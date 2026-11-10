import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../analytics/anyapp_analytics.dart';
import 'wish_preset_bootstrap.dart';
import 'wish_palette.dart';
import 'wish_form.dart';
import 'wish_dot_motion.dart';
import 'wish_motion.dart';

/// Keep profile switches inside first-run preparation, before the wall exposes
/// interactive works. A failed attempt keeps its IDs and can be retried.
class WishPresetGate extends StatefulWidget {
  const WishPresetGate({super.key, required this.child});
  final Widget child;
  @override
  State<WishPresetGate> createState() => _WishPresetGateState();
}

class _WishPresetGateState extends State<WishPresetGate> {
  bool _ready = false, _busy = false, _pending = false;
  String? _error, _name;
  int _done = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    AnyappAnalytics? analytics;
    final clock = Stopwatch()..start();
    try {
      if (await WishPresetBootstrap.pending()) {
        if (!mounted) return;
        setState(() => _pending = true);
        final tracker = ProviderScope.containerOf(context, listen: false).read(anyappAnalyticsProvider.notifier);
        analytics = tracker;
        tracker.track(AnyappEvent.onboardingStep, page: AnyappPage.preset, outcome: AnyappOutcome.start);
        await WishPresetBootstrap.run(
          ProviderScope.containerOf(context, listen: false),
          onProgress: (name, done) {
            if (mounted) {
              setState(() {
                _name = name;
                _done = done;
              });
            }
          },
        );
      }
      analytics?.track(
        AnyappEvent.onboardingStep,
        page: AnyappPage.preset,
        outcome: AnyappOutcome.success,
        elapsed: clock.elapsed,
      );
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      analytics?.track(
        AnyappEvent.onboardingStep,
        page: AnyappPage.preset,
        outcome: AnyappOutcome.failure,
        elapsed: clock.elapsed,
      );
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    if (!_pending && _error == null) {
      return Scaffold(
        backgroundColor: wishBg,
        body: Center(child: WishDotLoader(phase: appL10n.wishStarterPreparing)),
      );
    }
    return Scaffold(
      backgroundColor: wishBg,
      bottomNavigationBar: _error == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 492),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _busy ? null : _prepare,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(appL10n.wishRetry),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                ProviderScope.containerOf(context, listen: false)
                                    .read(anyappAnalyticsProvider.notifier)
                                    .track(
                                      AnyappEvent.onboardingSkip,
                                      page: AnyappPage.preset,
                                      outcome: AnyappOutcome.skipped,
                                    );
                                setState(() => _ready = true);
                              },
                        child: Text(appL10n.wishStarterSkip),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: WishEntrance(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 68,
                      child: _busy
                          ? WishDotLoader(size: 60, phase: appL10n.wishStarterPreparing)
                          : const WishDotMark(size: 60),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      appL10n.wishPresetPreparingTitle,
                      style: const TextStyle(
                        fontSize: 27,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.7,
                        color: wishText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      appL10n.wishPresetPreparingHelp,
                      style: const TextStyle(fontSize: 14, height: 1.7, color: wishText2),
                    ),
                    const SizedBox(height: 28),
                    _starter(
                      context,
                      0,
                      'radar',
                      Icons.radar_rounded,
                      appL10n.wishPresetRadar,
                      appL10n.wishPresetRadarHelp,
                    ),
                    const SizedBox(height: 12),
                    _starter(
                      context,
                      1,
                      'pomodoro',
                      Icons.timelapse_rounded,
                      appL10n.wishPresetPomodoro,
                      appL10n.wishPresetPomodoroHelp,
                    ),
                    const SizedBox(height: 22),
                    if (_busy) ...[
                      const LinearProgressIndicator(color: wishBlue, minHeight: 2),
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          appL10n.wishStarterProgress(_done, WishPresetBootstrap.names.length),
                          style: const TextStyle(fontSize: 12, color: wishText2),
                        ),
                      ),
                    ],
                    if (_error != null) ...[Text(_error!, style: const TextStyle(color: wishWarm, height: 1.6))],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _starter(BuildContext context, int index, String name, IconData icon, String title, String description) {
    final ready = index < _done;
    final active = _busy && _name == name;
    final accent = index == 0 ? const Color(0xFFAFC2FF) : const Color(0xFFA7DDC9);
    return AnimatedContainer(
      duration: WishMotion.duration(context, WishMotion.content),
      curve: WishMotion.settle,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: active ? wishSurfaceAlt : wishSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: active ? .35 : .12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: wishText),
                ),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(fontSize: 12, height: 1.6, color: wishText2)),
                const SizedBox(height: 9),
                WishContentTransition(
                  child: Text(
                    ready
                        ? appL10n.wishStarterReady
                        : active
                        ? appL10n.wishStarterPreparing
                        : appL10n.wishStarterNext,
                    key: ValueKey('$name-$ready-$active'),
                    style: TextStyle(fontSize: 11, color: accent),
                  ),
                ),
              ],
            ),
          ),
          if (ready)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.check_circle_rounded, color: accent, size: 20),
            ),
        ],
      ),
    );
  }
}
