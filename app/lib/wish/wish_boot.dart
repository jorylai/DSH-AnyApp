import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/anyapp_analytics.dart';
import '../analytics/anyapp_analytics_ui.dart';
import '../l10n/l10n.dart';
import '../runtime/runtime_bridge.dart';
import '../runtime/runtime_state.dart';
import '../state/account_state.dart';
import '../state/engine_control.dart';
import '../state/settings_state.dart';
import '../ui/phone/phone_stop_watcher.dart';
import 'wish_account_page.dart';
import 'wish_home.dart';
import 'wish_dot_motion.dart';
import 'wish_motion.dart';
import 'wish_material.dart';
import 'wish_setup_guide.dart';
import 'wish_preset_bootstrap.dart';
import 'wish_preset_gate.dart';

/// AnyApp owns onboarding and navigation; the shared DSH engine owns OAuth.
class WishBootPage extends ConsumerStatefulWidget {
  const WishBootPage({super.key});
  @override
  ConsumerState<WishBootPage> createState() => _WishBootPageState();
}

class _WishBootPageState extends ConsumerState<WishBootPage> {
  bool _startRequested = false, _flagsLoaded = false, _runtimeDeferred = false, _savingFlag = false;
  bool _welcomeSeen = false, _wantsDone = false, _permissionsDone = false, _connectSkipped = false;
  AnyappPage? _lastPage;

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  void _track(AnyappEvent event, AnyappPage page, AnyappOutcome outcome) {
    ref.read(anyappAnalyticsProvider.notifier).track(event, page: page, outcome: outcome);
  }

