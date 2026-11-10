import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_home.dart';
import 'wish_permissions.dart';

class WishLifeSettings extends StatefulWidget {
  const WishLifeSettings({super.key, required this.work});
  final String work;
  @override
  State<WishLifeSettings> createState() => _WishLifeSettingsState();
}

class _WishLifeSettingsState extends State<WishLifeSettings> {
  Map<String, dynamic> _state = {};
  String? _error;
  bool _busy = false;
  late final _life = AppLifecycleListener(onResume: _load);
  @override
  void initState() {
    super.initState();
    _life;
    _load();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final state = await WishDevice.status(widget.work);
      if (mounted) setState(() => _state = state);
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    }
  }

  Future<void> _run(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await fn();
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectApps() async {
    final apps = (await WishDevice.call<List>('notifications.apps') ?? []).map(wishMap).toList();
    final selected = (await WishDevice.call<List>('notifications.selected', work: widget.work) ?? [])
        .cast<String>()
        .toSet();
    if (!mounted) return;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * .8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(appL10n.wishNotificationSources, style: const TextStyle(fontSize: 20)),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final app in apps)
                        CheckboxListTile(
                          title: Text('${app['label']}'),
                          subtitle: Text('${app['package']}'),
                          value: selected.contains(app['package']),
                          onChanged: (v) => setSheet(() {
                            if (v == true)
                              selected.add(app['package'] as String);
                            else
                              selected.remove(app['package']);
                          }),
                        ),
                    ],
                  ),
                ),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishSaveIdentity)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
    if (accepted == true)
      await WishDevice.call('notifications.select', work: widget.work, args: {'apps': selected.toList()});
  }

  Widget grant(String title, String key, {String? stateKey}) => SwitchListTile(
    title: Text(title),
    subtitle: Text(appL10n.wishWorkGrant),
    value: _state[stateKey ?? key] == true,
    onChanged: _busy
        ? null
        : (v) => _run(() async {
            await WishDevice.call('grant', work: widget.work, args: {'capability': key, 'enabled': v});
          }),
  );
  @override
  Widget build(BuildContext context) {
    final life = wishMap(_state['life'] ?? {});
    return Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(title: Text(appL10n.wishLifeCapabilities)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appL10n.wishLifeHelp, style: const TextStyle(color: wishText2)),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
          grant(appL10n.wishCalendar, 'calendar'),
          ListTile(
            title: Text(appL10n.wishCalendarPermission),
            subtitle: Text(
              life['calendarRead'] == true && life['calendarWrite'] == true
                  ? appL10n.wishDeviceReady
                  : appL10n.wishDeviceOff,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _run(() async {
              await WishPermissions.request('requestCalendar');
              await WishPermissions.request('requestCalendarWrite');
            }),
          ),
          const Divider(),
          grant(appL10n.wishLocation, 'location'),
          ListTile(
            title: Text(appL10n.wishLocationPermission),
            subtitle: Text(life['location'] == true ? appL10n.wishDeviceReady : appL10n.wishDeviceOff),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _run(() => WishPermissions.request('requestLocation')),
          ),
          const Divider(),
          grant(appL10n.wishNotificationReading, 'notifications', stateKey: 'notificationAccess'),
          ListTile(
            title: Text(appL10n.wishNotificationReading),
            subtitle: Text(life['notificationListener'] == true ? appL10n.wishDeviceReady : appL10n.wishDeviceOff),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _run(() async {
              await WishDevice.call('settings', args: {'kind': 'notificationListener'});
            }),
          ),
          ListTile(
            title: Text(appL10n.wishNotificationSources),
            subtitle: Text(appL10n.wishNotificationsNewOnly),
            trailing: const Icon(Icons.chevron_right),
            onTap: _busy ? null : () => _run(_selectApps),
          ),
          const Divider(),
          ListTile(
            title: Text(appL10n.wishSpeech),
            subtitle: Text(life['speechRecognition'] == true ? appL10n.wishDeviceReady : appL10n.wishSpeechUnavailable),
          ),
          ListTile(title: Text(appL10n.wishLocalOcr), subtitle: Text(appL10n.wishOcrHelp)),
        ],
      ),
    );
  }
}
