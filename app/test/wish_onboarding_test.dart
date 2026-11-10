import 'dart:async';

import 'package:dsh_app/analytics/anyapp_analytics.dart';
import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/runtime/runtime_bridge.dart';
import 'package:dsh_app/runtime/runtime_state.dart';
import 'package:dsh_app/state/account_state.dart';
import 'package:dsh_app/state/connection_state.dart';
import 'package:dsh_app/state/settings_state.dart';
import 'package:dsh_app/state/phone_state.dart';
import 'package:dsh_app/state/phone_turn_end.dart';
import 'package:dsh_app/wish/wish_boot.dart';
import 'package:dsh_app/wish/wish_setup_guide.dart';
import 'package:dsh_app/wish/wish_account_page.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_dot_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const paths = MethodChannel('plugins.flutter.io/path_provider');
  const permissions = MethodChannel('dsh/wish/permissions');
  final asked = <String>[];
  setUp(() {
    asked.clear();
    SharedPreferences.setMockInitialValues({});
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(paths, (_) async {
      throw PlatformException(code: 'files-unavailable');
    });
    messenger.setMockMethodCallHandler(permissions, (call) async {
      if (call.method != 'status') asked.add(call.method);
      return {'camera': false, 'microphone': false, 'notifications': false};
    });
    messenger.setMockMethodCallHandler(
      WishDevice.channel,
      (call) async => switch (call.method) {
        'works.all' => {},
        'setup.info' => {
          'vendor': 'xiaomi',
          'manufacturer': 'Xiaomi',
          'brand': 'Redmi',
          'sdkInt': 36,
          'accessibility': {'enabled': false, 'serviceConnected': false},
          'notifications': {'enabled': false, 'listenerEnabled': false},
          'permissions': {'camera': false, 'microphone': false},
          'vendorSettings': {'autostart': null, 'background': null, 'popup': null},
        },
        _ => null,
      },
    );
  });
  tearDown(() async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(paths, null);
    messenger.setMockMethodCallHandler(permissions, null);
    messenger.setMockMethodCallHandler(WishDevice.channel, null);
    WishDevice.channel.setMethodCallHandler(null);
  });

  testWidgets('welcome consent is optional and local setup can be genuinely deferred', (tester) async {
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.notInstalled));
    await tester.pumpWidget(harness.app(const WishBootPage()));
    await tester.pumpAndSettle();
    expect(find.text('DSH AnyApp'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-brand-mark')), findsOneWidget);
    expect(find.byType(WishDotMark), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsNothing);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    await tester.ensureVisible(find.text(appL10n.anyWelcomeStart));
    await tester.tap(find.text(appL10n.anyWelcomeStart));
    await tester.pumpAndSettle();
    expect(find.text(appL10n.anyWelcomeRuntimeStart), findsOneWidget);
    await tester.ensureVisible(find.text('先看看界面'));
    await tester.tap(find.text('先看看界面'));
    await tester.pumpAndSettle();
    expect(find.text('我的造物'), findsWidgets);
    expect(harness.runtime.installCalls, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('wish.onboard.permissions'), isNull);
    expect(prefs.getBool('wish.onboard.connect_skipped'), isNull);
    expect(asked, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('capability introduction does not pretend to save a questionnaire or request permissions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': true});
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.installed));
    await tester.pumpWidget(harness.app(const WishBootPage()));
    await tester.pumpAndSettle();
    expect(find.text(appL10n.anyWelcomeAbilitiesTitle), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    await tester.ensureVisible(find.text('继续'));
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsOneWidget);
    expect(asked, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('denied permission in the brand guide remains optional and login skip reaches the wall', (tester) async {
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': true, 'wish.onboard.wants': true});
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.installed));
    await tester.pumpWidget(harness.app(const WishBootPage()));
    await tester.pumpAndSettle();
    final guide = tester.widget<WishSetupGuidePage>(find.byType(WishSetupGuidePage));
    expect(guide.onboarding, isTrue);
    expect(asked, isEmpty);
    await tester.ensureVisible(find.byKey(const ValueKey('setup-topic-notifications')));
    await tester.tap(find.byKey(const ValueKey('setup-topic-notifications')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('setup-enable-notifications')));
    await tester.tap(find.byKey(const ValueKey('setup-enable-notifications')));
    await tester.pumpAndSettle();
    expect(asked, ['requestNotifications']);
    expect(
      harness.analytics.events.where((e) => e.$1 == AnyappEvent.permissionResult).single.$2,
      AnyappOutcome.failure,
    );
    await tester.scrollUntilVisible(find.byKey(const ValueKey('setup-skip')), 250);
    await tester.tap(find.byKey(const ValueKey('setup-skip')));
    await tester.pumpAndSettle();
    expect(find.text(appL10n.anyWelcomeLoginTitle), findsOneWidget);
    expect(harness.analytics.events.where((e) => e.$1 == AnyappEvent.onboardingSkip).single.$2, AnyappOutcome.skipped);
    expect(asked, ['requestNotifications']);
    expect((await SharedPreferences.getInstance()).getBool('wish.onboard.permissions'), isTrue);
    await tester.ensureVisible(find.text(appL10n.anyWelcomeLoginLater));
    await tester.tap(find.text(appL10n.anyWelcomeLoginLater));
    await tester.pumpAndSettle();
    expect(find.text('我的造物'), findsWidgets);
    expect((await SharedPreferences.getInstance()).getBool('wish.onboard.connect_skipped'), isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('installed runtime startup failure offers restart without reinstalling', (tester) async {
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': true});
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.error, installedVersion: 'test-runtime'));
    await tester.pumpWidget(harness.app(const WishBootPage()));
    await tester.pumpAndSettle();
    expect(find.text('重新启动'), findsOneWidget);
    await tester.ensureVisible(find.text('重新启动'));
    await tester.tap(find.text('重新启动'));
    await tester.pumpAndSettle();
    expect(harness.runtime.starts, 1);
    expect(harness.runtime.installCalls, 0);
    expect(
      harness.analytics.events.where((e) => e.$1 == AnyappEvent.onboardingContinue).last.$2,
      AnyappOutcome.success,
    );
    expect(find.text(appL10n.anyWelcomeAbilitiesTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a completed call without an installed runtime is a failure event', (tester) async {
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': true});
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.notInstalled));
    await tester.pumpWidget(harness.app(const WishBootPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(appL10n.anyWelcomeRuntimeStart));
    await tester.tap(find.text(appL10n.anyWelcomeRuntimeStart));
    await tester.pumpAndSettle();
    expect(harness.runtime.installCalls, 1);
    expect(harness.analytics.events.where((e) => e.$1 == AnyappEvent.runtimeInstall).map((e) => e.$2), [
      AnyappOutcome.start,
      AnyappOutcome.failure,
    ]);
    expect(find.textContaining('准备未完成'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text in landscape can scroll to onboarding actions without overflow', (tester) async {
    tester.view.physicalSize = const Size(700, 350);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': true});
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.installed));
    await tester.pumpWidget(harness.app(const WishBootPage(), largeText: true));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('继续'));
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('setup-skip')), 250);
    expect(tester.widget<TextButton>(find.byKey(const ValueKey('setup-skip'))).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow phone welcome and permissions remain scrollable at large text size', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.installed));
    await tester.pumpWidget(harness.app(const WishBootPage(), largeText: true));
    await tester.pumpAndSettle();
    final start = find.text(appL10n.anyWelcomeStart);
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    final next = find.text('继续');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsOneWidget);
    expect(tester.getRect(find.byKey(const ValueKey('setup-skip'))).bottom, lessThanOrEqualTo(568));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('account page reads only the local connection and hides raw startup errors', (tester) async {
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.installed));
    harness.runtime.failStart = true;
    await tester.pumpWidget(harness.app(const WishAccountPage()));
    await tester.pumpAndSettle();
    expect(harness.activeReads, 0);
    expect(find.text('暂时没能读取本机的模型状态，请刷新重试。'), findsOneWidget);
    expect(find.textContaining('synthetic-secret'), findsNothing);
    harness.runtime.failStart = false;
    await tester.tap(find.byTooltip('刷新状态'));
    await tester.pumpAndSettle();
    expect(find.text('暂时没能读取本机的模型状态，请刷新重试。'), findsNothing);
    expect(harness.activeReads, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('browser return shows recovery actions without authorization query contents', (tester) async {
    final harness = _Harness(
      const RuntimeStatus(phase: RuntimePhase.running),
      account: const AccountState(
        phase: AccountPhase.signingIn,
        stage: SignInStage.waitingBrowser,
        browserHint: BrowserHint.returned,
        authorizeUrl: 'https://example.invalid/oauth/authorize?code=synthetic-private-query',
      ),
    );
    await tester.pumpWidget(harness.app(const WishAccountPage()));
    await tester.pumpAndSettle();
    expect(find.text('在浏览器中完成登录'), findsOneWidget);
    expect(find.text('https://example.invalid/oauth/authorize'), findsOneWidget);
    expect(find.textContaining('synthetic-private-query'), findsNothing);
    expect(find.textContaining('还没有收到授权结果'), findsOneWidget);
    expect(find.text('取消登录'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in cancel records the terminal outcome and leaves retry available', (tester) async {
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.running));
    await tester.pumpWidget(harness.app(const WishAccountPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('登录 DeepSeek 账号'));
    await tester.pump();
    await tester.ensureVisible(find.text('取消登录'));
    await tester.tap(find.text('取消登录'));
    await tester.pumpAndSettle();
    expect(harness.account.cancels, 1);
    expect(find.text('登录 DeepSeek 账号'), findsOneWidget);
    expect(harness.analytics.events.where((e) => e.$1 == AnyappEvent.loginResult).single.$2, AnyappOutcome.cancelled);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving a pending login cancels its attempt without using a disposed page', (tester) async {
    final harness = _Harness(const RuntimeStatus(phase: RuntimePhase.running));
    await tester.pumpWidget(harness.app(const WishAccountPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('登录 DeepSeek 账号'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(harness.account.cancels, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired authorization is a visible retry state', (tester) async {
    final harness = _Harness(
      const RuntimeStatus(phase: RuntimePhase.running),
      account: const AccountState(phase: AccountPhase.signedOut, failure: SignInFailure(SignInFailureKind.timeout)),
    );
    await tester.pumpWidget(harness.app(const WishAccountPage(onboarding: true)));
    await tester.pumpAndSettle();
    expect(find.textContaining('登录超时'), findsOneWidget);
    expect(find.text('登录 DeepSeek 账号'), findsOneWidget);
    await tester.ensureVisible(find.text('返回引导'));
    expect(tester.takeException(), isNull);
  });
}

class _Harness {
  _Harness(RuntimeStatus status, {AccountState account = const AccountState(phase: AccountPhase.signedOut)})
    : runtime = _Runtime(status),
      account = _Account(account);
  final _Runtime runtime;
  final _Account account;
  final analytics = _Analytics();
  int activeReads = 0;
  Widget app(Widget home, {bool largeText = false}) => ProviderScope(
    overrides: [
      settingsProvider.overrideWith(_Settings.new),
      localRuntimeProvider.overrideWith(() => runtime),
      runtimeBridgeProvider.overrideWithValue(_StatusBridge(runtime)),
      localConnectionProvider.overrideWith(_Local.new),
      activeConnectionProvider.overrideWith((ref) {
        activeReads++;
        return const AsyncData<HostConnection?>(null);
      }),
      accountProvider.overrideWith(() => account),
      anyappAnalyticsProvider.overrideWith(() => analytics),
      phoneStopWatcherProvider.overrideWith((ref) {}),
      phoneConfirmPendingProvider.overrideWith((ref) {}),
      phoneTurnEndProvider.overrideWith(_TurnEnd.new),
    ],
    child: MaterialApp(
      builder: largeText
          ? (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            )
          : null,
      home: home,
    ),
  );
}

class _Settings extends SettingsController {
  @override
  AppSettings build() => const AppSettings(loaded: true);
}

class _Local extends LocalConnectionController {
  @override
  Future<HostConnection?> build() async => null;
}

class _TurnEnd extends PhoneTurnEndController {
  @override
  void build() {}
}

class _Runtime extends LocalRuntimeController {
  _Runtime(this.initial);
  final RuntimeStatus initial;
  bool failStart = false;
  int starts = 0, installCalls = 0;
  RuntimeStatus get snapshot => state.status;
  @override
  LocalRuntimeState build() => LocalRuntimeState(loaded: true, status: initial);
  @override
  Future<void> start({String? profile}) async {
    starts++;
    if (failStart) throw StateError('synthetic-secret-transport-details');
    state = state.copyWith(
      status: const RuntimeStatus(
        phase: RuntimePhase.running,
        baseUrl: 'http://127.0.0.1:1',
        token: 'synthetic-test-token',
        installedVersion: 'test-runtime',
      ),
    );
  }

  @override
  Future<void> install() async {
    installCalls++;
  }
}

class _Account extends AccountController {
  _Account(this.initial);
  final AccountState initial;
  Completer<SignInResult>? pending;
  int cancels = 0;
  @override
  AccountState build() => initial;
  @override
  Future<void> refreshProfile() async {}
  @override
  void noteAppResumed() {}
  @override
  Future<SignInResult> signIn({Brightness? brightness}) {
    pending = Completer<SignInResult>();
    state = const AccountState(phase: AccountPhase.signingIn, stage: SignInStage.waitingBrowser);
    return pending!.future;
  }

  @override
  Future<void> cancel() async {
    cancels++;
    if (pending != null && !pending!.isCompleted) pending!.complete(SignInResult.cancelled);
    if (ref.mounted) state = const AccountState(phase: AccountPhase.signedOut);
  }
}

class _Analytics extends AnyappAnalytics {
  final events = <(AnyappEvent, AnyappOutcome?)>[];
  @override
  AnyappAnalyticsState build() => const AnyappAnalyticsState(loaded: true);
  @override
  void track(AnyappEvent event, {AnyappPage? page, AnyappOutcome? outcome, Duration? elapsed, AnyappPreset? preset}) {
    events.add((event, outcome));
  }
}

class _StatusBridge extends RuntimeBridge {
  _StatusBridge(this.runtime);
  final _Runtime runtime;
  @override
  Future<RuntimeStatus> status() async => runtime.snapshot;
}