  Widget _screen(AnyappPage page, Widget child) {
    if (_lastPage != page) {
      _lastPage = page;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _track(AnyappEvent.onboardingStep, page, AnyappOutcome.start);
      });
    }
    // Keep the navigation frame still. Each onboarding section owns a small,
    // finite arrival instead of fading and translating the whole screen.
    return KeyedSubtree(key: ValueKey(page), child: child);
  }

  Future<void> _loadFlags() async {
    // Record eligibility before onboarding creates the local runtime.
    try {
      await WishPresetBootstrap.initialize();
    } catch (_) {
      /* The preset gate owns retry. */
    }
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _welcomeSeen = p.getBool('wish.onboard.welcome') ?? false;
      _wantsDone = p.getBool('wish.onboard.wants') ?? false;
      _permissionsDone = p.getBool('wish.onboard.permissions') ?? false;
      _connectSkipped = p.getBool('wish.onboard.connect_skipped') ?? false;
      _flagsLoaded = true;
    });
  }

  Future<void> _setFlag(String key, AnyappPage page, {bool skipped = false}) async {
    if (_savingFlag) return;
    _savingFlag = true;
    try {
      final p = await SharedPreferences.getInstance();
      if (!await p.setBool(key, true)) throw StateError('onboarding-state-not-saved');
      if (!mounted) return;
      _track(
        skipped ? AnyappEvent.onboardingSkip : AnyappEvent.onboardingContinue,
        page,
        skipped ? AnyappOutcome.skipped : AnyappOutcome.success,
      );
      setState(() {
        if (key == 'wish.onboard.welcome') _welcomeSeen = true;
        if (key == 'wish.onboard.wants') _wantsDone = true;
        if (key == 'wish.onboard.permissions') _permissionsDone = true;
        if (key == 'wish.onboard.connect_skipped') _connectSkipped = true;
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appL10n.wishFailure)));
    } finally {
      _savingFlag = false;
    }
  }

  void _deferRuntime() {
    _track(AnyappEvent.onboardingSkip, AnyappPage.runtime, AnyappOutcome.skipped);
    setState(() => _runtimeDeferred = true);
    // This is temporary: next launch offers setup again, without marking
    // runtime, permissions, login or bundled apps complete.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appL10n.anyOnboardRuntimeDeferred)));
  }

  void _requestEngine(ProviderContainer container) {
    if (_startRequested) return;
    _startRequested = true;
    unawaited(
      Future<void>.microtask(() async {
        if (!mounted) return;
        try {
          await EngineControl.ensureStarted(container);
        } catch (_) {
          // Native runtime state and the account page expose retry. Do not loop
          // automatic restarts or display raw transport/credential errors.
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final runtime = ref.watch(localRuntimeProvider);
    if (!_flagsLoaded || !settings.loaded || !runtime.loaded) return const _Splash();
    if (_runtimeDeferred) return const PhoneStopWatcher(child: WishHomePage());
    if (!_welcomeSeen) {
      return _screen(
        AnyappPage.welcome,
        _WelcomeGate(onStart: () => _setFlag('wish.onboard.welcome', AnyappPage.welcome)),
      );
    }
    final phase = runtime.status.phase;
    if ({RuntimePhase.starting, RuntimePhase.running, RuntimePhase.stopping}.contains(phase)) {
      _startRequested = true;
    }
    if (phase == RuntimePhase.notInstalled || phase == RuntimePhase.error) {
      return _screen(AnyappPage.runtime, _RuntimeGate(runtime: runtime, onSkip: _deferRuntime));
    }
    if (phase == RuntimePhase.installing) return _screen(AnyappPage.runtime, _Installing(runtime: runtime));
    if (!_wantsDone) {
      return _screen(
        AnyappPage.capabilities,
        _CapabilitiesGate(onDone: () => _setFlag('wish.onboard.wants', AnyappPage.capabilities)),
      );
    }
    if (!_permissionsDone) {
      return _screen(
        AnyappPage.permissions,
        WishSetupGuidePage(
          onboarding: true,
          onDone: () => _setFlag('wish.onboard.permissions', AnyappPage.permissions),
          onSkip: () => _setFlag('wish.onboard.permissions', AnyappPage.permissions, skipped: true),
        ),
      );
    }
    final account = ref.watch(accountProvider);
    if (phase == RuntimePhase.installed) _requestEngine(ProviderScope.containerOf(context, listen: false));
    if (!settings.hasModelAccess && !account.signedIn && !_connectSkipped) {
      return _screen(
        AnyappPage.login,
        _ConnectGate(onSkip: () => _setFlag('wish.onboard.connect_skipped', AnyappPage.login, skipped: true)),
      );
    }
    return const WishPresetGate(child: PhoneStopWatcher(child: WishHomePage()));
  }
}

class _WelcomeGate extends StatelessWidget {
  const _WelcomeGate({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => _OnbScaffold(
    step: 1,
    total: 4,
    title: appL10n.anyWelcomeTitle,
    body: appL10n.anyWelcomeBody,
    primary: appL10n.anyWelcomeStart,
    onPrimary: onStart,
    custom: Column(
      children: [
        _CapabilityRow(
          icon: Icons.radar_rounded,
          title: appL10n.anyWelcomeRadarTitle,
          help: appL10n.anyWelcomeRadarHelp,
        ),
        const SizedBox(height: 10),
        _CapabilityRow(
          icon: Icons.timelapse_rounded,
          title: appL10n.anyWelcomeFocusTitle,
          help: appL10n.anyWelcomeFocusHelp,
        ),
        const SizedBox(height: 16),
        const AnyappAnalyticsNotice(page: AnyappPage.welcome),
      ],
    ),
    footnote: appL10n.anyWelcomeNext,
  );
}

class _CapabilitiesGate extends StatelessWidget {
  const _CapabilitiesGate({required this.onDone});
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) => _OnbScaffold(
    step: 2,
    total: 4,
    title: appL10n.anyWelcomeAbilitiesTitle,
    body: appL10n.anyWelcomeAbilitiesBody,
    primary: appL10n.anyOnboardContinue,
    onPrimary: onDone,
    custom: Column(
      children: [
        for (final item in [
          (Icons.bubble_chart_outlined, appL10n.anyWelcomeOverlayTitle, appL10n.anyWelcomeOverlayHelp),
          (Icons.event_available_outlined, appL10n.anyWelcomeReminderTitle, appL10n.anyWelcomeReminderHelp),
          (Icons.touch_app_outlined, appL10n.anyWelcomePhoneTitle, appL10n.anyWelcomePhoneHelp),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CapabilityRow(icon: item.$1, title: item.$2, help: item.$3),
          ),
      ],
    ),
    footnote: appL10n.anyWelcomeAbilitiesFootnote,
  );
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.icon, required this.title, required this.help});
  final IconData icon;
  final String title, help;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: wishSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0x1FFFFFFF)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: wishBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: wishText, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(help, style: const TextStyle(color: wishText2, fontSize: 13, height: 1.55)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: wishBg,
    body: Center(child: WishDotLoader(size: 104)),
  );
}

class _RuntimeGate extends ConsumerStatefulWidget {
  const _RuntimeGate({required this.runtime, required this.onSkip});
  final LocalRuntimeState runtime;
  final VoidCallback onSkip;
  @override
  ConsumerState<_RuntimeGate> createState() => _RuntimeGateState();
}

class _RuntimeGateState extends ConsumerState<_RuntimeGate> {
  bool _busy = false;
  String? _error;
  Future<void> _install() async {
    if (_busy) return;
    final analytics = ref.read(anyappAnalyticsProvider.notifier);
    final container = ProviderScope.containerOf(context, listen: false);
    final bridge = container.read(runtimeBridgeProvider);
    final restarting = widget.runtime.status.installedVersion != null;
    final event = restarting ? AnyappEvent.onboardingContinue : AnyappEvent.runtimeInstall;
    final clock = Stopwatch()..start();
    analytics.track(event, page: AnyappPage.runtime, outcome: AnyappOutcome.start);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (restarting) {
        await EngineControl.ensureStarted(container);
      } else {
        await ref.read(localRuntimeProvider.notifier).install();
      }
      var observed = await bridge.status();
      if (restarting) {
        final deadline = DateTime.now().add(const Duration(seconds: 90));
        while (observed.phase == RuntimePhase.starting && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          observed = await bridge.status();
        }
        if (!observed.isRunning) throw StateError('runtime-start-incomplete');
      } else if (observed.installedVersion == null ||
          !{RuntimePhase.installed, RuntimePhase.starting, RuntimePhase.running}.contains(observed.phase)) {
        throw StateError('runtime-install-incomplete');
      }
      analytics.track(event, page: AnyappPage.runtime, outcome: AnyappOutcome.success, elapsed: clock.elapsed);
    } catch (_) {
      analytics.track(event, page: AnyappPage.runtime, outcome: AnyappOutcome.failure, elapsed: clock.elapsed);
      if (mounted) setState(() => _error = appL10n.anyOnboardRuntimeFailure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final failed = widget.runtime.status.phase == RuntimePhase.error;
    final installed = widget.runtime.status.installedVersion != null;
    return _OnbScaffold(
      step: 1,
      total: 4,
      title: failed
          ? installed
                ? appL10n.anyOnboardRuntimeStartFailed
                : appL10n.anyOnboardRuntimeInstallFailed
          : appL10n.anyWelcomeRuntimeTitle,
      body: appL10n.anyWelcomeRuntimeBody,
      primary: installed
          ? appL10n.anyOnboardRuntimeRestart
          : failed
          ? appL10n.anyOnboardRuntimeRetry
          : appL10n.anyWelcomeRuntimeStart,
      busy: _busy,
      onPrimary: _busy ? null : _install,
      secondary: appL10n.anyOnboardRuntimeLater,
      onSecondary: _busy ? null : widget.onSkip,
      footnote: _error ?? appL10n.anyOnboardRuntimeKeepForeground,
    );
  }
}

class _Installing extends StatelessWidget {
  const _Installing({required this.runtime});
  final LocalRuntimeState runtime;
  @override
  Widget build(BuildContext context) {
    final fraction = runtime.progress?.fraction ?? 0;
    return _OnbScaffold(
      step: 1,
      total: 4,
      title: appL10n.anyWelcomeRuntimeInstalling,
      body: appL10n.anyWelcomeRuntimeProgress,
      primary: null,
      onPrimary: null,
      custom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fraction <= 0 && WishMotion.reduced(context))
            const SizedBox(
              width: double.infinity,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(color: wishSurfaceAlt, borderRadius: BorderRadius.all(Radius.circular(3))),
              ),
            )
          else
            LinearProgressIndicator(
              value: fraction <= 0 ? null : fraction.clamp(0, 1),
              minHeight: 6,
              backgroundColor: wishSurfaceAlt,
              color: wishBlue,
            ),
          const SizedBox(height: 12),
          if (fraction > 0) Text('${(fraction.clamp(0, 1) * 100).round()}%', style: const TextStyle(color: wishText2)),
        ],
      ),
      footnote: appL10n.anyOnboardRuntimeKeepForeground,
    );
  }
}

