import 'dart:convert';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:ui' as ui;

import 'wish_package_identity.dart';
import 'wish_release_activation.dart';

import 'wish_app_runtime.dart';
import 'wish_creator.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_project.dart';
import 'wish_preset_cache.dart';

enum WishInstallStage { allocated, created, imported, installed, reloaded, published }

/// The target identity is saved before any engine mutation. Retrying an import
/// must continue this identity rather than leave another half-created work.
class WishPackageInstallState {
  const WishPackageInstallState({
    required this.id,
    required this.sourceHash,
    this.stage = WishInstallStage.allocated,
    this.spec,
  });

  factory WishPackageInstallState.initial(Map<String, dynamic> envelope, {String? id}) {
    final checked = WishPresetPackageCache.validate(jsonEncode(envelope));
    final target = id ?? newWishId();
    if (!RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(target)) {
      throw const FormatException('invalid-install-state');
    }
    return WishPackageInstallState(id: target, sourceHash: checked['hash'] as String);
  }

  factory WishPackageInstallState.fromJson(Map<String, dynamic> value) {
    final id = value['id'], hash = value['sourceHash'];
    final stage = WishInstallStage.values.where((s) => s.name == value['stage']).firstOrNull;
    if (id is! String ||
        !RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(id) ||
        hash is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        stage == null ||
        (stage.index >= WishInstallStage.imported.index && value['spec'] is! String)) {
      throw const FormatException('invalid-install-state');
    }
    return WishPackageInstallState(id: id, sourceHash: hash, stage: stage, spec: value['spec'] as String?);
  }

  final String id, sourceHash;
  final WishInstallStage stage;
  final String? spec;
  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceHash': sourceHash,
    'stage': stage.name,
    if (spec != null) 'spec': spec,
  };
  WishPackageInstallState advance(WishInstallStage next, {String? spec}) =>
      WishPackageInstallState(id: id, sourceHash: sourceHash, stage: next, spec: spec ?? this.spec);
}

/// Narrow boundary also lets recovery be checked without a model or Android.
abstract interface class WishPackageInstallDriver {
  Future<void> connect(String id, {bool restart = false});
  Future<void> begin(String token);
  Future<void> end(String token);
  Future<Map<String, dynamic>?> project(String id);
  Future<void> create(String id, String title);
  Future<String> importPackage(Map<String, dynamic> envelope);
  Future<void> install(String id, String spec);
  Future<void> checkpoint();
  Future<void> preview(String id);
  Future<Map<String, dynamic>> publish(String id, String title);
  Future<void> describe(String id, String title);
}

class WishPresetInstaller {
  /// Explicit shared appearance is the sender's chosen home-card identity.
  /// Keep it in the user layer so a plugin's later work.describe call cannot
  /// turn the imported name back into its original creation prompt. Legacy
  /// locale/manifest fallbacks remain declared metadata, not user overrides.
  static Map<String, dynamic> sharedAppearanceOverrides(Map<String, dynamic> envelope) {
    final presentation = envelope['presentation'];
    if (presentation is! Map || presentation['version'] != 1) return {};
    final rawTitle = presentation['title'];
    final title = rawTitle is String
        ? rawTitle.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim()
        : '';
    final icon = WishPackageIdentity.sanitizeIcon(presentation['icon']);
    return {if (title.isNotEmpty && title.length <= 80) 'customName': title, 'icon': ?icon};
  }

  static Future<WishProject> install(
    ProviderContainer container,
    Map<String, dynamic> envelope, {
    required WishPackageInstallState state,
    required Future<void> Function(WishPackageInstallState) save,
    void Function(WishInstallStage)? onStage,
  }) async => WishProject(
    await run(_LocalInstaller(container, envelope), envelope, state: state, save: save, onStage: onStage),
  );

  static Future<Map<String, dynamic>> run(
    WishPackageInstallDriver driver,
    Map<String, dynamic> envelope, {
    required WishPackageInstallState state,
    required Future<void> Function(WishPackageInstallState) save,
    void Function(WishInstallStage)? onStage,
  }) async {
    WishPresetPackageCache.validate(jsonEncode(envelope));
    WishPackageInstallState.fromJson(state.toJson());
    if (envelope['hash'] != state.sourceHash) {
      throw const FormatException('release-incompatible-format');
    }
    var progress = state;
    Future<void> advance(WishInstallStage stage, {String? spec}) async {
      final next = progress.advance(stage, spec: spec);
      await save(next);
      progress = next;
      onStage?.call(stage);
      debugPrint('WISH import stage=${stage.name}');
    }

    onStage?.call(progress.stage);
    final id = progress.id, title = WishPackageIdentity.resolve(envelope).title;
    await driver.connect(id);
    if (progress.stage.index < WishInstallStage.reloaded.index) {
      final token = 'library-$id';
      await driver.begin(token);
      try {
        if (progress.stage == WishInstallStage.allocated) {
          // create may have completed just before process death or a failed
          // progress write. The authenticated engine remains authoritative.
          if (await driver.project(id) == null) await driver.create(id, title);
          await advance(WishInstallStage.created);
        }
        if (progress.stage == WishInstallStage.created) {
          final spec = await driver.importPackage(envelope);
          await advance(WishInstallStage.imported, spec: spec);
        }
        if (progress.stage == WishInstallStage.imported) {
          await driver.install(id, progress.spec!);
          await driver.checkpoint();
          await advance(WishInstallStage.installed);
        }
      } finally {
        await driver.end(token);
      }
      await driver.connect(id, restart: true);
      await advance(WishInstallStage.reloaded);
    }
    Map<String, dynamic>? row;
    if (progress.stage == WishInstallStage.reloaded) {
      await driver.preview(id);
      row = await driver.publish(id, title);
      await advance(WishInstallStage.published);
    } else {
      row = await driver.project(id);
    }
    if (row == null || row['state'] != 'published' || row['panel'] != id) {
      throw StateError('release-publish-incomplete');
    }
    await driver.describe(id, title);
    return row;
  }
}

