import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../analytics/anyapp_analytics_ui.dart';
import '../state/app_info.dart';
import '../runtime/runtime_state.dart';
import '../state/settings_state.dart';
import '../share_code/guest_fs.dart';
import 'wish_home.dart';
import 'wish_ui.dart';
import 'wish_account_page.dart';
import 'wish_capabilities_page.dart';
import 'wish_app_runtime.dart';
import 'wish_execution_settings.dart';
import 'wish_updates.dart';
import 'wish_diagnostics_page.dart';

class WishSettingsPage extends StatelessWidget {
  const WishSettingsPage({super.key});
  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.commonSettings,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PREFERENCES', style: TextStyle(color: Color(0xFFAFBDFF), fontSize: 10, letterSpacing: 2.1)),
            const SizedBox(height: 12),
            Text(
              appL10n.wishSettingsPoem,
              style: const TextStyle(color: wishText, fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -.5),
            ),
            const SizedBox(height: 8),
            Text(appL10n.wishSettingsInvitation, style: const TextStyle(color: wishText2, height: 1.6)),
          ],
        ),
      ),
      WishCard(
        title: appL10n.wishSettingsAccount,
        children: [
          WishRow(
            title: appL10n.wishSettingsAccount,
            help: appL10n.wishSettingsAccountHelp,
            icon: Icons.account_circle_outlined,
            onTap: () => _push(context, const WishAccountPage()),
          ),
        ],
      ),
      WishCard(
        title: appL10n.anyPermissionsAndActions,
        children: [
          WishRow(
            title: appL10n.wishAuthorization,
            help: appL10n.wishFullAccessHelp,
            icon: Icons.tune_outlined,
            onTap: () => _push(context, const WishExecutionSettings()),
          ),
          WishRow(
            title: appL10n.wishCapabilities,
            help: appL10n.anyPhoneAccessHelp,
            icon: Icons.shield_outlined,
            onTap: () => _push(context, const WishCapabilitiesPage()),
          ),
        ],
      ),
      WishCard(
        title: appL10n.wishStorageTitle,
        children: [
          WishRow(
            title: appL10n.wishStorageTitle,
            help: appL10n.wishStorageHelp,
            icon: Icons.storage_outlined,
            onTap: () => _push(context, const WishStoragePage()),
          ),
          WishRow(
            title: appL10n.wishRuntimeTitle,
            help: appL10n.wishRuntimeHelp,
            icon: Icons.memory_outlined,
            onTap: () => _push(context, const WishRuntimePage()),
          ),
        ],
      ),
      WishCard(
        title: appL10n.wishPrivacyTitle,
        children: [
          WishRow(title: appL10n.wishAiDirectLabel, help: appL10n.wishAiDirectHelp, icon: Icons.auto_awesome_outlined),
          WishRow(title: appL10n.wishLocalOnly, help: appL10n.wishDataPolicy, icon: Icons.folder_outlined),
          WishRow(
            title: appL10n.anyDiagnosticsTitle,
            help: appL10n.anyDiagnosticsIntroBody,
            icon: Icons.shield_outlined,
            onTap: () => _push(context, const WishModelDiagnosticsPage()),
          ),
          WishRow(
            title: appL10n.anyappAnalyticsTitle,
            help: appL10n.anyappAnalyticsNotice,
            icon: Icons.insights_outlined,
            onTap: () => _push(context, const AnyappAnalyticsPage()),
          ),
        ],
      ),
      WishCard(
        children: [
          WishRow(
            title: appL10n.wishUpdateTitle,
            help: AppInfo.displayVersion,
            icon: Icons.system_update_alt_rounded,
            onTap: () => _push(context, const WishUpdatesPage()),
          ),
          WishRow(
            title: appL10n.wishAbout,
            help: 'DSH AnyApp ${AppInfo.displayVersion}',
            icon: Icons.info_outline,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'DSH AnyApp',
              applicationVersion: AppInfo.displayVersion,
              applicationLegalese: 'Powered by DeepSeek Harness · AGPL-3.0',
              children: [Text(appL10n.wishSettingsAbout)],
            ),
          ),
        ],
      ),
    ],
  );
}

class WishBackgroundPage extends ConsumerStatefulWidget {
  const WishBackgroundPage({super.key});
  @override
  ConsumerState<WishBackgroundPage> createState() => _WishBackgroundState();
}

