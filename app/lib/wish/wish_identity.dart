import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'wish_app_runtime.dart';
import 'wish_device.dart';
import 'wish_form.dart';
import 'wish_palette.dart';
import 'wish_models.dart';
import 'wish_project.dart';
import 'wish_icon_art.dart';
import 'wish_icon_designer.dart';
import 'wish_icon_picker.dart';
export 'wish_icon_art.dart' show wishIcons;

class WishIdentity {
  const WishIdentity(this.value);
  final Map<String, dynamic> value;
  String name(String fallback) {
    for (final key in ['customName', 'title']) {
      final text = value[key];
      if (text is String && text.trim().isNotEmpty) return text;
    }
    return fallback;
  }

  Map<String, dynamic> get icon => wishMap(value['icon'] ?? value['declaredIcon'] ?? {});
  static Future<Map<String, WishIdentity>> all() async {
    final result = await WishDevice.call<Map>('works.all') ?? {};
    return {for (final e in result.entries) e.key as String: WishIdentity(wishMap(e.value))};
  }

  static Future<WishIdentity> get(String work) async =>
      WishIdentity(wishMap(await WishDevice.call('works.get', work: work)));
}

class WishIdentityIcon extends StatelessWidget {
  static final _bitmaps = <String, MemoryImage>{};
  static MemoryImage _bitmap(String data) {
    final cached = _bitmaps.remove(data);
    if (cached != null) {
      _bitmaps[data] = cached;
      return cached;
    }
    final image = MemoryImage(base64Decode(data));
    _bitmaps[data] = image;
    if (_bitmaps.length > 12) _bitmaps.remove(_bitmaps.keys.first);
    return image;
  }

  const WishIdentityIcon({super.key, this.icon = const {}, this.size = 44});
  final Map<String, dynamic> icon;
  final double size;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .28),
    child: SizedBox.square(
      dimension: size,
      child: icon['bitmap'] is String
          ? Image(
              image: _bitmap(icon['bitmap'] as String),
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              errorBuilder: (_, e, stack) => const Icon(Icons.auto_awesome_outlined),
            )
          : icon['paths'] is List
          ? CustomPaint(painter: _VectorIcon(icon))
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      (wishIconPalettes[icon['palette']] ?? wishIconPalettes['indigo']!)[0],
                      (wishIconPalettes[icon['palette']] ?? wishIconPalettes['indigo']!)[2],
                      .3,
                    )!,
                    (wishIconPalettes[icon['palette']] ?? wishIconPalettes['indigo']!)[0],
                  ],
                ),
                border: Border.all(color: const Color(0x26C7D4FF)),
                borderRadius: BorderRadius.circular(size * .28),
              ),
              child: Icon(
                wishIcons[icon['builtin']] ?? wishIcons['spark'],
                color: (wishIconPalettes[icon['palette']] ?? wishIconPalettes['indigo']!)[1],
                size: size * .52,
              ),
            ),
    ),
  );
}

