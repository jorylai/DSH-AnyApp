import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

const foodVisionPromptVersion = 'food-vision-v2';
const foodVisionPrompt = '''
你是食物热量识别器。分析图片中的食物，输出严格 JSON，不要 markdown、不要解释。
要求：
1. 只列图片里能辨认的食物；看不清就标 confidence 低，不要编造。
2. 区分主食（米饭/面条/面包/馒头等）、蛋白质、蔬菜、饮品、其他。
3. 每项给 name、amount、unit、kcal、staple、confidence（0–1）。
4. totalKcal 必须等于各项 kcal 之和。
5. 份量不确定时给保守估计，并在 notes 说明。
6. 无法识别时：{"items":[],"totalKcal":0,"needsManual":true,"reason":"..."}
7. 只输出 JSON：
{"items":[{"name":"米饭","amount":150,"unit":"g","kcal":174,"staple":true,"confidence":0.82}],"totalKcal":174,"staple":["米饭"],"confidence":0.82,"needsManual":false,"notes":"按常见份量估算"}
''';

class FoodItem {
  const FoodItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.kcal,
    required this.staple,
    required this.confidence,
  });
  final String name;
  final num amount;
  final String unit;
  final int kcal;
  final bool staple;
  final double confidence;

  Map<String, Object?> toJson() => {
    'name': name,
    'amount': amount,
    'unit': unit,
    'kcal': kcal,
    'staple': staple,
    'confidence': confidence,
  };
  static FoodItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final kcal = raw['kcal'];
    if (kcal is! num || !kcal.isFinite || kcal < 0 || kcal > 5000) throw const FormatException('invalid-food-calories');
    return FoodItem(
      name: (raw['name'] as String?)?.trim().isNotEmpty == true ? raw['name'] as String : '食物',
      amount: (raw['amount'] as num?) ?? 0,
      unit: (raw['unit'] as String?) ?? 'g',
      kcal: ((raw['kcal'] as num?) ?? 0).round(),
      staple: raw['staple'] == true,
      confidence: ((raw['confidence'] as num?) ?? 0).toDouble().clamp(0, 1),
    );
  }
}

class FoodRecognition {
  const FoodRecognition({
    required this.items,
    required this.totalKcal,
    required this.staple,
    required this.confidence,
    required this.needsManual,
    required this.notes,
  });
  final List<FoodItem> items;
  final int totalKcal;
  final List<String> staple;
  final double confidence;
  final bool needsManual;
  final String notes;

  Map<String, Object?> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'totalKcal': totalKcal,
    'staple': staple,
    'confidence': confidence,
    'needsManual': needsManual,
    'notes': notes,
    'promptVersion': foodVisionPromptVersion,
  };

  static FoodRecognition fromJson(Map<String, dynamic> j) {
    final items = (j['items'] as List?)?.map(FoodItem.fromJson).whereType<FoodItem>().toList() ?? const [];
    final sum = items.fold(0, (s, e) => s + e.kcal);
    return FoodRecognition(
      items: items,
      totalKcal: sum,
      staple: items.where((e) => e.staple).map((e) => e.name).toList(),
      confidence: ((j['confidence'] as num?) ?? 0).toDouble().clamp(0, 1),
      needsManual: j['needsManual'] == true || items.isEmpty || ((j['confidence'] as num?) ?? 0) < 0.6,
      notes: (j['notes'] as String?) ?? '',
    );
  }
}

class FoodVision {
  static const _cacheKey = 'wish.food.ai.cache.v2';

  static String hashImage(Uint8List bytes) => sha256.convert(bytes).toString();

  static String cacheId(
    Uint8List bytes, {
    String namespace = 'local-food-camera',
    String model = 'deepseek-flash',
    String? portionHint,
    String? locale,
  }) =>
      '$namespace:${sha256.convert(utf8.encode(jsonEncode([hashImage(bytes), foodVisionPromptVersion, model, portionHint?.trim() ?? '', locale ?? 'zh-CN'])))}';

  static Future<void> clearForForm(String namespace) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return;
    final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
    map.removeWhere((key, value) => key.startsWith('$namespace:'));
    await prefs.setString(_cacheKey, jsonEncode(map));
  }

  static Future<FoodRecognition?> cached(String hash) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
      final item = map[hash];
      if (item is! Map) return null;
      final at = DateTime.tryParse('${item['at']}');
      if (at == null ||
          DateTime.now().difference(at).isNegative ||
          DateTime.now().difference(at) >= const Duration(days: 30))
        return null;
      final data = item['data'];
      if (data is! Map) return null;
      return FoodRecognition.fromJson(data.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  static Future<void> storeCache(String hash, FoodRecognition r) async {
    final p = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {};
    try {
      final raw = p.getString(_cacheKey);
      if (raw != null) map = (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {}
    map[hash] = {'at': DateTime.now().toIso8601String(), 'data': r.toJson()};
    // Keep the cache small; drop oldest keys beyond 40 entries.
    if (map.length > 40) {
      final keys = map.keys.toList()..sort((a, b) => '${map[b]['at']}'.compareTo('${map[a]['at']}'));
      for (final k in keys.skip(40)) {
        map.remove(k);
      }
    }
    await p.setString(_cacheKey, jsonEncode(map));
  }

  /// 上传压缩后的图片到 DeepSeek，拿结构化结果。图片只在用户点「识别」后上传。
  static Future<FoodRecognition> recognize({
    required Uint8List jpeg,
    required Future<String> Function(String prompt, Uint8List image) complete,
    String model = 'dsh-default',
    String? portionHint,
    String? locale,
    String namespace = 'local-food-camera',
    bool uploadConsent = false,
  }) async {
    final hash = cacheId(jpeg, namespace: namespace, model: model, portionHint: portionHint, locale: locale);
    final hit = await cached(hash);
    if (hit != null) return hit;
    if (!uploadConsent) throw StateError('image-upload-not-approved');
    final hint = (portionHint == null || portionHint.trim().isEmpty) ? '' : '用户给的份量提示：${portionHint.trim()}\n';
    final content = await complete('$foodVisionPrompt\n${hint}语言：${locale ?? 'zh-CN'}。', jpeg);
    final cleaned = content.replaceAll(RegExp(r'^```json\s*|```$', multiLine: true), '').trim();
    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    final result = FoodRecognition.fromJson(parsed);
    await storeCache(hash, result);
    return result;
  }
}