class _WishBackgroundState extends ConsumerState<WishBackgroundPage> {
  bool? _battery;
  String? _error;
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
      final v = await ref.read(runtimeBridgeProvider).batteryExempt();
      if (mounted) setState(() => _battery = v);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _vendor(String key) async {
    try {
      if (await ref.read(runtimeBridgeProvider).openVendorSettings(key) == null) throw StateError(appL10n.wishFailure);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.wishBackgroundSetup,
    children: [
      Text(appL10n.wishVendorHint, style: const TextStyle(color: wishText2, height: 1.5)),
      const SizedBox(height: 20),
      if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
      WishCard(
        children: [
          WishRow(
            title: appL10n.wishBattery,
            help: _battery == true ? appL10n.wishDeviceReady : appL10n.wishDeviceOff,
            icon: Icons.battery_saver_outlined,
            onTap: () async {
              await ref.read(runtimeBridgeProvider).requestBatteryExempt();
            },
          ),
          WishRow(
            title: appL10n.wishAutoStart,
            help: appL10n.wishBackgroundHelp,
            icon: Icons.restart_alt,
            onTap: () => _vendor('autostart'),
          ),
          WishRow(
            title: appL10n.wishBackgroundPopup,
            help: appL10n.wishBackgroundHelp,
            icon: Icons.open_in_new,
            onTap: () => _vendor('popup'),
          ),
          WishRow(
            title: appL10n.wishBackgroundSetup,
            help: appL10n.wishVendorHint,
            icon: Icons.settings_suggest_outlined,
            onTap: () => _vendor('background'),
          ),
        ],
      ),
    ],
  );
}

class WishRuntimePage extends ConsumerStatefulWidget {
  const WishRuntimePage({super.key});
  @override
  ConsumerState<WishRuntimePage> createState() => _WishRuntimeState();
}

class _WishRuntimeState extends ConsumerState<WishRuntimePage> {
  String? _error;
  bool _busy = false;
  Future<void> _storage(bool enabled) async {
    if (_busy) return;
    try {
      final bridge = ref.read(runtimeBridgeProvider);
      if (enabled && !(await bridge.storageStatus()).granted) {
        final access = await bridge.requestStorage();
        if (!access.granted) {
          await bridge.openAllFilesAccess();
          return;
        }
      }
      await ref.read(settingsProvider.notifier).setPhoneStorage(enabled);
      if (mounted) await _restart();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _restart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(appL10n.wishRuntimeRestart),
        content: Text(appL10n.wishPhoneEngineHelp),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(appL10n.wishKeep)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(appL10n.wishRuntimeRestart)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await WishAppRuntime.connect(
        ProviderScope.containerOf(context, listen: false),
        ref.read(localRuntimeProfileProvider),
        restart: true,
      );
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localRuntimeProvider).status;
    return WishPage(
      title: appL10n.wishRuntimeTitle,
      children: [
        WishCard(
          title: appL10n.wishRuntimeTitle,
          help: appL10n.wishRuntimeHelp,
          children: [
            WishRow(title: state.isRunning ? appL10n.wishDeviceReady : appL10n.wishDeviceOff, help: state.error),
            SwitchListTile(
              title: Text(appL10n.wishFiles),
              subtitle: Text(appL10n.wishFilesHelp),
              value: ref.watch(settingsProvider).phoneStorage,
              onChanged: _busy ? null : _storage,
            ),
            WishRow(title: appL10n.wishRuntimeRestart, icon: Icons.sync, onTap: _busy ? null : _restart),
          ],
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
      ],
    );
  }
}

class WishStoragePage extends StatefulWidget {
  const WishStoragePage({super.key});
  @override
  State<WishStoragePage> createState() => _WishStorageState();
}

class _WishStorageState extends State<WishStoragePage> {
  Map<String, int>? _bytes;
  String? _error;
  @override
  void initState() {
    super.initState();
    _measure();
  }

  Future<void> _measure() async {
    try {
      final fs = await GuestFs.local();
      if (fs == null) throw StateError('runtime-not-installed');
      final path = fs.root.path;
      final result = await Isolate.run(() => _sizes(path));
      if (mounted) setState(() => _bytes = result);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  static Map<String, int> _sizes(String path) {
    var whole = 0, works = 0;
    for (final e in Directory(path).listSync(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      try {
        final length = e.lengthSync();
        whole += length;
        if (e.path.startsWith('$path/root/.dsh/wish/')) works += length;
      } on FileSystemException {
        continue;
      }
    }
    return {'engine': whole - works, 'works': works};
  }

  String _size(int value) => '${(value / 1024 / 1024).toStringAsFixed(1)} MB';
  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.wishStorageTitle,
    children: [
      if (_bytes == null && _error == null)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(appL10n.wishStorageCalculating),
            ],
          ),
        ),
      if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
      if (_bytes != null)
        WishCard(
          children: [
            WishRow(title: appL10n.wishStorageWorks, help: _size(_bytes!['works']!), icon: Icons.apps_outlined),
            WishRow(title: appL10n.wishStorageEngine, help: _size(_bytes!['engine']!), icon: Icons.storage_outlined),
          ],
        ),
      Text(appL10n.wishStorageNote, style: const TextStyle(color: wishText2, height: 1.5)),
    ],
  );
}