class _LocalInstaller implements WishPackageInstallDriver {
  _LocalInstaller(this.container, Map<String, dynamic> envelope)
    : appearance = WishPackageIdentity.resolve(envelope),
      sharedOverrides = WishPresetInstaller.sharedAppearanceOverrides(envelope);
  final WishPackageIdentity appearance;
  final Map<String, dynamic> sharedOverrides;
  final ProviderContainer container;
  late DshClient client;
  @override
  Future<void> connect(String id, {bool restart = false}) async {
    client = await WishAppRuntime.connect(container, 'app-$id', restart: restart);
  }

  @override
  Future<void> begin(String token) async {
    await client.rpc.call('wishMobile/beginOperation', {'token': token});
  }

  @override
  Future<void> end(String token) async {
    await client.rpc.call('wishMobile/endOperation', {'token': token});
  }

  @override
  Future<Map<String, dynamic>?> project(String id) async {
    final rows = await client.rpc.call('wishMobile/projects', {});
    if (rows is! List) throw StateError('invalid-project-list');
    for (final row in rows) {
      final value = wishMap(row);
      if (value['id'] == id) return value;
    }
    return null;
  }

  @override
  Future<void> create(String id, String title) async {
    await client.rpc.call('wishMobile/create', {'form': id, 'title': title, 'request': title});
  }

  @override
  Future<String> importPackage(Map<String, dynamic> envelope) async {
    final value = wishMap(await client.rpc.call('wishMobile/releaseImport', {'envelope': envelope}));
    if (value['sourceHash'] != envelope['hash'] || value['spec'] is! String) {
      throw StateError('release-import-incomplete');
    }
    return value['spec'] as String;
  }

  @override
  Future<void> install(String id, String spec) async {
    // Installing may already have completed before a progress write failed.
    // Reuse only the bundle for this host-issued identity and import target.
    final existing = (await client.listBundles()).where((b) => b.name == '@local/$id' && b.installed).firstOrNull;
    if (existing != null) {
      if (!WishReleaseRestorer.sameSource(existing, spec)) throw StateError('bundle-source-mismatch');
      if (!existing.enabled && !(await client.setBundleEnabled(existing.name, true)).succeeded) {
        throw StateError('bundle-enable-failed');
      }
      return;
    }
    final result = await client.installBundle(spec, enabled: true);
    debugPrint(
      'WISH import install application=${result.application.name} code=${result.error?.code ?? "none"} step=${result.failedAt ?? "none"} kind=${result.packageResult?.kind ?? "none"} exit=${result.packageResult?.exitCode}',
    );
    if (!result.succeeded)
      throw StateError(
        'release-install-failed:${result.error?.code ?? result.packageResult?.kind ?? result.application.name}',
      );
  }

  @override
  Future<void> checkpoint() async {
    await client.rpc.call('wishMobile/releaseCheckpoint', {});
  }

  @override
  Future<void> preview(String id) async {
    await client.rpc.call('wishMobile/preview', {'form': id});
  }

  @override
  Future<Map<String, dynamic>> publish(String id, String title) async =>
      wishMap(await client.rpc.call('wishMobile/publish', {'form': id, 'title': title, 'panel': id}));
  @override
  Future<void> describe(String id, String title) async {
    final icon = appearance.icon.isNotEmpty ? await _nativeIcon(appearance.icon) : <String, dynamic>{};
    await WishDevice.call(
      'works.describe',
      work: id,
      args: {
        'value': {'title': title, if (icon.isNotEmpty) 'icon': icon},
      },
    );
    if (sharedOverrides.isNotEmpty) {
      await WishDevice.call(
        'works.update',
        work: id,
        args: {
          'value': {...sharedOverrides, if (sharedOverrides.containsKey('icon')) 'icon': icon},
        },
      );
    }
  }
}

// A legacy package icon is rendered locally once; native metadata remains PNG.
Future<Map<String, dynamic>> _nativeIcon(Map<String, dynamic> icon) async {
  if (icon['svg'] is! String) return icon;
  final picture = await vg.loadPicture(SvgStringLoader(icon['svg'] as String), null);
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.scale(192 / picture.size.width, 192 / picture.size.height);
  canvas.drawPicture(picture.picture);
  final rendered = recorder.endRecording();
  final image = await rendered.toImage(192, 192);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('invalid-icon-image');
    return {'bitmap': base64Encode(bytes.buffer.asUint8List())};
  } finally {
    image.dispose();
    rendered.dispose();
    picture.picture.dispose();
  }
}
