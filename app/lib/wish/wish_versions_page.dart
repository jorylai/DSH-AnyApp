import 'dart:convert';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'wish_app_runtime.dart';
import 'wish_identity.dart';
import 'wish_package_identity.dart';
import 'wish_plugin_package.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_project.dart';
import 'wish_release_activation.dart';
import 'wish_ui.dart';
import 'wish_home.dart';

class WishVersionsPage extends StatefulWidget {
  const WishVersionsPage({super.key, required this.project, required this.client});
  final WishProject project;
  final DshClient client;
  @override
  State<WishVersionsPage> createState() => _VersionsState();
}

class _VersionsState extends State<WishVersionsPage> {
  late DshClient _client;
  List<Map<String, dynamic>> _rows = [];
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _load();
  }

  Future<void> _run(Future<void> Function() fn, {bool lock = true}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if ((await _client.listSessions()).any((s) => s.running)) throw StateError('finish-current-conversation-first');
      if (lock) await _client.rpc.call('wishMobile/beginOperation', {'token': 'versions'});
      try {
        await fn();
      } finally {
        if (lock) await _client.rpc.call('wishMobile/endOperation', {'token': 'versions'});
      }
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read() async {
    final rows = await _client.rpc.call('wishMobile/releaseList', {});
    if (mounted) setState(() => _rows = (rows as List).map(wishMap).toList());
  }

  Future<void> _load() => _run(_read);
  Future<void> _checkpoint() => _run(() async {
    await _client.rpc.call('wishMobile/releaseCheckpoint', {});
    await _read();
  });
  Future<void> _export() => _run(() async {
    final envelope = wishMap(await _client.rpc.call('wishMobile/releaseExport', {}));
    final identity = Map<String, dynamic>.from((await WishIdentity.get(widget.project.id)).value);
    if (identity['title'] == widget.project.title && identity['customName'] == null) identity.remove('title');
    final value = WishPackageIdentity.attach(envelope, identity: identity);
    final bytes = WishPluginPackage.encode(value);
    if (bytes.length > 2000000) throw StateError('release-exceeds-limit');
    await WishDevice.call(
      'files.export',
      work: widget.project.id,
      args: {
        'name': '${WishPackageIdentity.resolve(value).title.replaceAll(RegExp(r'[\\/:*?"<>|]'), "_")}.tgz',
        'mime': 'application/gzip',
        'data': base64Encode(bytes),
      },
    );
  });
  Future<void> _restore(Map<String, dynamic> row) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appL10n.wishRestoreVersion),
        content: Text(appL10n.wishRestoreVersionHelp),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishClose)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishRestoreVersion)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final driver = WishClientReleaseDriver(
      _client,
      open: (restart) => WishAppRuntime.connect(container, widget.project.profile, restart: restart),
    );
    await _run(() async {
      try {
        await WishReleaseRestorer(driver).restore(widget.project.id, row['hash'] as String);
      } finally {
        _client = driver.client;
      }
    }, lock: false);
    if (_error == null && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.wishVersions,
    children: [
      Text(appL10n.wishVersionsHelp, style: const TextStyle(color: wishText2)),
      const SizedBox(height: 20),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
      FilledButton.icon(
        onPressed: _busy ? null : _checkpoint,
        icon: const Icon(Icons.bookmark_add_outlined),
        label: Text(appL10n.wishCheckpoint),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _busy ? null : _export,
        icon: const Icon(Icons.ios_share),
        label: Text(appL10n.wishExportWork),
      ),
      const SizedBox(height: 20),
      if (_rows.isEmpty) Text(appL10n.wishNoVersions, style: const TextStyle(color: wishText2)),
      for (final row in _rows)
        WishCard(
          children: [
            ListTile(
              title: Text('${row['version']}'),
              subtitle: Text(
                '${row['createdAt'] ?? ''}\n${row['files']} files · ${((row['bytes'] as num? ?? 0) / 1024).ceil()} KB',
              ),
              isThreeLine: true,
              trailing: IconButton(
                onPressed: _busy ? null : () => _restore(row),
                tooltip: appL10n.wishRestoreVersion,
                icon: const Icon(Icons.restore),
              ),
            ),
          ],
        ),
    ],
  );
}
