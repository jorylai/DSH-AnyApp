import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:dsh_app/wish/wish_preset_bootstrap.dart';
import 'package:dsh_app/wish/wish_preset_installer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _hash = _envelope['hash'] as String;
const _id = 'local-starter-test';
final _files = [
  {
    'path': 'package.json',
    'data': base64Encode(utf8.encode('{"name":"@local/local-source"}')),
    'sha256': sha256.convert(utf8.encode('{"name":"@local/local-source"}')).toString(),
  },
];
final _envelope = <String, dynamic>{
  'format': 'dsh-anyapp-plugin/1',
  'api': 2,
  'portable': true,
  'sourceId': 'local-source',
  'hash': sha256.convert(utf8.encode(jsonEncode(_files))).toString(),
  'title': 'Voyo Trip',
  'files': _files,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('only a new installation is eligible, including empty upgraded walls', () {
    expect(WishPresetBootstrap.eligible(preferenceKeys: {}, runtimePresent: false), isTrue);
    expect(WishPresetBootstrap.eligible(preferenceKeys: {'wish.onboard.welcome'}, runtimePresent: false), isFalse);
    expect(WishPresetBootstrap.eligible(preferenceKeys: {'wish-wall-sort'}, runtimePresent: false), isFalse);
    expect(WishPresetBootstrap.eligible(preferenceKeys: {}, runtimePresent: true), isFalse);
  });
  test('first-run identities survive onboarding and a second initialization', () async {
    SharedPreferences.setMockInitialValues({});
    await WishPresetBootstrap.initialize();
    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString(WishPresetBootstrap.preferenceKey)!;
    final plan = jsonDecode(before) as Map;
    expect(plan['mode'], 'pending');
    expect((plan['ids'] as Map).keys.toSet(), {'radar', 'pomodoro'});
    expect((plan['ids'] as Map).values.toSet().length, 2);
    await prefs.setBool('wish.onboard.welcome', true);
    await WishPresetBootstrap.initialize();
    expect(prefs.getString(WishPresetBootstrap.preferenceKey), before);
    expect(await WishPresetBootstrap.pending(), isTrue);
  });
  test('an existing onboarding flag is skipped permanently even if false', () async {
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': false});
    await WishPresetBootstrap.initialize();
    final prefs = await SharedPreferences.getInstance();
    expect((jsonDecode(prefs.getString(WishPresetBootstrap.preferenceKey)!) as Map)['mode'], 'skipped');
    await prefs.remove('wish.onboard.welcome');
    expect(await WishPresetBootstrap.pending(), isFalse);
  });
  test('a completed current preload never returns to pending or replaces a deleted starter', () async {
    SharedPreferences.setMockInitialValues({
      WishPresetBootstrap.preferenceKey: jsonEncode({
        'version': 3,
        'mode': 'complete',
        'ids': {'radar': 'local-radar', 'pomodoro': 'local-pomodoro'},
        'progress': {},
      }),
    });
    expect(await WishPresetBootstrap.pending(), isFalse);
  });
  test('pending legacy starters migrate once without changing their original progress', () async {
    final legacy = {
      'version': 1,
      'mode': 'pending',
      'ids': {'voyo': 'local-voyo', 'calorie': 'local-calorie'},
      'progress': {
        'voyo': {'id': 'local-voyo', 'stage': 'installed', 'sourceHash': _hash, 'spec': '/kept/source'},
      },
    };
    SharedPreferences.setMockInitialValues({WishPresetBootstrap.preferenceKey: jsonEncode(legacy)});
    await WishPresetBootstrap.initialize();
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(WishPresetBootstrap.preferenceKey)!;
    final plan = jsonDecode(encoded) as Map;
    expect(plan['version'], 3);
    expect(plan['mode'], 'pending');
    expect((plan['ids'] as Map).keys.toSet(), {'radar', 'pomodoro'});
    expect((plan['ids'] as Map).values, isNot(contains('local-voyo')));
    expect(plan['progress'], isEmpty);
    expect(plan['legacyPlan'], legacy);
    await WishPresetBootstrap.initialize();
    expect(prefs.getString(WishPresetBootstrap.preferenceKey), encoded);
  });
  test('completed old preloads are replaced while their original plan stays recoverable', () async {
    final legacy = {
      'version': 1,
      'mode': 'complete',
      'ids': {'voyo': 'local-voyo', 'calorie': 'local-calorie'},
      'progress': {},
    };
    SharedPreferences.setMockInitialValues({WishPresetBootstrap.preferenceKey: jsonEncode(legacy)});
    expect(await WishPresetBootstrap.pending(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    final plan = jsonDecode(prefs.getString(WishPresetBootstrap.preferenceKey)!) as Map;
    expect(plan['version'], 3);
    expect(plan['mode'], 'pending');
    expect((plan['ids'] as Map).keys.toSet(), {'radar', 'pomodoro'});
    expect(plan['legacyPlan'], legacy);
    expect(await WishPresetBootstrap.hiddenStarterIds(), {'local-voyo', 'local-calorie'});
    final encoded = prefs.getString(WishPresetBootstrap.preferenceKey);
    await WishPresetBootstrap.initialize();
    expect(prefs.getString(WishPresetBootstrap.preferenceKey), encoded);
  });
  test('v2 skipped legacy migration is repaired without reallocating on retry', () async {
    final legacy = {
      'version': 1,
      'mode': 'complete',
      'ids': {'voyo': 'local-voyo', 'calorie': 'local-calorie'},
      'progress': <String, dynamic>{},
    };
    SharedPreferences.setMockInitialValues({
      WishPresetBootstrap.preferenceKey: jsonEncode({
        'version': 2,
        'mode': 'skipped',
        'ids': <String, dynamic>{},
        'progress': <String, dynamic>{},
        'legacyPlan': legacy,
      }),
    });
    expect(await WishPresetBootstrap.pending(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(WishPresetBootstrap.preferenceKey)!;
    final plan = jsonDecode(encoded) as Map;
    expect(plan['legacyPlan'], legacy);
    expect((plan['ids'] as Map).values.toSet().length, 2);
    await WishPresetBootstrap.initialize();
    expect(prefs.getString(WishPresetBootstrap.preferenceKey), encoded);
    expect(await WishPresetBootstrap.hiddenStarterIds(), {'local-voyo', 'local-calorie'});
  });
  test('current v2 progress and package hashes survive the schema migration', () async {
    final old = {
      'version': 2,
      'mode': 'pending',
      'ids': {'radar': 'local-radar', 'pomodoro': 'local-pomodoro'},
      'progress': {
        'radar': {'id': 'local-radar', 'stage': 'installed', 'sourceHash': _hash, 'spec': '/kept/source'},
      },
    };
    SharedPreferences.setMockInitialValues({WishPresetBootstrap.preferenceKey: jsonEncode(old)});
    await WishPresetBootstrap.initialize();
    final prefs = await SharedPreferences.getInstance();
    final plan = jsonDecode(prefs.getString(WishPresetBootstrap.preferenceKey)!) as Map;
    expect(plan, {...old, 'version': 3});
    expect(await WishPresetBootstrap.hiddenStarterIds(), isEmpty);
  });
  test('an existing install without old bundled starters stays skipped', () async {
    final old = {'version': 2, 'mode': 'skipped', 'ids': <String, dynamic>{}, 'progress': <String, dynamic>{}};
    SharedPreferences.setMockInitialValues({WishPresetBootstrap.preferenceKey: jsonEncode(old)});
    expect(await WishPresetBootstrap.pending(), isFalse);
    expect(await WishPresetBootstrap.hiddenStarterIds(), isEmpty);
  });
  test('retirement requires an exact valid old plan and never uses titles', () {
    final plan = <String, dynamic>{
      'version': 3,
      'ids': {'radar': 'local-radar', 'pomodoro': 'local-pomodoro'},
      'legacyPlan': {
        'version': 1,
        'mode': 'complete',
        'ids': {'voyo': 'local-builtin-voyo', 'calorie': 'local-builtin-calorie'},
      },
    };
    final retired = WishPresetBootstrap.retiredStarterIds(plan);
    expect(retired, {'local-builtin-voyo', 'local-builtin-calorie'});
    expect(retired, isNot(contains('local-hnyg9h8gg9-10nd8po')));
    expect(WishPresetBootstrap.retiredStarterIds({'title': 'Voyo Trip'}), isEmpty);
    expect(
      WishPresetBootstrap.retiredStarterIds({
        ...plan,
        'ids': {'radar': 'local-builtin-voyo'},
      }),
      isEmpty,
    );
    expect(
      WishPresetBootstrap.retiredStarterIds({
        ...plan,
        'legacyPlan': {
          'version': 1,
          'mode': 'complete',
          'ids': {'voyo': 'local-same', 'calorie': 'local-same'},
        },
      }),
      isEmpty,
    );
  });
  test('an incomplete saved install requires its original target and package hash', () {
    final initial = WishPackageInstallState.initial(_envelope, id: _id);
    expect(WishPackageInstallState.fromJson(initial.toJson()).id, _id);
    expect(
      () => WishPackageInstallState.fromJson({'id': _id, 'sourceHash': _hash, 'stage': 'imported'}),
      throwsFormatException,
    );
  });
  test('installation publishes only after install, reload and preview', () async {
    final driver = _Driver();
    var saved = WishPackageInstallState.initial(_envelope, id: _id);
    final result = await WishPresetInstaller.run(
      driver,
      _envelope,
      state: saved,
      save: (next) async {
        saved = next;
      },
    );
    expect(result['panel'], _id);
    expect(saved.stage, WishInstallStage.published);
    expect(driver.calls, [
      'connect',
      'begin',
      'project',
      'create',
      'import',
      'install',
      'checkpoint',
      'end',
      'restart',
      'preview',
      'publish',
      'describe',
    ]);
  });
  test('process death after create reuses the engine project and original identity', () async {
    final driver = _Driver();
    final initial = WishPackageInstallState.initial(_envelope, id: _id);
    var lost = true;
    await expectLater(
      WishPresetInstaller.run(
        driver,
        _envelope,
        state: initial,
        save: (next) async {
          if (lost) {
            lost = false;
            throw StateError('disk-busy');
          }
        },
      ),
      throwsStateError,
    );
    expect(driver.row?['id'], _id);
    await WishPresetInstaller.run(driver, _envelope, state: initial, save: (_) async {});
    expect(driver.calls.where((c) => c == 'create').length, 1);
  });
  test('process death after import retries the same import and releases the operation', () async {
    final driver = _Driver();
    var saved = WishPackageInstallState.initial(_envelope, id: _id);
    var lost = true;
    await expectLater(
      WishPresetInstaller.run(
        driver,
        _envelope,
        state: saved,
        save: (next) async {
          if (next.stage == WishInstallStage.imported && lost) {
            lost = false;
            throw StateError('disk-busy');
          }
          saved = next;
        },
      ),
      throwsStateError,
    );
    expect(saved.stage, WishInstallStage.created);
    expect(driver.calls.last, 'end');
    await WishPresetInstaller.run(
      driver,
      _envelope,
      state: saved,
      save: (next) async {
        saved = next;
      },
    );
    expect(saved.id, _id);
    expect(driver.calls.where((c) => c == 'import').length, 2);
    expect(driver.importedIdentity, _id);
  });
  test('failed installation retries its imported spec without another create/import', () async {
    final driver = _Driver()..failInstall = true;
    var saved = WishPackageInstallState.initial(_envelope, id: _id);
    await expectLater(
      WishPresetInstaller.run(
        driver,
        _envelope,
        state: saved,
        save: (next) async {
          saved = next;
        },
      ),
      throwsStateError,
    );
    expect(saved.stage, WishInstallStage.imported);
    expect(driver.calls, isNot(contains('publish')));
    driver.failInstall = false;
    await WishPresetInstaller.run(
      driver,
      _envelope,
      state: saved,
      save: (next) async {
        saved = next;
      },
    );
    expect(driver.calls.where((c) => c == 'create').length, 1);
    expect(driver.calls.where((c) => c == 'import').length, 1);
    expect(saved.stage, WishInstallStage.published);
  });
  test('failed publish retries after reload without silently reinstalling', () async {
    final driver = _Driver()..failPublish = true;
    var saved = WishPackageInstallState.initial(_envelope, id: _id);
    await expectLater(
      WishPresetInstaller.run(
        driver,
        _envelope,
        state: saved,
        save: (next) async {
          saved = next;
        },
      ),
      throwsStateError,
    );
    expect(saved.stage, WishInstallStage.reloaded);
    driver.failPublish = false;
    await WishPresetInstaller.run(
      driver,
      _envelope,
      state: saved,
      save: (next) async {
        saved = next;
      },
    );
    expect(driver.calls.where((c) => c == 'install').length, 1);
    expect(driver.calls.where((c) => c == 'restart').length, 1);
  });
  test('completed installation verifies the saved project without reinstalling', () async {
    final driver = _Driver()..row = {'id': _id, 'title': 'Voyo Trip', 'state': 'published', 'panel': _id};
    final state = WishPackageInstallState(
      id: _id,
      sourceHash: _hash,
      stage: WishInstallStage.published,
      spec: '/work/package',
    );
    await WishPresetInstaller.run(
      driver,
      _envelope,
      state: state,
      save: (_) async {
        fail('must not advance completed install');
      },
    );
    expect(driver.calls, ['connect', 'project', 'describe']);
  });
  test('a damaged source package is rejected before creating an empty project', () async {
    final driver = _Driver();
    final damaged = jsonDecode(jsonEncode(_envelope)) as Map<String, dynamic>;
    (damaged['files'] as List).first['data'] = base64Encode(utf8.encode('tampered'));
    await expectLater(
      WishPresetInstaller.run(
        driver,
        damaged,
        state: WishPackageInstallState.initial(_envelope, id: _id),
        save: (_) async {},
      ),
      throwsFormatException,
    );
    expect(driver.calls, isEmpty);
    expect(() => WishPackageInstallState.initial(_envelope, id: 'external-profile'), throwsFormatException);
  });
  test('a mismatched package does not connect or mutate the runtime', () async {
    final driver = _Driver();
    await expectLater(
      WishPresetInstaller.run(
        driver,
        {..._envelope, 'hash': 'different'},
        state: WishPackageInstallState.initial(_envelope, id: _id),
        save: (_) async {},
      ),
      throwsFormatException,
    );
    expect(driver.calls, isEmpty);
  });
}

class _Driver implements WishPackageInstallDriver {
  final calls = <String>[];
  Map<String, dynamic>? row;
  bool failInstall = false, failPublish = false;
  String? target, importedIdentity;
  @override
  Future<void> connect(String id, {bool restart = false}) async {
    target = id;
    calls.add(restart ? 'restart' : 'connect');
  }

  @override
  Future<void> begin(String token) async {
    calls.add('begin');
  }

  @override
  Future<void> end(String token) async {
    calls.add('end');
  }

  @override
  Future<Map<String, dynamic>?> project(String id) async {
    calls.add('project');
    return row;
  }

  @override
  Future<void> create(String id, String title) async {
    calls.add('create');
    if (row != null) throw StateError('already-exists');
    row = {'id': id, 'title': title, 'state': 'draft'};
  }

  @override
  Future<String> importPackage(Map<String, dynamic> envelope) async {
    calls.add('import');
    importedIdentity = target;
    return '/work/package';
  }

  @override
  Future<void> install(String id, String spec) async {
    calls.add('install');
    if (failInstall) throw StateError('failed-install');
  }

  @override
  Future<void> checkpoint() async {
    calls.add('checkpoint');
  }

  @override
  Future<void> preview(String id) async {
    calls.add('preview');
  }

  @override
  Future<Map<String, dynamic>> publish(String id, String title) async {
    calls.add('publish');
    if (failPublish) throw StateError('failed-publish');
    return row = {'id': id, 'title': title, 'state': 'published', 'panel': id};
  }

  @override
  Future<void> describe(String id, String title) async {
    calls.add('describe');
  }
}
