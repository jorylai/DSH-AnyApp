import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'wish_app_runtime.dart';
import 'wish_form.dart';
import 'wish_home.dart';
import 'wish_surface.dart';

class WishInstallPage extends StatefulWidget {
  const WishInstallPage({super.key, required this.formId});
  final String formId;
  @override
  State<WishInstallPage> createState() => _WishInstallPageState();
}

class _WishInstallPageState extends State<WishInstallPage> {
  WishForm? _form;
  bool _busy = true, _installed = false, _previewed = false, _accepted = false;
  String? _error;
  String _progress = '';
  String _componentLabel(Map raw) =>
      '${raw['label'] ?? raw['text'] ?? switch (raw['type']) {
            'camera' => appL10n.wishCamera,
            'list' => appL10n.wishReviewList,
            'text' => appL10n.wishReviewStatus,
            'metric' => appL10n.wishReviewMetric,
            _ => appL10n.wishReviewInput,
          }}';
  late final _container = ProviderScope.containerOf(context, listen: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final form = await WishFormInstaller(_container).prepare(widget.formId);
      if (mounted) setState(() => _form = form);
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _install() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await WishFormInstaller(_container).install(_form!, (p) {
        if (mounted) setState(() => _progress = p);
      });
      if (mounted) setState(() => _installed = true);
    } catch (e) {
      // A failed candidate never enters the catalog. Return the engine to its
      // base profile, leaving the previous accepted works untouched.
      try {
        await WishAppRuntime.connect(_container, 'web');
      } catch (_) {}
      if (mounted) setState(() => _error = '${appL10n.wishFailure} ${e is StateError ? e.message : e.runtimeType}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (_installed && mounted) await _preview();
  }

  Future<void> _preview() async {
    final opened = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => WishSurfacePage(form: _form!, preview: true)));
    if (mounted && opened == true) setState(() => _previewed = true);
  }

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final client = await WishAppRuntime.connect(_container, _form!.profile);
      await client.rpc.call('appForm/accept', {'form': _form!.id, 'hash': _form!.hash});
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) setState(() => _error = '${appL10n.wishFailure} ${e.runtimeType}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = _form;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: wishBg,
        appBar: AppBar(title: Text(appL10n.wishInstallReview)),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (form != null) ...[
              Text(form.name, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('${form.manifest['subtitle'] ?? ''}'),
              const SizedBox(height: 20),
              for (final raw in form.view['components'] as List)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.widgets_outlined),
                  title: Text(_componentLabel(raw as Map)),
                ),
              const Divider(),
              Text(
                '${appL10n.wishModules}: ${(form.manifest['capabilities'] as List).map((c) => c == 'camera' ? appL10n.wishCamera : appL10n.wishAi).join(', ')}',
              ),
              ExpansionTile(title: const Text('SHA-256'), children: [SelectableText(form.hash)]),
              const SizedBox(height: 16),
              Text(_installed ? appL10n.wishAcceptHelp : appL10n.wishInstallWarning),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_error!, style: const TextStyle(color: wishWarm)),
              ),
            if (_busy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              Text('${form == null ? appL10n.wishPreparing : appL10n.wishInstalling} $_progress'),
            ],
            if (!_busy && form == null) FilledButton(onPressed: _prepare, child: Text(appL10n.wishRetry)),
            if (!_busy && form != null && !_installed)
              FilledButton(onPressed: _install, child: Text(appL10n.wishInstallPreview)),
            if (!_busy && _installed) ...[
              OutlinedButton(onPressed: _preview, child: Text(appL10n.wishReopen)),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(appL10n.wishAcceptCheck),
                value: _accepted,
                onChanged: _previewed ? (v) => setState(() => _accepted = v == true) : null,
              ),
              FilledButton(onPressed: _accepted && _previewed ? _accept : null, child: Text(appL10n.wishAccept)),
            ],
          ],
        ),
      ),
    );
  }
}
