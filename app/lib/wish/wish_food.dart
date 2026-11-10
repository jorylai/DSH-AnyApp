import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wish_app_runtime.dart';
import 'wish_models.dart';
import 'wish_food_ai.dart';
import '../l10n/l10n.dart';
import 'wish_store.dart';

import 'wish_home.dart';

/// 食物相机：拍照 → 手动/视觉识别 → 热量 → 保存到今日饮食。
/// 没有登录/视觉模型时仍可手动填热量，不伪造识别结果。
class WishFoodPage extends StatefulWidget {
  const WishFoodPage({super.key, this.onSaved});
  final Future<void> Function(int)? onSaved;

  @override
  State<WishFoodPage> createState() => _WishFoodPageState();
}

class _WishFoodPageState extends State<WishFoodPage> {
  final _picker = ImagePicker();
  final _kcal = TextEditingController();
  XFile? _photo;
  bool _busy = false;
  bool _recognizing = false;
  FoodRecognition? _result;
  String? _tip;

  Future<void> _takePhoto() async {
    setState(() {
      _busy = true;
      _tip = null;
    });
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (!mounted) return;
      setState(() {
        if (file != null) {
          _result = null;
          _kcal.clear();
        }
        _photo = file;
        _tip = file == null ? '没有拍照，仍可手动记录。' : '照片只在本机用于这次记录。';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _tip = '相机打不开，可以先手动填热量。');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recognize() async {
    final photo = _photo;
    if (photo == null) {
      setState(() => _tip = '先拍一张照片。');
      return;
    }
    final allowed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appL10n.wishCloudTitle),
        content: Text(appL10n.wishCloudDescription),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishManual)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishCloudAllow)),
        ],
      ),
    );
    if (allowed != true || !mounted) return;
    setState(() {
      _recognizing = true;
      _tip = appL10n.wishBusy;
    });
    try {
      final bytes = await photo.readAsBytes();
      final client = await WishAppRuntime.connect(
        ProviderScope.containerOf(context, listen: false),
        'app-local-food-camera',
      );
      final r = await WishModels.food(client, bytes, namespace: 'local-food-camera', uploadConsent: true);
      if (!mounted) return;
      setState(() {
        _result = r;
        _recognizing = false;
        _tip = r.needsManual ? '没看清，手动改一下热量再保存。' : (r.notes.isEmpty ? '识别结果可改。' : r.notes);
        if (r.totalKcal > 0) _kcal.text = '${r.totalKcal}';
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _recognizing = false;
          _tip = e is StateError ? e.message : '识别失败，手动填热量也行。';
        });
    }
  }

  Future<void> _save() async {
    final n = int.tryParse(_kcal.text.trim()) ?? 0;
    final r = _result;
    final name = (r != null && r.items.isNotEmpty) ? r.items.map((e) => e.name).take(3).join(' + ') : '这一餐';
    if (n <= 0 || n > 5000) {
      setState(() => _tip = '热量填 1–5000 kcal。');
      return;
    }
    if (_busy || _recognizing) return;
    setState(() => _busy = true);
    final items = r != null && r.totalKcal == n
        ? r.items
        : [FoodItem(name: name, amount: 1, unit: '份', kcal: n, staple: false, confidence: 1)];
    try {
      await WishStore.addFood(n, name: name, items: items);
    } catch (_) {
      if (mounted)
        setState(() {
          _busy = false;
          _tip = appL10n.wishFailure;
        });
      return;
    }
    if (!mounted) return;
    await widget.onSaved?.call(n);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('已记下 $n kcal，保存到今日饮食。'), behavior: SnackBarBehavior.floating));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _kcal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(
        backgroundColor: wishBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: wishText,
        title: const Text('食物相机', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        children: [
          Text('拍一张，记下这一餐。', style: TextStyle(color: wishText2, fontSize: 13, height: 1.5)),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: wishSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _photo == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 44, color: wishText3),
                        const SizedBox(height: 12),
                        const Text('还没有照片', style: TextStyle(color: wishText2, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text('支持手动记录，不登录也能用', style: TextStyle(color: wishText3, fontSize: 11)),
                      ],
                    )
                  : Image.file(File(_photo!.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _takePhoto,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(_busy ? '正在打开相机…' : (_photo == null ? '拍照' : '重拍')),
              style: OutlinedButton.styleFrom(
                foregroundColor: wishText,
                side: const BorderSide(color: Color(0x33FFFFFF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _recognizing || _photo == null ? null : _recognize,
              icon: const Icon(Icons.auto_awesome, size: 17),
              label: Text(_recognizing ? '识别中…' : '识别热量'),
              style: FilledButton.styleFrom(
                backgroundColor: wishSurfaceAlt,
                foregroundColor: wishBlue,
                disabledForegroundColor: wishText3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: wishSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x1FFFFFFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in _result!.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text(item.name, style: const TextStyle(color: wishText, fontSize: 12)),
                          if (item.staple)
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text('主食', style: TextStyle(color: wishWarm, fontSize: 9)),
                            ),
                          const Spacer(),
                          Text('${item.kcal} kcal', style: const TextStyle(color: wishText3, fontSize: 11)),
                        ],
                      ),
                    ),
                  if (_result!.staple.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '主食：${_result!.staple.join('、')}',
                        style: const TextStyle(color: wishText2, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            '热量',
            style: TextStyle(color: wishText2, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _kcal,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: wishText, fontSize: 24, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              suffixText: 'kcal',
              suffixStyle: const TextStyle(color: wishText3, fontSize: 13),
              filled: true,
              fillColor: wishSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x24FFFFFF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x24FFFFFF)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('识别结果可改；没有视觉模型时不会自动猜。', style: TextStyle(color: wishText3, fontSize: 11)),
          if (_tip != null) ...[
            const SizedBox(height: 10),
            Text(_tip!, style: const TextStyle(color: wishWarm, fontSize: 12)),
          ],
          const SizedBox(height: 22),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _busy || _recognizing ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: wishBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('保存到今日饮食'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(appL10n.wishCloudDescription, style: TextStyle(color: wishText3, fontSize: 10.5)),
          ),
        ],
      ),
    );
  }
}
