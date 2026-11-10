import 'dart:async';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import 'wish_agent.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_home.dart';
import 'wish_travel.dart';

/// Shared review surfaces are available to every work, including older plugins.
class WishRecordsPage extends StatefulWidget {
  const WishRecordsPage({super.key, required this.work, required this.client, this.openTask});
  final String work;
  final DshClient client;
  final VoidCallback? openTask;
  @override
  State<WishRecordsPage> createState() => _WishRecordsPageState();
}

class _WishRecordsPageState extends State<WishRecordsPage> {
  int _tab = 0;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _imports = [], _trips = [], _notifications = [], _candidates = [];
  List<dynamic> _results = [];
  Map<String, dynamic> _task = {};
  String? _source;
  bool _calendar = false, _reminder = false;
  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    await _run(() async {
      switch (_tab) {
        case 0:
          final rows = await WishDevice.call<List>('imports.list', work: widget.work) ?? [];
          if (mounted) setState(() => _imports = rows.map(wishMap).toList());
        case 1:
          final rows = await widget.client.rpc.call('wishMobile/travelList', {});
          if (mounted) setState(() => _trips = (rows as List).map(wishMap).toList());
        case 2:
          final state = await WishAgent(widget.work, widget.client).status();
          final raw = await widget.client.rpc.call('wishMobile/agentResults', {});
          if (mounted)
            setState(() {
              _task = state;
              _results = raw is List
                  ? raw
                  : raw == null
                  ? []
                  : [raw];
            });
        case 3:
          final data = wishMap(await WishDevice.call('notifications.list', work: widget.work));
          if (mounted) setState(() => _notifications = (data['items'] as List? ?? []).map(wishMap).toList());
      }
    });
  }

  final Map<String, String> _ocrText = {};
  Future<void> _ocr(Map<String, dynamic> source) async {
    await _run(() async {
      final data = wishMap(await WishDevice.call('imports.read', work: widget.work, args: {'id': source['id']}));
      final file = wishMap(data['file']);
      final result = wishMap(
        await WishDevice.call('ocr.recognize', work: widget.work, args: {'data': file['data'], 'script': 'chinese'}),
      );
      final text = '${result['text'] ?? ''}'.trim();
      if (text.isEmpty) throw StateError(appL10n.wishOcrEmpty);
      if (mounted) setState(() => _ocrText['${source['id']}'] = text);
    });
  }

  Future<void> _deleteTrip(Map<String, dynamic> trip) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appL10n.wishDeleteTrip),
        content: Text(appL10n.wishDeleteTripHelp),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishDeleteTrip)),
        ],
      ),
    );
    if (yes != true) return;
    await _run(() async {
      await WishTravel.remove(widget.client, widget.work, trip['id'] as String);
      if (mounted) setState(() => _trips = _trips.where((r) => r['id'] != trip['id']).toList());
    });
  }

  Future<void> _extract(Map<String, dynamic> source, {bool imported = false}) async {
    await _run(() async {
      final data = imported
          ? wishMap(await WishDevice.call('imports.read', work: widget.work, args: {'id': source['id']}))
          : source;
      final file = wishMap(data['file'] ?? {});
      final mime = '${file['mime'] ?? ''}';
      if (file.isNotEmpty && !mime.startsWith('image/')) throw StateError('travel-import-use-text-or-image');
      final localText = _ocrText['${source['id']}'];
      final text = imported
          ? '${data['text'] ?? ''}\n${localText ?? ''}'
          : '${source['title'] ?? ''}\n${source['text'] ?? ''}';
      final rows = await WishTravel.extract(
        widget.client,
        text,
        image: file.isNotEmpty && localText == null ? {'data': file['data'], 'mediaType': mime} : null,
      );
      final id = '${source['id'] ?? source['key'] ?? ''}';
      if (mounted)
        setState(() {
          _source = id;
          _candidates = rows
              .map((r) => {...r, 'sourceId': id, 'sourceKind': imported ? 'import' : 'notification'})
              .toList();
        });
    });
  }

  Future<void> _saveCandidate(Map<String, dynamic> candidate) async {
    await _run(() async {
      await WishTravel.save(widget.client, widget.work, candidate, calendar: _calendar, reminder: _reminder);
      if (mounted) setState(() => _candidates = _candidates.where((c) => c['id'] != candidate['id']).toList());
    });
  }

  String _time(dynamic value) {
    final at = value is num ? DateTime.fromMillisecondsSinceEpoch(value.toInt()) : DateTime.tryParse('$value');
    if (at == null) return appL10n.wishTimeUnknown;
    final d = at.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: wishText2),
      ),
    ),
  );
  Widget _card(Widget child) => Card(
    color: wishSurface,
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(padding: const EdgeInsets.all(18), child: child),
  );
  Widget _trip(Map<String, dynamic> trip, {bool candidate = false}) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${trip['title'] ?? ''}',
          style: const TextStyle(color: wishText, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Text('${_time(trip['start'])} → ${_time(trip['end'])}', style: const TextStyle(color: wishText2)),
        if ('${trip['location'] ?? ''}'.isNotEmpty)
          Text('${trip['location']}', style: const TextStyle(color: wishText2)),
        if ('${trip['notes'] ?? ''}'.isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${trip['notes']}')),
        if ((trip['missing'] as List? ?? []).isNotEmpty)
          Text((trip['missing'] as List).join(' · '), style: const TextStyle(color: wishWarm)),
        if (candidate)
          FilledButton(onPressed: _busy ? null : () => _saveCandidate(trip), child: Text(appL10n.wishSaveTrip))
        else
          Wrap(
            spacing: 10,
            children: [
              if (trip['calendarSaved'] == true) Chip(label: Text(appL10n.wishCalendarSaved)),
              if (trip['reminderSaved'] == true) Chip(label: Text(appL10n.wishReminderSaved)),
              TextButton(onPressed: _busy ? null : () => _deleteTrip(trip), child: Text(appL10n.wishDeleteTrip)),
            ],
          ),
      ],
    ),
  );
  Widget _importsView() => Column(
    children: [
      if (_imports.isEmpty) _empty(appL10n.wishImportEmpty),
      for (final row in _imports)
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_time(row['at']), style: const TextStyle(color: wishText3, fontSize: 12)),
              const SizedBox(height: 10),
              Text('${row['text'] ?? ''}', maxLines: 6, overflow: TextOverflow.ellipsis),
              if (row['file'] != null)
                Text('${wishMap(row['file'])['name'] ?? ''}', style: const TextStyle(color: wishText2)),
              if (_ocrText['${row['id']}'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SelectableText(_ocrText['${row['id']}']!),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if ('${wishMap(row['file'] ?? {})['mime'] ?? ''}'.startsWith('image/'))
                    TextButton.icon(
                      onPressed: _busy ? null : () => _ocr(row),
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: Text(appL10n.wishLocalOcr),
                    ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _extract(row, imported: true),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: Text(appL10n.wishExtractTravel),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                            await WishDevice.call('imports.remove', work: widget.work, args: {'id': row['id']});
                            if (mounted)
                              setState(() => _imports = _imports.where((r) => r['id'] != row['id']).toList());
                          }),
                    child: Text(appL10n.wishRemove),
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );
  Widget _notificationView() => Column(
    children: [
      Text(appL10n.wishNotificationsNewOnly, style: const TextStyle(color: wishText2)),
      const SizedBox(height: 16),
      if (_notifications.isEmpty) _empty(appL10n.wishNotificationEmpty),
      for (final row in _notifications)
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${row['title'] ?? ''}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              Text('${row['package']} · ${_time(row['at'])}', style: const TextStyle(color: wishText3, fontSize: 12)),
              const SizedBox(height: 8),
              Text('${row['text'] ?? ''}'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _extract(row),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(appL10n.wishExtractTravel),
              ),
            ],
          ),
        ),
    ],
  );
  Widget _taskView() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _phase('${_task['phase'] ?? 'idle'}'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final row in (_task['events'] as List? ?? []).take(12))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  row['type'] == 'tool' ? '${appL10n.wishTaskStep}: ${row['name']}' : '${row['text'] ?? ''}',
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: widget.openTask == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          widget.openTask!();
                        },
                  child: Text(appL10n.wishTaskConversation),
                ),
                if (_task['running'] == true)
                  TextButton(
                    onPressed: () => _run(() async {
                      await WishAgent(widget.work, widget.client).stop();
                      _task = await WishAgent(widget.work, widget.client).status();
                    }),
                    child: Text(appL10n.wishStopTask),
                  ),
              ],
            ),
          ],
        ),
      ),
      if (_results.isEmpty) _empty(appL10n.wishResultsEmpty),
      for (final raw in _results) WishComparisonCard(value: raw is Map ? wishMap(raw) : {'conclusion': '$raw'}),
    ],
  );
  String _phase(String value) => switch (value) {
    'succeeded' => appL10n.wishTaskSucceeded,
    'failed' => appL10n.wishTaskFailed,
    'stopped' => appL10n.wishTaskStopped,
    'interrupted' => appL10n.wishTaskInterrupted,
    'paused' => appL10n.wishTaskPaused,
    'running' => appL10n.wishTaskRunning,
    'awaiting-confirmation' => appL10n.wishTaskWaiting,
    _ => appL10n.wishNoTask,
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: wishBg,
    appBar: AppBar(
      title: Text(appL10n.wishRecords),
      actions: [
        IconButton(onPressed: _busy ? null : _load, tooltip: appL10n.wishRefresh, icon: const Icon(Icons.refresh)),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                for (final row in [
                  (0, appL10n.wishImportTab),
                  (1, appL10n.wishTravelTab),
                  (2, appL10n.wishTasksTab),
                  (3, appL10n.wishNotificationsTab),
                ])
                  ButtonSegment(value: row.$1, label: Text(row.$2)),
              ],
              selected: {_tab},
              onSelectionChanged: _busy
                  ? null
                  : (v) {
                      setState(() {
                        _tab = v.first;
                        _candidates = [];
                      });
                      _load();
                    },
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_error != null) _card(Text(_error!, style: const TextStyle(color: wishWarm))),
                if (_candidates.isNotEmpty) ...[
                  Text(appL10n.wishReviewCandidates, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    '${appL10n.wishSource}: $_source',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: wishText3, fontSize: 12),
                  ),
                  SwitchListTile(
                    title: Text(appL10n.wishAlsoCalendar),
                    value: _calendar,
                    onChanged: _busy ? null : (v) => setState(() => _calendar = v),
                  ),
                  SwitchListTile(
                    title: Text(appL10n.wishAlsoReminder),
                    subtitle: Text(appL10n.wishTwoHoursBefore),
                    value: _reminder,
                    onChanged: _busy ? null : (v) => setState(() => _reminder = v),
                  ),
                  for (final trip in _candidates) _trip(trip, candidate: true),
                  const Divider(),
                ],
                switch (_tab) {
                  0 => _importsView(),
                  1 =>
                    _trips.isEmpty
                        ? _empty(appL10n.wishTravelEmpty)
                        : Column(children: _trips.map((t) => _trip(t)).toList()),
                  2 => _taskView(),
                  _ => _notificationView(),
                },
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class WishComparisonCard extends StatelessWidget {
  const WishComparisonCard({super.key, required this.value});
  final Map<String, dynamic> value;
  Future<void> _open(String raw) async {
    final url = Uri.tryParse(raw);
    if (url != null && {'http', 'https'}.contains(url.scheme))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final rawOffers = value['offers'];
    final offers = (rawOffers is List ? rawOffers : const [])
        .whereType<Map>()
        .map((r) => r.cast<String, dynamic>())
        .toList();
    return Card(
      color: wishSurface,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${value['product'] ?? value['商品名称'] ?? value['title'] ?? appL10n.wishComparisonResult}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (value['spec'] != null) Text('${value['spec']}', style: const TextStyle(color: wishText2)),
            const SizedBox(height: 12),
            Text(appL10n.wishComparisonScope, style: const TextStyle(color: wishText2, fontSize: 12)),
            if (offers.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(appL10n.wishSource)),
                    DataColumn(label: Text(appL10n.wishPrice)),
                    DataColumn(label: Text(appL10n.wishShipping)),
                    DataColumn(label: Text(appL10n.wishCouponConditions)),
                    DataColumn(label: Text(appL10n.wishCheckedAt)),
                  ],
                  rows: [
                    for (final offer in offers)
                      DataRow(
                        cells: [
                          DataCell(
                            TextButton(
                              onPressed: () => _open('${offer['url'] ?? ''}'),
                              child: Text('${offer['source'] ?? appL10n.wishSource}'),
                            ),
                          ),
                          DataCell(
                            Text(
                              offer['price'] == null
                                  ? appL10n.wishNotVerified
                                  : '${offer['currency'] ?? 'CNY'} ${offer['price']}',
                            ),
                          ),
                          DataCell(Text('${offer['shipping'] ?? appL10n.wishNotVerified}')),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: Text('${offer['couponConditions'] ?? appL10n.wishNotVerified}'),
                            ),
                          ),
                          DataCell(Text('${offer['checkedAt'] ?? appL10n.wishNotVerified}')),
                        ],
                      ),
                  ],
                ),
              ),
            if (value['conclusion'] != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text('${value['conclusion']}')),
            if (value['unavailableSources'] != null)
              Text(
                '${appL10n.wishUnavailableSources}: ${value['unavailableSources']}',
                style: const TextStyle(color: wishWarm),
              ),
            if (offers.isEmpty && value['conclusion'] == null)
              Text('${value['result'] ?? value['结论'] ?? appL10n.wishResultsNeedReview}'),
          ],
        ),
      ),
    );
  }
}
