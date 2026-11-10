import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'wish_phone_setup.dart';
import 'wish_setup_guide.dart';
import 'wish_settings.dart' show WishBackgroundPage;
import 'wish_device.dart';
import 'wish_home.dart';
import 'wish_ui.dart';
import 'wish_permissions.dart';
import 'wish_life_settings.dart';
import 'wish_jobs_page.dart';
import 'wish_action_settings.dart';
import 'wish_floating_entry_switch.dart';

class WishCapabilitiesPage extends StatefulWidget {
  const WishCapabilitiesPage({super.key, this.projectId});
  final String? projectId;
  @override
  State<WishCapabilitiesPage> createState() => _WishCapabilitiesPageState();
}

class _WishCapabilitiesPageState extends State<WishCapabilitiesPage> {
  Map<String, dynamic> _status = {};
  Map<String, bool> _permissions = {};
  String? _error;
  bool _busy = false;
  late final _life = AppLifecycleListener(onResume: _refresh);
  @override
  void initState() {
    super.initState();
    _life;
    _refresh();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final status = await WishDevice.status(widget.projectId);
      final permissions = await WishPermissions.status();
      if (mounted) {
        setState(() {
          _status = status;
          _permissions = permissions;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) await _refresh();
  }

  Future<void> _grant(String capability, bool value) async {
    if (value && capability == 'phone') {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(appL10n.wishPhone),
          content: Text(appL10n.wishPhoneConsent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishBridgeAllow)),
          ],
        ),
      );
      if (accepted != true) return;
    }
    await WishDevice.call('grant', work: widget.projectId, args: {'capability': capability, 'enabled': value});
  }

  Widget _statusRow(String title, bool enabled, Future<void> Function() action, {String? help}) => ListTile(
    title: Text(title),
    subtitle: Text(help ?? (enabled ? appL10n.wishDeviceReady : appL10n.wishDeviceOff)),
    leading: Icon(
      enabled ? Icons.check_circle_outline : Icons.radio_button_unchecked,
      color: enabled ? wishGreen : wishText3,
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: _busy ? null : () => _run(action),
  );
  Widget _group(String title, String help, List<Widget> children, {String? grant}) => WishCard(
    title: title,
    help: help,
    children: [
      if (grant != null && widget.projectId != null)
        SwitchListTile(
          key: ValueKey('grant-$grant'),
          title: Text(appL10n.wishWorkGrant),
          value: _status[grant] == true,
          onChanged: _busy ? null : (v) => _run(() => _grant(grant, v)),
        ),
      ...children,
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(title: Text(appL10n.anyPermissionsAndActions)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appL10n.anyPermissionsAndActionsHelp, style: const TextStyle(color: wishText2, height: 1.6)),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, style: const TextStyle(color: wishWarm)),
            ),
          if (widget.projectId != null)
            WishCard(
              children: [
                WishRow(
                  title: appL10n.wishFloatingActions,
                  help: appL10n.anyActionsCenterHelp,
                  icon: Icons.touch_app_outlined,
                  onTap: () => _push(WishActionSettings(work: widget.projectId!)),
                ),
              ],
            ),
          if (widget.projectId == null)
            WishCard(
              children: [
                WishFloatingEntrySwitch(
                  waitForSystemResume: true,
                  requestPermission: () async {
                    final result = await WishDevice.call<Map>('setup.open', args: {'target': 'overlay'});
                    if (result?['opened'] != true) throw StateError(appL10n.phoneSetupOpenFailed);
                  },
                ),
                const WishSetupGuidePage(initialTopic: 'overlay', embedded: true),
              ],
            ),
          _group(appL10n.wishPhone, appL10n.wishPhoneHelp, [const WishPhoneSetupPage(embedded: true)], grant: 'phone'),
          _group(appL10n.wishReminders, appL10n.wishReminderHelp, [
            const WishSetupGuidePage(initialTopic: 'notifications', embedded: true),
            const WishSetupGuidePage(initialTopic: 'exact', embedded: true),
            if (widget.projectId != null && _status['reminders'] == true)
              ListTile(
                title: Text(appL10n.wishReminderTest),
                leading: const Icon(Icons.alarm),
                onTap: _busy
                    ? null
                    : () => _run(() async {
                        await WishDevice.call(
                          'reminders.schedule',
                          work: widget.projectId,
                          args: {
                            'id': 'permission-test',
                            'at': DateTime.now().millisecondsSinceEpoch + 10000,
                            'title': appL10n.wishReminderTestTitle,
                            'body': appL10n.wishReminderTestBody,
                          },
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(this.context)
                              .showSnackBar(SnackBar(content: Text(appL10n.wishReminderQueued)));
                        }
                      }),
              ),
          ], grant: 'reminders'),
          WishCard(
            children: [
              ExpansionTile(
                key: const ValueKey('capabilities-more'),
                leading: const Icon(Icons.settings_suggest_outlined),
                title: Text(appL10n.anyMorePhoneCapabilities),
                subtitle: Text(appL10n.anyMorePhoneCapabilitiesHelp),
                childrenPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                children: [
                  if (widget.projectId != null)
                    ListTile(
                      leading: const Icon(Icons.explore_outlined),
                      title: Text(appL10n.wishLifeCapabilities),
                      subtitle: Text(appL10n.wishLifeHelp),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _push(WishLifeSettings(work: widget.projectId!)),
                    ),
                  _group(appL10n.wishBackgroundRun, appL10n.wishBackgroundLimit, [
                    if (widget.projectId != null)
                      ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: Text(appL10n.wishBackgroundRun),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _push(WishJobsPage(work: widget.projectId!)),
                      ),
                    ListTile(
                      leading: const Icon(Icons.battery_saver_outlined),
                      title: Text(appL10n.wishBackgroundSetup),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _push(const WishBackgroundPage()),
                    ),
                  ], grant: 'background'),
                  const WishSetupGuidePage(initialTopic: 'developerOptions', embedded: true),
                  const WishSetupGuidePage(initialTopic: 'usbDebugging', embedded: true),
                  _group(appL10n.wishSharedDevice, appL10n.wishBackgroundHelp, [
                    _statusRow(appL10n.wishCamera, _permissions['camera'] == true, () async {
                      await WishPermissions.requestCamera();
                    }),
                    _statusRow(appL10n.wishMicrophone, _permissions['microphone'] == true, () async {
                      await WishPermissions.requestMicrophone();
                    }),
                    if (widget.projectId != null) const WishSetupGuidePage(initialTopic: 'overlay', embedded: true),
                    _statusRow(appL10n.wishFiles, _status['files'] == true, () async {
                      await WishDevice.call('settings', args: {'kind': 'files'});
                    }, help: appL10n.wishFilesHelp),
                  ]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
