import 'package:dsh_client/dsh_client.dart';

/// Code-only version changes. No work data or package removal is involved.
abstract interface class WishReleaseDriver {
  Future<void> connect({bool restart = false});
  Future<bool> running();
  Future<void> begin(String token);
  Future<void> end(String token);
  Future<Map<String, dynamic>> checkpoint();
  Future<Map<String, dynamic>> restore(String hash);
  Future<List<PluginBundle>> bundles();
  Future<void> install(String spec);
  Future<void> enable(String name);
  Future<void> preview(String work);
}

class WishClientReleaseDriver implements WishReleaseDriver {
  WishClientReleaseDriver(this.client, {required this.open});
  DshClient client;
  final Future<DshClient> Function(bool restart) open;

  @override
  Future<void> connect({bool restart = false}) async => client = await open(restart);
  @override
  Future<bool> running() async => (await client.listSessions()).any((session) => session.running);
  @override
  Future<void> begin(String token) async => client.rpc.call('wishMobile/beginOperation', {'token': token});
  @override
  Future<void> end(String token) async => client.rpc.call('wishMobile/endOperation', {'token': token});
  @override
  Future<Map<String, dynamic>> checkpoint() async =>
      (await client.rpc.call('wishMobile/releaseCheckpoint', {}) as Map).cast<String, dynamic>();
  @override
  Future<Map<String, dynamic>> restore(String hash) async =>
      (await client.rpc.call('wishMobile/releaseRestore', {'hash': hash}) as Map).cast<String, dynamic>();
  @override
  Future<List<PluginBundle>> bundles() => client.listBundles();
  @override
  Future<void> install(String spec) async {
    if (!(await client.installBundle(spec, enabled: true)).succeeded) throw StateError('release-install-failed');
  }

  @override
  Future<void> enable(String name) async {
    if (!(await client.setBundleEnabled(name, true)).succeeded) throw StateError('bundle-enable-failed');
  }

  @override
  Future<void> preview(String work) async => client.rpc.call('wishMobile/preview', {'form': work});
}

/// Local packages keep the same installed source when their code is restored.
/// Reinstalling them is rejected by DSH's HMR package manager. Enable the
/// existing dependency if needed, then restart and verify the actual host.
class WishReleaseRestorer {
  WishReleaseRestorer(this.driver);
  final WishReleaseDriver driver;

  static bool sameSource(PluginBundle bundle, String spec) {
    String normalize(String value) =>
        value.replaceFirst(RegExp(r'^(file:|link:)'), '').replaceFirst(RegExp(r'/+$'), '');
    final source = bundle.source ?? bundle.installTargetSpec;
    return source != null && normalize(source) == normalize(spec);
  }

  Future<void> _ensure(String work, String spec) async {
    final installed = (await driver.bundles())
        .where((bundle) => bundle.name == '@local/$work' && bundle.installed)
        .firstOrNull;
    if (installed == null) {
      await driver.install(spec);
    } else {
      if (!sameSource(installed, spec)) throw StateError('bundle-source-mismatch');
      if (!installed.enabled) await driver.enable(installed.name);
    }
  }

  Future<void> _verify(String work, String spec) async {
    final active = (await driver.bundles())
        .where((bundle) => bundle.name == '@local/$work' && bundle.installed)
        .firstOrNull;
    if (active == null || !active.enabled || active.error != null || !sameSource(active, spec)) {
      throw StateError('release-activation-failed');
    }
    await driver.preview(work);
  }

  Future<T> _mutate<T>(String token, Future<T> Function() action) async {
    if (await driver.running()) throw StateError('finish-current-conversation-first');
    await driver.begin(token);
    try {
      return await action();
    } finally {
      // A runtime restart must happen after this token is released, otherwise
      // its hostBusy guard correctly refuses to stop the engine.
      await driver.end(token);
    }
  }

  Future<void> restore(String work, String hash) async {
    final token = 'version-${DateTime.now().microsecondsSinceEpoch}';
    String? beforeHash;
    var attempted = false;
    try {
      final spec = await _mutate(token, () async {
        beforeHash = (await driver.checkpoint())['hash'] as String;
        attempted = true;
        final target = await driver.restore(hash);
        final spec = target['spec'] as String;
        await _ensure(work, spec);
        return spec;
      });
      await driver.connect(restart: true);
      await _verify(work, spec);
    } catch (error, stack) {
      if (!attempted || beforeHash == null) rethrow;
      try {
        // A failed restart can invalidate the original client. Reconnect
        // before restoring the saved code, without deleting the dependency.
        await driver.connect();
        final spec = await _mutate(token, () async {
          final before = await driver.restore(beforeHash!);
          final spec = before['spec'] as String;
          await _ensure(work, spec);
          return spec;
        });
        await driver.connect(restart: true);
        await _verify(work, spec);
      } catch (_) {
        throw StateError('release-rollback-needs-retry');
      }
      Error.throwWithStackTrace(error, stack);
    }
  }
}
