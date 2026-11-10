import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../wish/wish_device.dart';
import '../wish/wish_palette.dart';
import '../wish/wish_ui.dart';
import 'anyapp_analytics.dart';

/// The same optional choice is available during welcome and in settings.
/// Opening this row never enables collection.
class AnyappAnalyticsNotice extends ConsumerWidget {
  const AnyappAnalyticsNotice({super.key, this.page = AnyappPage.settings});
  final AnyappPage page;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anyappAnalyticsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          key: const ValueKey('anyapp-analytics-consent'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          activeThumbColor: wishBlue,
          title: Text(appL10n.anyappAnalyticsChoice, style: const TextStyle(color: wishText, fontSize: 14)),
          subtitle: Text(
            appL10n.anyappAnalyticsNotice,
            style: const TextStyle(color: wishText2, fontSize: 12, height: 1.6),
          ),
          value: state.enabled,
          onChanged: !state.loaded
              ? null
              : (enabled) async {
                  final analytics = ref.read(anyappAnalyticsProvider.notifier);
                  await analytics.setEnabled(enabled);
                  if (enabled) {
                    analytics.track(AnyappEvent.analyticsPreference, page: page, outcome: AnyappOutcome.success);
                  }
                },
        ),
        if (state.status == AnyappAnalyticsStatus.storageFailure)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appL10n.anyappAnalyticsStorageFailed, style: const TextStyle(color: wishWarm, fontSize: 12)),
                TextButton(
                  onPressed: () => ref.read(anyappAnalyticsProvider.notifier).setEnabled(state.enabled),
                  child: Text(appL10n.anyappAnalyticsRetrySave),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AnyappAnalyticsPage extends ConsumerStatefulWidget {
  const AnyappAnalyticsPage({super.key});
  @override
  ConsumerState<AnyappAnalyticsPage> createState() => _AnyappAnalyticsPageState();
}

class _AnyappAnalyticsPageState extends ConsumerState<AnyappAnalyticsPage> {
  bool _busy = false;
  String? _error, _feedback;
  @override
  void initState() {
    super.initState();
    ref.read(anyappAnalyticsProvider.notifier).track(AnyappEvent.pageView, page: AnyappPage.analytics);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _feedback = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.wishFailure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _run(() async {
    final data = await ref.read(anyappAnalyticsProvider.notifier).exportJson();
    if (!mounted) return;
    final result = await WishDevice.call<Map>(
      'files.export',
      work: 'local-analytics',
      args: {'name': 'anyapp-experience.json', 'mime': 'application/json', 'data': base64Encode(utf8.encode(data))},
    );
    if (mounted && result?['saved'] == true) setState(() => _feedback = appL10n.anyappAnalyticsExported);
  });

  Future<void> _clear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appL10n.anyappAnalyticsClear),
        content: Text(appL10n.anyappAnalyticsClearHelp),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(appL10n.wishKeep)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(appL10n.anyappAnalyticsClear)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    await _run(() async {
      await ref.read(anyappAnalyticsProvider.notifier).clear();
      if (!mounted) return;
      if (ref.read(anyappAnalyticsProvider).status == AnyappAnalyticsStatus.storageFailure) {
        setState(() => _error = appL10n.anyappAnalyticsStorageFailed);
      } else {
        setState(() => _feedback = appL10n.anyappAnalyticsCleared);
      }
    });
  }

  String _status(AnyappAnalyticsState state) {
    if (state.status == AnyappAnalyticsStatus.storageFailure) return appL10n.anyappAnalyticsStorageFailed;
    if (!state.enabled) return appL10n.anyappAnalyticsOff;
    if (!state.endpointConfigured) return appL10n.anyappAnalyticsLocal;
    return switch (state.status) {
      AnyappAnalyticsStatus.sending => appL10n.anyappAnalyticsSending,
      AnyappAnalyticsStatus.retry => appL10n.anyappAnalyticsRetry,
      AnyappAnalyticsStatus.delivered => appL10n.anyappAnalyticsDelivered,
      _ => appL10n.anyappAnalyticsReady,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(anyappAnalyticsProvider);
    return WishPage(
      title: appL10n.anyappAnalyticsTitle,
      children: [
        Text(appL10n.anyappAnalyticsInvitation, style: const TextStyle(color: wishText, fontSize: 25, height: 1.4)),
        const SizedBox(height: 12),
        Text(appL10n.anyappAnalyticsHelp, style: const TextStyle(color: wishText2, height: 1.7)),
        const SizedBox(height: 22),
        WishCard(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: AnyappAnalyticsNotice(page: AnyappPage.analytics),
            ),
          ],
        ),
        WishCard(
          title: appL10n.anyappAnalyticsStatus,
          children: [
            WishRow(
              title: _status(state),
              help: state.endpointConfigured ? appL10n.anyappAnalyticsIndependent : appL10n.anyappAnalyticsUnconfigured,
              icon: state.endpointConfigured ? Icons.cloud_outlined : Icons.phone_android_rounded,
            ),
            WishRow(title: appL10n.anyappAnalyticsQueue, help: '${state.queued}', icon: Icons.layers_outlined),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy || !state.loaded ? null : _export,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(appL10n.anyappAnalyticsExport),
                  ),
                  TextButton.icon(
                    onPressed: _busy || !state.loaded ? null : _clear,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(appL10n.anyappAnalyticsClear),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
        if (_feedback != null) Text(_feedback!, style: const TextStyle(color: wishGreen)),
        if (_busy) const LinearProgressIndicator(),
      ],
    );
  }
}
