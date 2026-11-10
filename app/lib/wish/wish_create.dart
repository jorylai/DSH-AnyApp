import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../analytics/anyapp_analytics.dart';
import '../state/connection_state.dart';
import 'wish_project.dart';
import 'wish_project_page.dart';
import 'wish_form.dart';
import 'wish_account_page.dart';
import 'wish_creation_plan.dart';
import 'wish_creation_service.dart';
import 'wish_home.dart';
import 'wish_material.dart';
import 'wish_dot_motion.dart';
import 'wish_motion.dart';

class WishCreatePage extends ConsumerStatefulWidget {
  const WishCreatePage({super.key, this.initialRequest = '', this.sourceId});
  final String initialRequest;
  final String? sourceId;
  @override
  ConsumerState<WishCreatePage> createState() => _WishCreatePageState();
}

class _WishCreatePageState extends ConsumerState<WishCreatePage> {
  late final _request = TextEditingController(text: widget.initialRequest);
  final _brief = TextEditingController();
  final _scroll = ScrollController();
  final _selected = <WishCreationCapability>{WishCreationCapability.storage};
  final _excluded = <WishCreationCapability>{};
  WishCreationPlan? _plan;
  bool _smart = true, _review = false, _busy = false, _optimizing = false, _pending = false;
  int _revision = 0;
  String? _error, _optimizerError;

  Set<WishCreationCapability> get _effective =>
      {..._selected, if (_smart) ...WishCreationPlanner.suggest(_request.text)}..removeAll(_excluded);

  @override
  void initState() {
    super.initState();
    ref.read(anyappAnalyticsProvider.notifier).track(AnyappEvent.pageView, page: AnyappPage.create);
  }