class _VectorIcon extends CustomPainter {
  _VectorIcon(this.data);
  final Map<String, dynamic> data;
  Color color(String key, Color fallback) {
    final text = data[key];
    return text is String && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(text)
        ? Color(int.parse('ff${text.substring(1)}', radix: 16))
        : fallback;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color('background', wishSurfaceAlt));
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    for (final raw in (data['paths'] as List).take(16)) {
      final row = wishMap(raw), points = row['points'] as List? ?? [];
      final path = Path();
      for (var i = 0; i < math.min(points.length, 96); i++) {
        final xy = points[i] as List;
        final x = (xy[0] as num).toDouble(), y = (xy[1] as num).toDouble();
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      if (row['closed'] == true) path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color('color', wishText)
          ..style = row['filled'] == true ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = (row['width'] as num? ?? 3).toDouble()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VectorIcon oldDelegate) => oldDelegate.data != data;
}

class WishIdentityPage extends StatefulWidget {
  const WishIdentityPage({super.key, required this.project});
  final WishProject project;
  @override
  State<WishIdentityPage> createState() => _WishIdentityPageState();
}

class _WishIdentityPageState extends State<WishIdentityPage> {
  final _name = TextEditingController();
  final _design = TextEditingController();
  Map<String, dynamic> _icon = {};
  Map<String, dynamic>? _aiStyle;
  bool _busy = false, _loaded = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final identity = await WishIdentity.get(widget.project.id);
      if (!mounted) return;
      setState(() {
        _name.text = identity.name(widget.project.title);
        _icon = identity.icon;
        _loaded = true;
      });
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _design.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final client = await WishAppRuntime.connect(
        ProviderScope.containerOf(context, listen: false),
        widget.project.profile,
      );
      await WishModels.ready(client);
      final response = await WishModels.complete(
        client,
        WishIconDesigner.prompt(
          name: _name.text,
          purpose: widget.project.request.substring(0, math.min(widget.project.request.length, 600)),
          request: _design.text,
          previous: _aiStyle,
        ),
      );
      final style = WishIconDesigner.parse('${response['text'] ?? ''}');
      final rendered = await WishIconArt.render(style);
      final icon = wishMap(await WishDevice.call('icon.validate', args: {'value': rendered}));
      if (!mounted) return;
      final apply = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          scrollable: true,
          title: Text(appL10n.wishIconPreview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WishIdentityIcon(icon: icon, size: 112),
              const SizedBox(height: 20),
              Text(appL10n.wishAiIconPreviewHint, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishApplyIcon)),
          ],
        ),
      );
      if (apply == true && mounted) {
        setState(() {
          _icon = icon;
          _aiStyle = style;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e is FormatException ? appL10n.wishAiIconInvalid : wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _browse() async {
    FocusScope.of(context).unfocus();
    final icon = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => WishIconPickerPage(initialIcon: _icon)),
    );
    if (icon != null && mounted) {
      setState(() {
        _icon = icon;
        _error = null;
      });
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await WishDevice.call(
        'works.update',
        work: widget.project.id,
        args: {
          'value': {'customName': _name.text.trim(), if (_icon.isNotEmpty) 'icon': _icon},
        },
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = wishErrorText(e);
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: wishBg,
    appBar: AppBar(
      title: Text(appL10n.wishIdentity),
      actions: [TextButton(onPressed: _loaded && !_busy ? _save : null, child: Text(appL10n.wishSaveIdentity))],
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF203252), Color(0xFF111D33)],
              ),
              border: Border.all(color: const Color(0x293F68AA)),
            ),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: WishIdentityIcon(key: ValueKey(_icon['bitmap'] ?? _icon.toString()), icon: _icon, size: 96),
                ),
                const SizedBox(height: 18),
                Text(appL10n.wishIconPersonalize, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  appL10n.wishIconPersonalizeHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: wishText2, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            maxLength: 80,
            enabled: _loaded && !_busy,
            decoration: InputDecoration(
              labelText: appL10n.wishWorkName,
              helperText: appL10n.wishNamePriority,
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loaded && !_busy ? _browse : null,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16)),
            icon: const Icon(Icons.emoji_emotions_outlined),
            label: Text(appL10n.wishBrowseIcons),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, color: wishBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(appL10n.wishAiIconTitle, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Text(appL10n.wishAiIconHint, style: const TextStyle(color: wishText2, height: 1.5)),
          const SizedBox(height: 16),
          TextField(
            controller: _design,
            enabled: _loaded && !_busy,
            maxLength: 200,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: appL10n.wishAiIconPrompt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          FilledButton.icon(
            onPressed: _loaded && !_busy ? _generate : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_busy ? appL10n.wishAiIconGenerating : appL10n.wishRegenerateIcon),
          ),
          if (_busy) const Padding(padding: EdgeInsets.all(20), child: LinearProgressIndicator()),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_error!, style: const TextStyle(color: wishWarm)),
            ),
        ],
      ),
    ),
  );
}
