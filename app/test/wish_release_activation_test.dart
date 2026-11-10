import 'package:dsh_app/wish/wish_release_activation.dart';
import 'package:dsh_client/dsh_client.dart';
import 'package:flutter_test/flutter_test.dart';

const work = 'local-test';
const spec = '/root/.dsh/wish/workspaces/local-test/package';

class _Driver implements WishReleaseDriver {
  final events = <String>[];
  String version = 'before';
  String source = 'file:$spec';
  bool installed = true, enabled = true, busy = false, locked = false;
  bool unhealthyTarget = false;
  String? fail, rollbackFail;

  void step(String event) {
    events.add(event);
    final condition = version == 'before' ? rollbackFail : fail;
    if (condition == event) throw StateError('$event-failed');
  }

  @override
  Future<void> connect({bool restart = false}) async {
    expect(locked, isFalse, reason: 'Runtime cannot restart with a live mutation token');
    step(restart ? 'restart' : 'connect');
  }

  @override
  Future<bool> running() async => busy;
  @override
  Future<void> begin(String token) async {
    expect(locked, isFalse);
    locked = true;
    events.add('begin');
  }

  @override
  Future<void> end(String token) async {
    expect(locked, isTrue);
    locked = false;
    events.add('end');
  }

  @override
  Future<Map<String, dynamic>> checkpoint() async {
    events.add('checkpoint');
    return {'hash': 'before'};
  }

  @override
  Future<Map<String, dynamic>> restore(String hash) async {
    expect(locked, isTrue);
    version = hash;
    step('restore:$hash');
    return {'spec': spec};
  }

  @override
  Future<List<PluginBundle>> bundles() async {
    step('bundles');
    return [
      PluginBundle(
        name: '@local/$work',
        installed: installed,
        enabled: enabled,
        source: source,
        error: unhealthyTarget && version == 'target' && events.contains('restart')
            ? const PluginManagerError('operation-error')
            : null,
      ),
      // Another work can never satisfy activation of this one.
      const PluginBundle(name: '@local/local-other', installed: true, enabled: true, source: spec),
    ];
  }

  @override
  Future<void> install(String target) async {
    expect(installed, isFalse, reason: 'DSH rejects installBundle for an existing dependency');
    expect(target, spec);
    step('install');
    installed = enabled = true;
  }

  @override
  Future<void> enable(String name) async {
    expect(name, '@local/$work');
    step('enable');
    enabled = true;
  }

  @override
  Future<void> preview(String id) async {
    expect(id, work);
    step('preview');
  }
}

void main() {
  test('restores an installed local bundle without reinstalling or removing it', () async {
    final driver = _Driver();
    await WishReleaseRestorer(driver).restore(work, 'target');
    expect(driver.version, 'target');
    expect(driver.events, ['begin', 'checkpoint', 'restore:target', 'bundles', 'end', 'restart', 'bundles', 'preview']);
  });

  test('enables an installed disabled bundle before restart', () async {
    final driver = _Driver()..enabled = false;
    await WishReleaseRestorer(driver).restore(work, 'target');
    expect(driver.events, containsAllInOrder(['restore:target', 'enable', 'end', 'restart', 'preview']));
    expect(driver.events, isNot(contains('install')));
  });

  test('only a missing bundle is installed', () async {
    final driver = _Driver()..installed = false;
    await WishReleaseRestorer(driver).restore(work, 'target');
    expect(driver.events.where((event) => event == 'install'), hasLength(1));
    expect(driver.events.last, 'preview');
  });

  test('normalizes only local file and link source prefixes', () {
    for (final source in [spec, 'file:$spec', 'link:$spec/']) {
      expect(WishReleaseRestorer.sameSource(PluginBundle(name: '@local/$work', source: source), spec), isTrue);
    }
    expect(
      WishReleaseRestorer.sameSource(const PluginBundle(name: '@local/$work', source: '$spec-other'), spec),
      isFalse,
    );
    expect(WishReleaseRestorer.sameSource(const PluginBundle(name: '@local/$work'), spec), isFalse);
  });

  for (final point in ['restore:target', 'restart', 'bundles', 'preview', 'enable', 'install']) {
    test('$point failure restores and verifies the previous code before returning failure', () async {
      final driver = _Driver()
        ..fail = point
        ..enabled = point != 'enable'
        ..installed = point != 'install';
      await expectLater(
        WishReleaseRestorer(driver).restore(work, 'target'),
        throwsA(isA<StateError>().having((error) => error.message, 'reason', '$point-failed')),
      );
      expect(driver.version, 'before');
      expect(driver.locked, isFalse);
      expect(
        driver.events,
        containsAllInOrder(['end', 'connect', 'begin', 'restore:before', 'end', 'restart', 'preview']),
      );
    });
  }

  test('a changed package source is never overwritten by reinstalling', () async {
    final driver = _Driver()..source = '$spec-other';
    await expectLater(
      WishReleaseRestorer(driver).restore(work, 'target'),
      throwsA(isA<StateError>().having((error) => error.message, 'reason', 'release-rollback-needs-retry')),
    );
    expect(driver.version, 'before');
    expect(driver.events, isNot(contains('install')));
  });

  test('a bundle that remains unhealthy after restart rolls back without reinstalling', () async {
    final driver = _Driver()..unhealthyTarget = true;
    await expectLater(
      WishReleaseRestorer(driver).restore(work, 'target'),
      throwsA(isA<StateError>().having((error) => error.message, 'reason', 'release-activation-failed')),
    );
    expect(driver.version, 'before');
    expect(driver.events.where((event) => event == 'preview'), hasLength(1));
    expect(driver.events, isNot(contains('install')));
  });

  test('a failed rollback keeps an explicit recovery error', () async {
    final driver = _Driver()
      ..fail = 'preview'
      ..rollbackFail = 'restore:before';
    await expectLater(
      WishReleaseRestorer(driver).restore(work, 'target'),
      throwsA(isA<StateError>().having((error) => error.message, 'reason', 'release-rollback-needs-retry')),
    );
    expect(driver.locked, isFalse);
  });

  test('a running conversation prevents any version mutation', () async {
    final driver = _Driver()..busy = true;
    await expectLater(
      WishReleaseRestorer(driver).restore(work, 'target'),
      throwsA(isA<StateError>().having((error) => error.message, 'reason', 'finish-current-conversation-first')),
    );
    expect(driver.events, isEmpty);
    expect(driver.version, 'before');
  });
}
