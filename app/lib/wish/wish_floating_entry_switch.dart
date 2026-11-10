import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_palette.dart';

/// Controls the actual shared entry, independently of a work's WebView.
/// Permission and visibility remain distinct facts supplied by Android.
class WishFloatingEntrySwitch extends StatefulWidget {
  const WishFloatingEntrySwitch({super.key, required this.requestPermission, this.waitForSystemResume = false});
  final Future<void> Function() requestPermission;
  final bool waitForSystemResume;

  @override
  State<WishFloatingEntrySwitch> createState() => _WishFloatingEntrySwitchState();
}

class _WishFloatingEntrySwitchState extends State<WishFloatingEntrySwitch> {
  bool _shown = false, _busy = false, _pending = false;
  String? _notice;
  int _revision = 0;
  late final _life = AppLifecycleListener(onResume: _resumed);

  @override
  void initState() {
    super.initState();
    _life;
    WishDevice.entryVisibility.addListener(_changed);
    _refresh();
  }

  void _changed() {
    if (mounted) setState(() => _shown = WishDevice.entryVisibility.value['shown'] == true);
  }

  Future<void> _resumed() async {
    await _refresh();
    if (mounted && _pending) {
      _pending = false;
      setState(() => _notice = appL10n.anySetupOverlayDeferred);
    }
  }

  @override
  void dispose() {
    _revision++;
    _life.dispose();
    WishDevice.entryVisibility.removeListener(_changed);
    super.dispose();
  }

  Future<void> _refresh() async {
    final revision = ++_revision;
    try {
      final access = await WishDevice.status();
      final state = wishMap(await WishDevice.call('actions.state'));
      if (!mounted || revision != _revision) return;
      setState(() => _shown = access['overlay'] == true && state['shown'] == true);
      if (_pending && access['overlay'] == true) {
        _pending = false;
        if (!_shown) await WishDevice.call('actions.show', args: {'userInitiated': true});
        if (mounted) {
          final actual = wishMap(await WishDevice.call('actions.state'));
          if (mounted) setState(() => _shown = actual['shown'] == true);
        }
      }
    } catch (error) {
      if (mounted && revision == _revision) setState(() => _notice = wishErrorText(error));
    }
  }

  Future<void> _toggle(bool show) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      if (show) {
        _pending = true;
        final access = await WishDevice.status();
        if (!mounted) return;
        if (access['overlay'] != true) await widget.requestPermission();
        if (!mounted) return;
        await _refresh();
        if (mounted && _pending && !widget.waitForSystemResume) {
          _pending = false;
          setState(() => _notice = appL10n.anySetupOverlayDeferred);
        }
      } else {
        _pending = false;
        await WishDevice.call('actions.hide', args: {'userInitiated': true});
        await _refresh();
      }
    } catch (error) {
      _pending = false;
      if (mounted) setState(() => _notice = wishErrorText(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SwitchListTile.adaptive(
        key: const ValueKey('global-floating-entry'),
        title: Text(appL10n.wishFloatingEntry),
        subtitle: Text(_shown ? appL10n.wishFloatingVisible : appL10n.anySetupOverlaySwitchHelp),
        value: _shown,
        onChanged: _busy ? null : _toggle,
      ),
      if (_notice != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(_notice!, style: const TextStyle(color: wishText2, height: 1.5)),
        ),
    ],
  );
}
