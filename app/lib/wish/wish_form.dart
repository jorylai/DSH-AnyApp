import 'package:flutter/services.dart';
import 'package:dsh_client/dsh_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';

import 'wish_app_runtime.dart';

Map<String, dynamic> wishMap(Object? value) => (value as Map).cast<String, dynamic>();

String wishErrorText(Object error) {
  final modelCode = error is DshRemoteException
      ? error.code.split('/').last
      : error is StateError
      ? error.message
      : error is PlatformException
      ? error.message
      : null;
  if (modelCode == 'overlay-permission-required') return appL10n.wishNeedOverlay;
  if (modelCode == 'finish-current-conversation-first' || modelCode == 'another-work-task-running')
    return appL10n.wishFinishTaskFirst;
  if (modelCode == 'notification-listener-permission-required' || modelCode == 'notifications-work-permission-required')
    return appL10n.wishNeedNotificationReading;
  if (modelCode == 'calendar-system-permission-required' || modelCode == 'calendar-work-permission-required')
    return appL10n.wishNeedCalendar;
  if (modelCode == 'location-system-permission-required' || modelCode == 'location-work-permission-required')
    return appL10n.wishNeedLocation;
  if (modelCode == 'no-writable-calendar') return appL10n.wishNoWritableCalendar;
  if (modelCode == 'speech-service-unavailable' ||
      modelCode == 'tts-unavailable' ||
      modelCode == 'tts-language-unavailable')
    return appL10n.wishSpeechUnavailable;
  if (modelCode == 'location-timeout' || modelCode == 'location-provider-unavailable')
    return appL10n.wishLocationUnavailable;
  if (modelCode == 'travel-saved-time-required' || modelCode == 'travel-saved-reminder-in-past')
    return appL10n.wishTripPartialSave;
  if (modelCode == 'travel-import-use-text-or-image') return appL10n.wishTripImportFormat;
  if ({
    'MODEL_NOT_CONFIGURED',
    'MISSING_CREDENTIAL',
    'ACCOUNT_SIGN_IN_REQUIRED',
    'INVALID_CREDENTIAL',
  }.contains(modelCode))
    return appL10n.wishModelSignIn;
  if (modelCode == 'VISION_UNAVAILABLE') return appL10n.wishModelVision;
  if ({'ACCOUNT_QUOTA_EXCEEDED', 'QUOTA_EXCEEDED', 'ACCOUNT_INSUFFICIENT_BALANCE'}.contains(modelCode))
    return appL10n.wishModelQuota;
  if (modelCode == 'MODEL_ROUTE_UNAVAILABLE') return appL10n.wishModelUnavailable;
  if (modelCode == 'TIMEOUT') return appL10n.wishModelTimeout;
  if (modelCode == 'creator-preset-not-active' || modelCode == 'creator-preset-unavailable')
    return appL10n.wishCreatorModeRequired;
  if (error is DshRemoteException) {
    if (error.code == 'wish/plugin-not-installed') return appL10n.wishPluginNotInstalled;
    if (error.code == 'app-form/invalid-calories') return appL10n.wishCaloriesHelp;
    if (error.code == 'app-form/missing-artifact') return appL10n.wishMissingArtifact;
    if (error.code.startsWith('app-form/invalid-') ||
        error.code.startsWith('app-form/unsupported-') ||
        error.code.startsWith('app-form/missing-')) {
      return '${appL10n.wishArtifactInvalid} (${error.code})';
    }
    return '${appL10n.wishActionFailed} (${error.code})';
  }
  return '${appL10n.wishFailure} ${error is StateError ? error.message : error.runtimeType}';
}

class WishForm {
  WishForm(Map<String, dynamic> json)
    : manifest = wishMap(json['manifest']),
      view = wishMap(json['view']),
      hash = json['hash'] as String,
      specs = (json['specs'] as List).cast<String>();
  final Map<String, dynamic> manifest;
  final Map<String, dynamic> view;
  final String hash;
  final List<String> specs;
  String get id => manifest['id'] as String;
  String get name => manifest['name'] as String;
  String get profile => wishMap(manifest['runtime'])['profile'] as String;
  bool has(String capability) => (manifest['capabilities'] as List).contains(capability);
}

class WishFormInstaller {
  WishFormInstaller(this.container);
  final ProviderContainer container;
  Future<WishForm> prepare(String id) async {
    final client = await WishAppRuntime.connect(container, 'app-$id');
    return WishForm(wishMap(await client.rpc.call('appForm/prepare', {'form': id})));
  }

  /// The UI obtains consent before entering this method. The real DSH package
  /// manager installs bundles; cold restart and health check prove activation.
  Future<DshClient> install(WishForm form, void Function(String) progress) async {
    var client = await WishAppRuntime.connect(container, form.profile);
    final bundles = (await client.rpc.call('pluginManager/listBundles') as List).map(wishMap).toList();
    final requested = wishMap(form.manifest['runtime'])['bundles'] as List;
    for (var i = 0; i < form.specs.length; i++) {
      progress('${i + 1}/${form.specs.length}');
      final name = requested[i]['name'];
      final installed = bundles.where((b) => b['name'] == name && b['installed'] == true).firstOrNull;
      if (installed != null) {
        final source = '${installed['source'] ?? ''}';
        if (source != form.specs[i] && source != 'file:${form.specs[i]}' && source != 'link:${form.specs[i]}')
          throw StateError('bundle-source-mismatch');
        if (installed['enabled'] != true) {
          final enabled = wishMap(
            await client.rpc.call('pluginManager/setBundleEnabled', {'name': name, 'enabled': true}),
          );
          if (!{'applied', 'restart-required'}.contains(enabled['application']))
            throw StateError('bundle-enable-failed');
        }
        continue;
      }
      final result = wishMap(
        await client.rpc.call('pluginManager/installBundle', {
          'spec': form.specs[i],
          'options': {'enabled': true, 'requestId': 'wish-${form.id}-$i'},
        }, const Duration(minutes: 5)),
      );
      if (!{'applied', 'restart-required'}.contains(result['application'])) {
        throw StateError(
          'bundle-install-failed: ${result['error'] is Map ? result['error']['code'] : result['application']}',
        );
      }
    }
    client = await WishAppRuntime.connect(container, form.profile, restart: true);
    final health = wishMap(await client.rpc.call('appForm/health', {'form': form.id}));
    if (health['ready'] != true || health['hash'] != form.hash) throw StateError('form-health-failed');
    return client;
  }
}
