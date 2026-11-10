import 'dart:io';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';
import '../analytics/anyapp_analytics.dart';
import 'wish_app_runtime.dart';
import 'wish_models.dart';
import 'wish_form.dart';
import 'wish_home.dart';

/// A small declarative native surface. No generated Dart/HTML is executed.
class WishSurfacePage extends StatefulWidget {
  const WishSurfacePage({super.key, required this.form, this.preview = false});
  final WishForm form;
  final bool preview;
  @override
  State<WishSurfacePage> createState() => _WishSurfacePageState();
}

class _WishSurfacePageState extends State<WishSurfacePage> {
  final _data = <String, dynamic>{};
  final _inputs = <String, TextEditingController>{};
  DshClient? _client;
  XFile? _photo;
  bool _busy = true, _ready = false;
  String? _error;
  late final _container = ProviderScope.containerOf(context, listen: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final c in _inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final analytics = _container.read(anyappAnalyticsProvider.notifier);
    final timer = Stopwatch()..start();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _client = await WishAppRuntime.connect(_container, widget.form.profile);
      final health = wishMap(await _client!.rpc.call('appForm/health', {'form': widget.form.id}));
      if (health['ready'] != true) throw StateError('form-health-failed');
      await _invoke(widget.form.view['load'] as String, depth: 0, effectsAllowed: false);
      _ready = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          analytics.track(
            AnyappEvent.workReady,
            page: AnyappPage.work,
            outcome: AnyappOutcome.success,
            elapsed: timer.elapsed,
          );
      });
    } catch (e) {
      analytics.track(
        AnyappEvent.workReady,
        page: AnyappPage.work,
        outcome: AnyappOutcome.failure,
        elapsed: timer.elapsed,
      );
      _error = wishErrorText(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(String action) async {
    if (_busy || _client == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _invoke(action, depth: 0, effectsAllowed: true);
    } catch (e) {
      _error = wishErrorText(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invoke(
    String action, {
    required int depth,
    required bool effectsAllowed,
    Map<String, dynamic>? extra,
  }) async {
    if (depth > 2) throw StateError('too-many-effects');
    final actions = wishMap(wishMap(widget.form.manifest['surface'])['dsh'])['actions'] as List;
    if (!actions.contains(action)) throw StateError('undeclared-action');
    final args = {
      ..._data,
      for (final e in _inputs.entries) e.key: e.value.text,
      'today': DateTime.now().toIso8601String().substring(0, 10),
      ...?extra,
    };
    args.remove('effects');
    args.remove('photo');
    final reply = wishMap(
      await _client!.rpc.call('appForm/invoke', {
        'form': widget.form.id,
        'action': action,
        'args': args,
      }, const Duration(seconds: 50)),
    );
    final effects = reply.remove('effects');
    if (!mounted) return;
    setState(() {
      _data.addAll(reply);
      for (final e in _inputs.entries) {
        if (reply.containsKey(e.key)) e.value.text = '${reply[e.key] ?? ''}';
      }
      if (reply.containsKey('photo') && reply['photo'] == null) _photo = null;
    });
    if (effects is List && effects.isNotEmpty) {
      // Startup/refresh must never silently upload anything.
      if (!effectsAllowed || effects.length > 2 || !widget.form.has('ai')) throw StateError('ai-effect-not-authorized');
      for (final raw in effects) {
        final effect = wishMap(raw);
        final result = await _ai(effect);
        if (result == null || !mounted) return;
        await _invoke(effect['then'] as String, depth: depth + 1, effectsAllowed: false, extra: {'result': result});
      }
    }
  }

  Future<Map<String, dynamic>?> _ai(Map<String, dynamic> effect) async {
    if (effect['type'] == 'ai.food') {
      final photo = _photo;
      if (photo == null) throw StateError(appL10n.wishNoPhoto);
      final bytes = await photo.readAsBytes();
      if (!mounted) return null;
      final result = await WishModels.food(_client!, bytes, namespace: widget.form.id, uploadConsent: true);
      return result.toJson().cast<String, dynamic>();
    }
    if (effect['type'] == 'ai.text') {
      final prompt = effect['prompt'];
      final input = effect['input'];
      if (prompt is! String || input is! String || prompt.length > 8000 || input.length > 32000)
        throw StateError('invalid-ai-request');
      return WishModels.complete(_client!, '$prompt\n$input');
    }
    throw StateError(appL10n.wishUnsupported);
  }

  Future<void> _capture() async {
    if (!widget.form.has('camera') || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (mounted && photo != null)
        setState(() {
          _photo = photo;
          _data.remove('items');
          _data.remove('notes');
          for (final c in _inputs.values) {
            c.clear();
          }
        });
    } catch (_) {
      _error = appL10n.wishManual;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _component(Map<String, dynamic> c) {
    final bind = c['bind'] as String?;
    final value = _data[bind];
    return switch (c['type']) {
      'text' => Text('${c['text'] ?? value ?? ''}', style: const TextStyle(color: wishText2)),
      'input' => TextField(
        controller: _inputs.putIfAbsent(bind!, () => TextEditingController(text: '${value ?? ''}')),
        enabled: !_busy,
        keyboardType: c['keyboard'] == 'number' ? TextInputType.number : TextInputType.multiline,
        maxLines: c['keyboard'] == 'number' ? 1 : null,
        decoration: InputDecoration(labelText: '${c['label'] ?? ''}', border: const OutlineInputBorder()),
      ),
      'button' => FilledButton(
        onPressed: _busy || !_ready ? null : () => _run(c['action'] as String),
        child: Text('${c['label'] ?? ''}'),
      ),
      'metric' => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${c['label'] ?? ''}'),
        trailing: Text('${value ?? 0} ${c['unit'] ?? ''}', style: const TextStyle(fontSize: 22)),
      ),
      'camera' => Column(
        children: [
          if (_photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_photo!.path), height: 210, fit: BoxFit.cover),
            )
          else
            Padding(padding: const EdgeInsets.all(24), child: Text(appL10n.wishNoPhoto)),
          OutlinedButton.icon(
            onPressed: _busy ? null : _capture,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(appL10n.wishTakePhoto),
          ),
        ],
      ),
      'list' => _list(c, value),
      _ => Text(appL10n.wishUnsupported),
    };
  }

  Widget _list(Map<String, dynamic> c, Object? value) {
    if (value is! List || value.isEmpty) return Text(appL10n.wishEmpty, style: const TextStyle(color: wishText3));
    final item = wishMap(c['item'] ?? {});
    return Column(
      children: [
        for (final row in value.take(200).whereType<Map>())
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${row[item['title']] ?? ''}'),
            subtitle: item['subtitle'] == null ? null : Text('${row[item['subtitle']] ?? ''}'),
            trailing: item['trailing'] == null ? null : Text('${row[item['trailing']] ?? ''}'),
          ),
      ],
    );
  }

  void _back() => Navigator.of(context).pop(_ready);
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_busy) _back();
    },
    child: Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(
        leading: IconButton(onPressed: _busy ? null : _back, icon: const Icon(Icons.arrow_back)),
        title: Text(widget.form.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: wishWarm)),
            if (!_ready) TextButton(onPressed: _busy ? null : _load, child: Text(appL10n.wishRetry)),
          ],
          for (final c in widget.form.view['components'] as List)
            Padding(padding: const EdgeInsets.only(bottom: 16), child: _component(wishMap(c))),
        ],
      ),
    ),
  );
}
