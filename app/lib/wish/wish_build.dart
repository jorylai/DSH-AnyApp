import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../state/chat_state.dart';
import '../state/connection_state.dart';
import '../state/schedule_editor_state.dart' show deviceTimeZoneProvider;
import '../ui/settings/settings_screen.dart';
import '../ui/chat/widgets/approval_card.dart';
import '../ui/chat/widgets/question_card.dart';
import 'wish_install.dart';
import 'wish_home.dart';
import 'wish_form.dart';

class WishBuildPage extends ConsumerStatefulWidget {
  const WishBuildPage({super.key, required this.sessionId, required this.formId, required this.request});
  final String sessionId;
  final String formId;
  final String request;
  @override
  ConsumerState<WishBuildPage> createState() => _WishBuildPageState();
}

class _WishBuildPageState extends ConsumerState<WishBuildPage> {
  bool _stopping = false;
  bool _sending = false;
  final _revision = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final client = ref.read(activeConnectionProvider).value?.client;
      if (client == null) throw StateError('not-connected');
      await client.prompt(
        widget.sessionId,
        '${appL10n.wishRepairPrompt}\n${_revision.text.trim()}',
        timeZone: ref.read(deviceTimeZoneProvider).value,
      );
      _revision.clear();
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _stopping = true);
    try {
      final client = ref.read(activeConnectionProvider).value?.client;
      if (client == null) throw StateError('not-connected');
      await client.cancel(widget.sessionId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.wishFailure);
    } finally {
      if (mounted) setState(() => _stopping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider(widget.sessionId));
    final ended = !chat.loading && !chat.running && !chat.syncing && chat.turns.lastOrNull?.end != null;
    final notifier = ref.read(chatProvider(widget.sessionId).notifier);
    final latest = chat.items.whereType<AssistantChatItem>().lastOrNull?.text;
    final turn = chat.turns.lastOrNull;
    final notices = chat.items.whereType<NoticeChatItem>().where((n) => n.seq >= (turn?.startSeq ?? 0));
    return PopScope(
      canPop: ended,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_stopping) _cancel();
      },
      child: Scaffold(
        backgroundColor: wishBg,
        appBar: AppBar(title: Text(appL10n.wishBuilding)),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(widget.request, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            Text(appL10n.wishBuildHelp),
            const SizedBox(height: 20),
            if (!ended && chat.approvals.isEmpty && chat.questions.isEmpty) const LinearProgressIndicator(),
            for (final approval in chat.approvals)
              ApprovalCard(key: ValueKey(approval.eventId), request: approval, onRespond: notifier.respond),
            for (final question in chat.questions)
              QuestionCard(
                key: ValueKey(question.eventId),
                request: question,
                onAnswer: (q, a) async {
                  await notifier.answer(q, a);
                },
                onReject: (q) async {
                  await notifier.rejectQuestion(q);
                },
              ),
            if (latest != null && latest.isNotEmpty) ...[const SizedBox(height: 20), SelectableText(latest)],
            for (final notice in notices)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SelectableText(
                  notice.failure?.code == 'MISSING_CREDENTIAL' ? appL10n.wishCreatorKeyMissing : notice.text,
                  style: const TextStyle(color: wishWarm),
                ),
              ),
            if (ended && turn?.endReason?.isCompleted != true)
              Text(appL10n.wishGenerationStopped, style: const TextStyle(color: wishWarm)),
            if (chat.error != null || _error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_error ?? chat.error!, style: const TextStyle(color: wishWarm)),
              ),
            const SizedBox(height: 20),
            if (ended)
              FilledButton(
                onPressed: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => WishInstallPage(formId: widget.formId))),
                child: Text(appL10n.wishCheckArtifact),
              ),
            if (ended) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _revision,
                maxLines: 3,
                decoration: InputDecoration(labelText: appL10n.wishRevisionLabel),
              ),
              OutlinedButton(
                onPressed: _sending ? null : _continue,
                child: Text(_sending ? appL10n.wishBusy : appL10n.wishContinueCreator),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
                child: Text(appL10n.wishCreatorModelSettings),
              ),
            ],
            TextButton(
              onPressed: _stopping ? null : _cancel,
              child: Text(_stopping ? appL10n.wishBusy : appL10n.wishCancel),
            ),
          ],
        ),
      ),
    );
  }
}
