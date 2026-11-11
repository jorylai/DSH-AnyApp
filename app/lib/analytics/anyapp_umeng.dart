import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:umeng_apm_sdk/umeng_apm_sdk.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../state/app_info.dart';
import '../diagnostics/redact.dart';

/// Consent adapter for the SDKs installed by the official Umeng skill.
/// No account identity, prompts, work names or content are added to events.
abstract interface class AnyappDiagnosticsSdk {
  bool get started;
  Future<bool> enable({bool explicitConsent = false});
  void event(String name, Map<String, dynamic> properties);
  Future<void> closeAfterOptOut();
}

class AnyappUmeng implements AnyappDiagnosticsSdk {
  AnyappUmeng._();
  static final instance = AnyappUmeng._();
  static bool get supported => !kIsWeb && Platform.isAndroid;
  static const _host = MethodChannel('dsh/app');
  bool _started = false;
  bool _starting = false;
  int _generation = 0;

  @override
  bool get started => _started || _starting;

  @override
  Future<bool> enable({bool explicitConsent = false}) async {
    if (!supported) return false;
    if (_started) return true;
    final generation = _generation;
    _starting = true;
    await WidgetsBinding.instance.endOfFrame;
    if (generation != _generation) return false;
    // Official two-stage recipe: Application.preInit, then initCommon only
    // after the first frame and the current disclosure's persisted consent.
    final allowed = await _host.invokeMethod<bool>('activateAnalytics', {'explicitConsent': explicitConsent});
    if (allowed != true || generation != _generation) {
      _starting = false;
      return false;
    }
    _started = true;
    // The official Android plugin deliberately sends no MethodChannel reply.
    // Match its official example: dispatch without awaiting that pending future.
    unawaited(UmengCommonSdk.initCommon(
      '6af444776545637cd650f48a',
      'YOUR_IOS_APPKEY', // Unused: this project only ships Android.
      'https://github.com/jorylai/DSH-AnyApp',
    ));
    UmengCommonSdk.setPageCollectionModeAuto();
    UmengApmSdk(
      name: 'dsh_app',
      bver: AppInfo.version,
      enableLog: !kReleaseMode,
      enableTrackingPageFps: true,
      enableTrackingPagePerf: true,
      // Keep model traffic and authenticated URLs out of automatic tracing.
      enableTrackingApi: false,
      // Retain AnyApp's existing binding and widget tree. SDK.init supports
      // omitting appRunner; calling runApp again would discard page state.
      initFlutterBinding: () => WidgetsBinding.instance,
    ).init();
    // The app was started before consent, outside the SDK's guarded zone.
    // Keep its existing platform error handler and add the documented custom
    // exception path for uncaught asynchronous Dart errors.
    final previousError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      ExceptionTrace.captureException(
        exception: Exception(redactDiagnostics(error.toString())),
        stack: redactDiagnostics(stack.toString()),
      );
      return previousError?.call(error, stack) ?? false;
    };
    _starting = false;
    return true;
  }

  @override
  void event(String name, Map<String, dynamic> properties) {
    if (_started) UmengCommonSdk.onEvent('anyapp_$name', properties);
  }

  @override
  Future<void> closeAfterOptOut() async {
    if (!started) return;
    _generation++;
    // These Flutter SDKs expose no complete shutdown API. After consent has
    // been saved, terminate the SDK process rather than pretend a flag stops
    // its internal timers and uploads. The UI explicitly confirms this exit.
    await _host.invokeMethod<void>('closeAfterAnalyticsOptOut');
  }
}