  @override
  void dispose() {
    _revision++;
    _request.dispose();
    _brief.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _invalidate() {
    _revision++;
    _plan = null;
    _brief.clear();
    _optimizerError = null;
    _error = null;
    _optimizing = false;
  }

  void _toTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _showPlan(WishCreationPlan plan) {
    setState(() {
      _plan = plan;
      // Keep model-added abilities visible and removable when returning to edit.
      _selected.addAll(plan.capabilities);
      _brief.text = plan.brief;
      _review = true;
      _optimizerError = null;
    });
    _toTop();
  }

  Future<void> _optimize({bool regenerate = false}) async {
    if (_busy || _pending || _request.text.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_plan != null && !regenerate) {
      setState(() => _review = true);
      _toTop();
      return;
    }
    final revision = ++_revision;
    final input = _request.text.trim();
    final selected = Set<WishCreationCapability>.of(_effective);
    final excluded = Set<WishCreationCapability>.of(_excluded);
    final smart = _smart;
    setState(() {
      _optimizing = true;
      _pending = true;
      _optimizerError = null;
      _error = null;
    });
    try {
      final plan = await WishCreationPlanner.optimize(
        request: input,
        selected: selected,
        excluded: excluded,
        smart: smart,
        language: AppLocale.current.languageCode,
        complete: ref.read(wishCreationCompleteProvider),
      );
      if (!mounted || revision != _revision) return;
      _showPlan(plan);
    } catch (e) {
      if (mounted && revision == _revision) {
        setState(() => _optimizerError = e is FormatException ? appL10n.wishPlanInvalidResponse : wishErrorText(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _pending = false;
          if (revision == _revision) _optimizing = false;
        });
      }
    }
  }

  void _fallback() {
    FocusManager.instance.primaryFocus?.unfocus();
    _showPlan(
      WishCreationPlanner.fallback(
        request: _request.text.trim(),
        selected: _effective,
        excluded: _excluded,
        smart: _smart,
        language: AppLocale.current.languageCode,
      ),
    );
  }

  Future<void> _start({bool direct = false}) async {
    final request = _request.text.trim();
    if (_busy || _pending || request.isEmpty || (!direct && _brief.text.trim().isEmpty)) return;
    final submission = WishCreationSubmission(
      request: request,
      creationPlan: direct ? null : _brief.text.trim(),
      capabilities: direct ? _effective : _plan!.capabilities,
      excluded: _excluded,
      smart: _smart,
      sourceId: widget.sourceId,
    );
    unawaited(HapticFeedback.mediumImpact());
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final analytics = ref.read(anyappAnalyticsProvider.notifier);
    final timer = Stopwatch()..start();
    var resultNoted = false;
    analytics.track(AnyappEvent.creatorStart, page: AnyappPage.create, outcome: AnyappOutcome.start);
    try {
      final result = await ref.read(wishCreationStarterProvider)(ref, submission);
      if (!mounted) return;
      analytics.track(
        AnyappEvent.creatorResult,
        page: AnyappPage.create,
        outcome: result.error == null ? AnyappOutcome.success : AnyappOutcome.failure,
        elapsed: timer.elapsed,
      );
      resultNoted = true;
      final client = ref.read(activeConnectionProvider).value!.client;
      final projects = await client.rpc.call('wishMobile/projects') as List;
      final project = WishProject(wishMap(projects.firstWhere((p) => p['id'] == result.formId)));
      if (!mounted) return;
      unawaited(HapticFeedback.lightImpact());
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WishProjectPage(project: project, creator: true, startupError: result.error),
        ),
      );
    } catch (e) {
      if (!resultNoted) {
        analytics.track(
          AnyappEvent.creatorResult,
          page: AnyappPage.create,
          outcome: AnyappOutcome.failure,
          elapsed: timer.elapsed,
        );
      }
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _label(WishCreationCapability c) => switch (c) {
    WishCreationCapability.ai => appL10n.wishAi,
    WishCreationCapability.camera => appL10n.wishCamera,
    WishCreationCapability.phone => appL10n.wishPhone,
    WishCreationCapability.storage => appL10n.wishLocalData,
    WishCreationCapability.reminders => appL10n.wishPlanReminders,
    WishCreationCapability.overlay => appL10n.wishPlanOverlay,
    WishCreationCapability.calendar => appL10n.wishPlanCalendar,
    WishCreationCapability.location => appL10n.wishPlanLocation,
    WishCreationCapability.files => appL10n.wishPlanFiles,
    WishCreationCapability.voice => appL10n.wishPlanVoice,
    WishCreationCapability.notifications => appL10n.wishPlanNotifications,
    WishCreationCapability.share => appL10n.wishPlanShare,
    WishCreationCapability.entries => appL10n.wishPlanEntries,
  };

  Widget _capabilities(Iterable<WishCreationCapability> items, {bool editable = true}) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final c in items)
        if (!editable)
          Chip(
            key: ValueKey('capability-${c.name}'),
            avatar: const Icon(Icons.check_rounded, size: 18, color: wishText2),
            label: Text(_label(c), style: const TextStyle(color: wishText)),
            backgroundColor: wishBlue.withValues(alpha: .22),
            side: const BorderSide(color: Color(0x3DAFBDFF)),
          )
        else
          FilterChip(
            key: ValueKey('capability-${c.name}'),
            label: Text(_label(c)),
            selected: _effective.contains(c),
            onSelected: _busy || _optimizing
                ? null
                : (v) => setState(() {
                    _invalidate();
                    if (v) {
                      _selected.add(c);
                      _excluded.remove(c);
                    } else {
                      _selected.remove(c);
                      _excluded.add(c);
                    }
                  }),
          ),
    ],
  );

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(18)}) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1C2946), wishSurface],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0x2DFFFFFF)),
    ),
    padding: padding,
    child: child,
  );

  Widget _example(String title, String hint, String prompt, IconData icon, Color accent) => WishPressable(
    enabled: !_busy && !_optimizing,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _busy || _optimizing
            ? null
            : () => setState(() {
                _request.text = prompt;
                _invalidate();
              }),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: .18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 24),
                  const Spacer(),
                  Icon(Icons.north_east_rounded, color: accent.withValues(alpha: .7), size: 15),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(color: wishText, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(hint, style: const TextStyle(color: wishText3, fontSize: 12, height: 1.5)),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _input({bool editing = false, double? editorHeight}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Offstage(
        offstage: editing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appL10n.wishNewEyebrow,
                    style: const TextStyle(
                      color: Color(0xFFAFBDFF),
                      fontSize: 10,
                      letterSpacing: 2.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const WishDotMark(size: 36),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appL10n.wishNewTitle,
              style: const TextStyle(
                fontSize: 30,
                height: 1.22,
                letterSpacing: -.7,
                fontWeight: FontWeight.w500,
                color: wishText,
              ),
            ),
            const SizedBox(height: 14),
            Text(appL10n.wishPlanIntro, style: const TextStyle(fontSize: 14, color: wishText2, height: 1.6)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      SizedBox(
        height: editing ? editorHeight : null,
        child: _card(
          padding: const EdgeInsets.all(4),
          child: TextField(
            key: const ValueKey('creation-request'),
            controller: _request,
            enabled: !_busy && !_optimizing,
            minLines: editing ? null : 3,
            maxLines: editing ? null : 6,
            expands: editing,
            textAlignVertical: TextAlignVertical.top,
            maxLength: 10000,
            onChanged: (_) => setState(_invalidate),
            style: const TextStyle(fontSize: 17, height: 1.6),
            decoration: InputDecoration(
              hintText: appL10n.wishNewHint,
              hintStyle: const TextStyle(fontSize: 15, color: wishText3, height: 1.6),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
              counterText: '',
            ),
          ),
        ),
      ),
      Offstage(
        offstage: editing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _example(
                    appL10n.wishIdeaMeditate,
                    appL10n.wishIdeaMeditateHint,
                    appL10n.wishIdeaMeditatePrompt,
                    Icons.self_improvement_rounded,
                    const Color(0xFFA7DDC9),
                  ),
                  _example(
                    appL10n.wishIdeaPomodoro,
                    appL10n.wishIdeaPomodoroHint,
                    appL10n.wishIdeaPomodoroPrompt,
                    Icons.timelapse_rounded,
                    const Color(0xFFD7BB83),
                  ),
                ];
                if (constraints.maxWidth < 300 || MediaQuery.textScalerOf(context).scale(14) > 20) {
                  return Column(children: [cards[0], const SizedBox(height: 10), cards[1]]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 10),
                    Expanded(child: cards[1]),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(appL10n.wishPlanCapabilities, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SwitchListTile.adaptive(
                key: const ValueKey('creation-smart'),
                contentPadding: EdgeInsets.zero,
                title: Text(appL10n.wishPlanSmart),
                subtitle: Text(appL10n.wishPlanSmartHint, style: const TextStyle(fontSize: 12, color: wishText2)),
                value: _smart,
                onChanged: _busy || _optimizing
                    ? null
                    : (v) => setState(() {
                        final current = _effective;
                        _invalidate();
                        _selected.addAll(current);
                        _smart = v;
                      }),
              ),
            ),
            const SizedBox(height: 12),
            _capabilities(WishCreationCapability.values.take(6)),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(appL10n.wishPlanMoreCapabilities, style: const TextStyle(fontSize: 13, color: wishText2)),
              children: [
                Align(alignment: Alignment.centerLeft, child: _capabilities(WishCreationCapability.values.skip(6))),
                const SizedBox(height: 12),
              ],
            ),
            const SizedBox(height: 8),
            Text(appL10n.wishPlanCapabilityHint, style: const TextStyle(fontSize: 12, color: wishText3, height: 1.6)),
            if (_optimizerError != null) ...[
              const SizedBox(height: 20),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appL10n.wishPlanFailed, style: const TextStyle(color: wishWarm)),
                    const SizedBox(height: 8),
                    Text(_optimizerError!, style: const TextStyle(color: wishText2)),
                    const SizedBox(height: 10),
                    TextButton(onPressed: _fallback, child: Text(appL10n.wishPlanUseLocal)),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WishAccountPage())),
                      child: Text(appL10n.wishCreatorModelSettings),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _preview({bool editing = false, double? editorHeight}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Offstage(
        offstage: editing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 19, color: Color(0xFFAFBDFF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _plan!.fromAi ? appL10n.wishPlanAiReady : appL10n.wishPlanLocalReady,
                    style: const TextStyle(color: Color(0xFFAFBDFF), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              appL10n.wishPlanReviewTitle,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500, letterSpacing: -.6, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(appL10n.wishPlanReviewHint, style: const TextStyle(fontSize: 14, color: wishText2, height: 1.6)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      SizedBox(
        height: editing ? editorHeight : null,
        child: _card(
          padding: const EdgeInsets.all(4),
          child: TextField(
            key: const ValueKey('creation-brief'),
            controller: _brief,
            enabled: !_busy && !_optimizing,
            minLines: editing ? null : 8,
            maxLines: editing ? null : 18,
            expands: editing,
            textAlignVertical: TextAlignVertical.top,
            maxLength: 12000,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 15, height: 1.65),
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterText: '',
            ),
          ),
        ),
      ),
      Offstage(
        offstage: editing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Text(appL10n.wishPlanAppliedCapabilities, style: const TextStyle(fontSize: 14, color: wishText2)),
            const SizedBox(height: 10),
            if (_plan!.capabilities.isNotEmpty)
              _capabilities(_plan!.capabilities, editable: false)
            else
              Text(appL10n.wishPlanNoCapabilities, style: const TextStyle(color: wishText3)),
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      setState(() => _review = false);
                      _toTop();
                    },
              child: Text(appL10n.wishPlanAdjust),
            ),
            if (_plan!.assumptions.isNotEmpty) ...[
              const SizedBox(height: 10),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appL10n.wishPlanAssumptions, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    for (final assumption in _plan!.assumptions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '· $assumption',
                          style: const TextStyle(fontSize: 13, color: wishText2, height: 1.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(appL10n.wishPlanOriginal),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText(
                    _request.text,
                    style: const TextStyle(fontSize: 14, color: wishText2, height: 1.6),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
            Text(appL10n.wishPlanCapabilityHint, style: const TextStyle(fontSize: 12, color: wishText3, height: 1.6)),
          ],
        ),
      ),
    ],
  );

  String get _actionLabel => _busy
      ? appL10n.wishPreparing
      : _optimizing
      ? appL10n.wishPlanOptimizing
      : _pending
      ? appL10n.wishPlanWaiting
      : _review
      ? appL10n.wishPlanStart
      : _plan != null
      ? appL10n.wishPlanView
      : appL10n.wishPlanOptimize;

  VoidCallback? get _primaryAction =>
      _busy || _pending || _request.text.trim().isEmpty || (_review && _brief.text.trim().isEmpty)
      ? null
      : _review
      ? () => _start()
      : _optimize;

  @override
  Widget build(BuildContext context) {
    final editing = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      canPop: !_busy && !_review,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy && _review) {
          setState(() => _review = false);
          _toTop();
        }
      },
      child: Scaffold(
        backgroundColor: wishBg,
        appBar: AppBar(
          title: Text(_review ? appL10n.wishPlanReviewBar : appL10n.wishCreate),
          leading: _review
              ? BackButton(
                  onPressed: _busy
                      ? null
                      : () {
                          setState(() => _review = false);
                          _toTop();
                        },
                )
              : null,
        ),
        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    WishEntrance(
                      key: ValueKey(('creation-step', _review)),
                      child: _review
                          ? _preview(
                              editing: editing,
                              editorHeight: (constraints.maxHeight - 40).clamp(80.0, double.infinity),
                            )
                          : _input(
                              editing: editing,
                              editorHeight: (constraints.maxHeight - 40).clamp(80.0, double.infinity),
                            ),
                    ),
                    if (_review && _optimizerError != null) ...[
                      const SizedBox(height: 16),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appL10n.wishPlanKeptDraft, style: const TextStyle(color: wishWarm)),
                            const SizedBox(height: 8),
                            Text(_optimizerError!, style: const TextStyle(color: wishText2)),
                          ],
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 20),
                      Text(_error!, style: const TextStyle(color: wishWarm)),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context)
                                .push(MaterialPageRoute<void>(builder: (_) => const WishAccountPage())),
                        child: Text(appL10n.wishCreatorModelSettings),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, editing ? 6 : 10, 24, editing ? 6 : 10),
                child: editing
                    ? Row(
                        children: [
                          IconButton(
                            key: const ValueKey('creation-hide-keyboard'),
                            tooltip: appL10n.wishPlanHideKeyboard,
                            icon: const Icon(Icons.keyboard_hide_outlined),
                            onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              key: const ValueKey('creation-compact-submit'),
                              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                              onPressed: _primaryAction,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text(_actionLabel),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WishRitualButton(label: _actionLabel, busy: _busy || _optimizing, onPressed: _primaryAction),
                          if (!_busy && !_review)
                            TextButton(
                              onPressed: _optimizing
                                  ? () => setState(() {
                                      _revision++;
                                      _optimizing = false;
                                    })
                                  : _pending || _request.text.trim().isEmpty
                                  ? null
                                  : () => _start(direct: true),
                              child: Text(_optimizing ? appL10n.wishPlanStopWaiting : appL10n.wishPlanDirect),
                            ),
                          if (!_busy && _review && MediaQuery.viewInsetsOf(context).bottom == 0)
                            TextButton(
                              onPressed: _pending ? null : () => _optimize(regenerate: true),
                              child: Text(appL10n.wishPlanRegenerate),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
