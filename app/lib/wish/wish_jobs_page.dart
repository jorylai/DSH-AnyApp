import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../ui/features/schedule_editor/time_zones.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_home.dart';
import 'wish_ui.dart';
import 'wish_project.dart';
import 'wish_project_page.dart';

class WishJobsPage extends StatefulWidget {
  const WishJobsPage({super.key, required this.work, this.title = '', this.prompt = '', this.phone = false});
  final String work, title, prompt;
  final bool phone;
  @override
  State<WishJobsPage> createState() => _JobsState();
}

class _JobsState extends State<WishJobsPage> {
  List<Map<String, dynamic>> _jobs = [];
  bool _busy = false;
  String? _error;
  Timer? _refresh;
  @override
  void initState() {
    super.initState();
    _load();
    _refresh = Timer.periodic(const Duration(seconds: 8), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true &&
          !_busy)
        _load();
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
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

  Future<void> _read() async {
    final rows = await WishDevice.call<List>('background.list', work: widget.work) ?? [];
    if (mounted) setState(() => _jobs = rows.map(wishMap).toList());
  }

  Future<void> _load() => _run(_read);
  String phase(String? value) => switch (value) {
    'succeeded' => appL10n.wishTaskSucceeded,
    'failed' => appL10n.wishTaskFailed,
    'stopped' => appL10n.wishTaskStopped,
    'interrupted' => appL10n.wishTaskInterrupted,
    'running' => appL10n.wishTaskRunning,
    'awaiting-confirmation' => appL10n.wishTaskWaiting,
    'paused' => appL10n.wishTaskPaused,
    'waiting-resource' => appL10n.wishJobWaitResource,
    'waiting-unlock' => appL10n.wishJobWaitUnlock,
    'permission-required' => appL10n.wishJobNeedPermission,
    'waiting-system' => appL10n.wishJobWaitSystem,
    _ => appL10n.wishJobScheduled,
  };
  String time(dynamic value) {
    if (value is! num || value <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _add() async {
    final title = TextEditingController(text: widget.title), prompt = TextEditingController(text: widget.prompt);
    var at = DateTime.now().add(const Duration(minutes: 5));
    var repeat = 'daily';
    var phone = widget.phone;
    var minutes = 60;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appL10n.wishNewBackgroundTask,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: title,
                    maxLength: 100,
                    decoration: InputDecoration(labelText: appL10n.wishActionName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: prompt,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 8000,
                    decoration: InputDecoration(labelText: appL10n.wishActionPrompt),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(appL10n.wishFirstRun),
                    subtitle: Text(time(at.millisecondsSinceEpoch)),
                    trailing: const Icon(Icons.schedule),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: at,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date == null || !ctx.mounted) return;
                      final tod = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(at));
                      if (tod != null)
                        update(() => at = DateTime(date.year, date.month, date.day, tod.hour, tod.minute));
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: repeat,
                    decoration: InputDecoration(labelText: appL10n.wishRepeat),
                    items: [
                      for (final row in [
                        ('none', appL10n.wishRepeatOnce),
                        ('daily', appL10n.wishRepeatDaily),
                        ('weekly', appL10n.wishRepeatWeekly),
                        ('interval', appL10n.wishRepeatInterval),
                      ])
                        DropdownMenuItem(value: row.$1, child: Text(row.$2)),
                    ],
                    onChanged: (v) => update(() => repeat = v!),
                  ),
                  if (repeat == 'interval')
                    DropdownButtonFormField<int>(
                      initialValue: minutes,
                      items: [
                        for (final n in [15, 30, 60, 180, 1440]) DropdownMenuItem(value: n, child: Text('$n min')),
                      ],
                      onChanged: (v) => update(() => minutes = v!),
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(appL10n.wishJobPhone),
                    subtitle: Text(appL10n.wishJobPhoneHelp),
                    value: phone,
                    onChanged: (v) => update(() => phone = v),
                  ),
                  Text(appL10n.wishBackgroundLimit, style: const TextStyle(color: wishText2, fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishSaveTask)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final name = title.text.trim(), task = prompt.text.trim();
    title.dispose();
    prompt.dispose();
    if (accepted != true || !mounted) return;
    await _run(() async {
      if (name.isEmpty || task.isEmpty) throw StateError(appL10n.wishJobRequired);
      if (!at.isAfter(DateTime.now())) throw StateError(appL10n.wishJobFuture);
      final zone = await detectDeviceTimeZone();
      await WishDevice.call('grant', work: widget.work, args: {'capability': 'background', 'enabled': true});
      await WishDevice.call(
        'background.schedule',
        work: widget.work,
        args: {
          'id': 'task-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
          'title': name,
          'prompt': task,
          'at': at.millisecondsSinceEpoch,
          'timeZone': zone,
          'repeat': repeat,
          'intervalMinutes': minutes,
          'phone': phone,
        },
      );
      await _read();
    });
  }

  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.wishBackgroundRun,
    children: [
      Text(appL10n.wishBackgroundIntro, style: const TextStyle(color: wishText2)),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _busy ? null : _add,
        icon: const Icon(Icons.add_rounded),
        label: Text(appL10n.wishNewBackgroundTask),
      ),
      const SizedBox(height: 16),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
      if (_jobs.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(appL10n.wishNoBackgroundTasks, style: const TextStyle(color: wishText2)),
        ),
      for (final job in _jobs)
        WishCard(
          title: '${job['title']}',
          help:
              '${phase((job['phase'] == 'running' ? job['detail'] ?? job['phase'] : job['phase']) as String?)} · ${time(job['nextAt'])} ${job['timeZone'] ?? ''}',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                '${job['prompt']}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: wishText2),
              ),
            ),
            if ('${job['result'] ?? ''}'.isNotEmpty)
              Padding(padding: const EdgeInsets.all(18), child: SelectableText('${job['result']}')),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                children: [
                  if (job['sessionId'] is String)
                    TextButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                              final projects = await WishProject.local();
                              final project = projects.where((p) => p.id == widget.work).firstOrNull;
                              if (project == null || !mounted) throw StateError('project-not-found');
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => WishProjectPage(
                                    project: project,
                                    creator: true,
                                    initialConversation: job['sessionId'] as String,
                                  ),
                                ),
                              );
                              await _read();
                            }),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(appL10n.wishTaskConversation),
                    ),
                  TextButton.icon(
                    onPressed: _busy || job['phase'] == 'running'
                        ? null
                        : () => _run(() async {
                            await WishDevice.call('background.runNow', work: widget.work, args: {'id': job['id']});
                            await _read();
                          }),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(appL10n.wishRunNow),
                  ),
                  TextButton(
                    onPressed: _busy || job['enabled'] != true
                        ? null
                        : () => _run(() async {
                            await WishDevice.call('background.cancel', work: widget.work, args: {'id': job['id']});
                            await _read();
                          }),
                    child: Text(appL10n.wishStopTask),
                  ),
                ],
              ),
            ),
          ],
        ),
    ],
  );
}
