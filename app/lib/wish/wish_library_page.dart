import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/anyapp_analytics.dart';
import '../l10n/l10n.dart';
import 'wish_create.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_glass.dart';
import 'wish_home.dart';
import 'wish_material.dart';
import 'wish_motion.dart';
import 'wish_plugin_package.dart';
import 'wish_package_identity.dart';
import 'wish_preset_installer.dart';
import 'wish_project_page.dart';
import 'wish_ui.dart';

/// Shared bundles are installed into a new work/profile, never over an existing work.
class WishLibraryPage extends ConsumerStatefulWidget {
  const WishLibraryPage({super.key});
  @override
  ConsumerState<WishLibraryPage> createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<WishLibraryPage> {
  Map<String, dynamic>? _package;
  String? _error;
  WishPackageInstallState? _installState;
  WishInstallStage? _stage;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(anyappAnalyticsProvider.notifier).track(AnyappEvent.pageView, page: AnyappPage.library);
  }

  Future<void> _run(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await fn();
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() => _run(() async {
    final raw = await WishDevice.call('files.pick', work: 'local-library', args: {'mime': '*/*'});
    if (raw == null || !mounted) return;
    final value = wishMap(raw);
    setState(() {
      _package = null;
      _installState = null;
      _stage = null;
    });
    if (value['data'] is! String) throw const FormatException('release-incompatible-format');
    final selected = WishPluginPackage.decode(base64Decode(value['data'] as String));
    setState(() {
      _package = selected;
      _installState = null;
      _stage = null;
    });
    // Selecting the file is the import action. No second confirmation button.
    await _installSelected();
  });

  Future<void> _retry() => _run(_installSelected);

  Future<void> _installSelected() async {
    if (_package == null) return;
    final analytics = ref.read(anyappAnalyticsProvider.notifier);
    final timer = Stopwatch()..start();
    var resultNoted = false;
    analytics.track(
      AnyappEvent.presetInstall,
      page: AnyappPage.library,
      preset: AnyappPreset.imported,
      outcome: AnyappOutcome.start,
    );
    try {
      final state = _installState ??= WishPackageInstallState.initial(_package!);
      final project = await WishPresetInstaller.install(
        ProviderScope.containerOf(context, listen: false),
        _package!,
        state: state,
        save: (next) async => _installState = next,
        onStage: (stage) {
          if (mounted) setState(() => _stage = stage);
        },
      );
      analytics.track(
        AnyappEvent.presetResult,
        page: AnyappPage.library,
        preset: AnyappPreset.imported,
        outcome: AnyappOutcome.success,
        elapsed: timer.elapsed,
      );
      resultNoted = true;
      if (!mounted) return;
      await Navigator.of(context)
          .pushReplacement(MaterialPageRoute<void>(builder: (_) => WishProjectPage(project: project)));
    } catch (_) {
      if (!resultNoted) {
        analytics.track(
          AnyappEvent.presetResult,
          page: AnyappPage.library,
          preset: AnyappPreset.imported,
          outcome: AnyappOutcome.failure,
          elapsed: timer.elapsed,
        );
      }
      rethrow;
    }
  }

  String get _progress => switch (_stage) {
    null => _package == null ? appL10n.anyappGuideImportPicking : appL10n.anyappGuideImportPreparing,
    WishInstallStage.allocated || WishInstallStage.created => appL10n.anyappGuideImportPreparing,
    WishInstallStage.imported => appL10n.anyappGuideImportAdding,
    WishInstallStage.installed || WishInstallStage.reloaded => appL10n.anyappGuideImportConnecting,
    WishInstallStage.published => appL10n.anyappGuideImportOpening,
  };

  void _create([String request = '']) {
    if (_busy) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WishCreatePage(initialRequest: request)));
  }

  Widget _importCard() => WishGlassSurface(
    radius: 22,
    tint: const Color(0xFFADBCD9),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_open_outlined, size: 23, color: wishText2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appL10n.anyappGuideImportTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: wishText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(appL10n.anyappGuideImportBody, style: const TextStyle(fontSize: 13, height: 1.6, color: wishText2)),
          if (_package != null && (_busy || _error != null)) ...[
            const SizedBox(height: 14),
            Text(
              WishPackageIdentity.resolve(_package!).title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: wishText, fontWeight: FontWeight.w500),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 14),
            Semantics(
              liveRegion: true,
              child: Text(_progress, style: const TextStyle(fontSize: 13, color: wishText2)),
            ),
            const SizedBox(height: 9),
            const LinearProgressIndicator(minHeight: 2, borderRadius: BorderRadius.all(Radius.circular(2))),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            if (_package != null)
              Text(
                appL10n.anyappGuideImportRecovery,
                style: const TextStyle(fontSize: 13, height: 1.6, color: wishText2),
              ),
            const SizedBox(height: 6),
            Semantics(
              liveRegion: true,
              child: Text(_error!, style: const TextStyle(fontSize: 12, height: 1.5, color: wishWarm)),
            ),
          ],
          if (!_busy) ...[
            const SizedBox(height: 14),
            if (_error != null && _package != null) ...[
              FilledButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: Text(appL10n.anyappGuideImportRetry),
              ),
              const SizedBox(height: 6),
            ],
            OutlinedButton.icon(
              key: const ValueKey('library-import'),
              onPressed: _pick,
              icon: const Icon(Icons.add_rounded, size: 19),
              label: Text(
                _error != null && _package != null
                    ? appL10n.anyappGuideImportDifferent
                    : appL10n.anyappGuideImportAction,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: WishPage(
      glass: true,
      title: appL10n.anyappGuideTitle,
      children: [
        WishEntrance(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appL10n.anyappGuideHeadline,
                  style: const TextStyle(fontSize: 27, height: 1.35, fontWeight: FontWeight.w600, letterSpacing: -.6),
                ),
                const SizedBox(height: 12),
                Text(appL10n.anyappGuideIntro, style: const TextStyle(fontSize: 14, height: 1.65, color: wishText2)),
                const SizedBox(height: 19),
                WishRitualButton(label: appL10n.anyappGuideCreate, onPressed: _busy ? null : _create),
              ],
            ),
          ),
        ),
        _importCard(),
        const SizedBox(height: 28),
        Text(appL10n.anyappGuideExamples, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _IdeaRow(
          icon: Icons.radar_rounded,
          tint: const Color(0xFFAFC2FF),
          title: appL10n.anyappGuideShopTitle,
          body: appL10n.anyappGuideShopBody,
          onTap: _busy ? null : () => _create(appL10n.anyappGuideShopPrompt),
        ),
        const SizedBox(height: 10),
        _IdeaRow(
          icon: Icons.timelapse_rounded,
          tint: const Color(0xFFA7DDC9),
          title: appL10n.anyappGuideFocusTitle,
          body: appL10n.anyappGuideFocusBody,
          onTap: _busy ? null : () => _create(appL10n.anyappGuideFocusPrompt),
        ),
        const SizedBox(height: 10),
        _IdeaRow(
          icon: Icons.auto_awesome_mosaic_outlined,
          tint: const Color(0xFFD0B7E7),
          title: appL10n.anyappGuideNoteTitle,
          body: appL10n.anyappGuideNoteBody,
          onTap: _busy ? null : () => _create(appL10n.anyappGuideNotePrompt),
        ),
        const SizedBox(height: 28),
        Text(appL10n.anyappGuideStepsTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _GuideStep(number: '01', title: appL10n.anyappGuideStepOneTitle, body: appL10n.anyappGuideStepOneBody),
        _GuideStep(number: '02', title: appL10n.anyappGuideStepTwoTitle, body: appL10n.anyappGuideStepTwoBody),
        _GuideStep(number: '03', title: appL10n.anyappGuideStepThreeTitle, body: appL10n.anyappGuideStepThreeBody),
      ],
    ),
  );
}

class _IdeaRow extends StatelessWidget {
  const _IdeaRow({required this.icon, required this.tint, required this.title, required this.body, this.onTap});
  final IconData icon;
  final Color tint;
  final String title, body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => WishPressable(
    enabled: onTap != null,
    child: WishGlassSurface(
      radius: 21,
      tint: tint,
      seed: icon.codePoint % 7 / 3,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: tint.withValues(alpha: .14)),
                  ),
                  child: Icon(icon, color: tint, size: 25),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(body, style: const TextStyle(fontSize: 13, height: 1.6, color: wishText2)),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Icon(Icons.north_east_rounded, size: 17, color: tint),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.title, required this.body});
  final String number, title, body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 19),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            number,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: wishText3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text(body, style: const TextStyle(fontSize: 13, height: 1.65, color: wishText2)),
            ],
          ),
        ),
      ],
    ),
  );
}