class _ConnectGate extends ConsumerWidget {
  const _ConnectGate({required this.onSkip});
  final VoidCallback onSkip;
  @override
  Widget build(BuildContext context, WidgetRef ref) => _OnbScaffold(
    step: 4,
    total: 4,
    title: appL10n.anyWelcomeLoginTitle,
    body: appL10n.anyWelcomeLoginBody,
    primary: appL10n.wishAccountSignIn,
    onPrimary: () {
      ref
          .read(anyappAnalyticsProvider.notifier)
          .track(AnyappEvent.onboardingContinue, page: AnyappPage.login, outcome: AnyappOutcome.start);
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WishAccountPage(onboarding: true)));
    },
    secondary: appL10n.anyWelcomeLoginLater,
    onSecondary: onSkip,
    footnote: appL10n.anyOnboardLoginFootnote,
  );
}

class _OnbScaffold extends StatelessWidget {
  const _OnbScaffold({
    required this.step,
    required this.total,
    required this.title,
    required this.body,
    required this.primary,
    required this.onPrimary,
    this.secondary,
    this.onSecondary,
    this.footnote,
    this.custom,
    this.busy = false,
  });
  final int step, total;
  final String title, body;
  final String? primary, secondary, footnote;
  final VoidCallback? onPrimary, onSecondary;
  final Widget? custom;
  final bool busy;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: wishBg,
    body: Stack(
      children: [
        if (!(MediaQuery.maybeHighContrastOf(context) ?? false))
          const Positioned(
            top: 60,
            right: -70,
            child: IgnorePointer(
              child: SizedBox.square(
                dimension: 300,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: RadialGradient(colors: [Color(0x124D6BFE), Color(0x004D6BFE)])),
                ),
              ),
            ),
          ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480, minHeight: math.max(0, constraints.maxHeight - 38)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OnboardingHeader(step: step, total: total),
                          SizedBox(height: constraints.maxHeight < 650 ? 28 : 40),
                          WishEntrance(key: ValueKey('onboarding-emblem-$step'), child: const _OnboardingEmblem()),
                          const SizedBox(height: 24),
                          WishEntrance(
                            order: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  key: const ValueKey('onboarding-title'),
                                  style: const TextStyle(
                                    color: wishText,
                                    fontSize: 32,
                                    height: 1.22,
                                    letterSpacing: -.8,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(body, style: const TextStyle(color: wishText2, fontSize: 14, height: 1.65)),
                              ],
                            ),
                          ),
                          if (custom != null) ...[const SizedBox(height: 26), WishEntrance(order: 2, child: custom!)],
                          const SizedBox(height: 32),
                        ],
                      ),
                      WishEntrance(
                        order: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (primary != null) WishRitualButton(label: primary!, busy: busy, onPressed: onPrimary),
                            if (secondary != null) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: busy ? null : onSecondary,
                                child: Text(
                                  secondary!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: wishText2, fontSize: 13),
                                ),
                              ),
                            ],
                            if (footnote != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                footnote!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: wishText2, fontSize: 12, height: 1.6),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Progress stays anchored while the explanatory content arrives below it.
class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.step, required this.total});
  final int step, total;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'DSH AnyApp',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: wishText2, fontSize: 13, letterSpacing: .2, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Text('$step / $total', style: const TextStyle(color: wishText3, fontSize: 12)),
        ],
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: AnimatedContainer(
                duration: WishMotion.duration(context, WishMotion.content),
                curve: WishMotion.settle,
                height: 2,
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: i < step ? const Color(0xFF8CA0FF) : wishSurfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

/// One quiet brand mark, without a second illustration competing beside it.
class _OnboardingEmblem extends StatelessWidget {
  const _OnboardingEmblem();

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 84, height: 84, child: WishDotMark(key: ValueKey('onboarding-brand-mark'), size: 76));
}
