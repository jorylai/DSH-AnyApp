import 'dart:convert';

import 'wish_food_ai.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FoodEntry {
  FoodEntry(this.name, this.kcal, {DateTime? createdAt, this.items = const []})
    : createdAt = createdAt ?? DateTime.now();
  final String name;
  final int kcal;
  final DateTime createdAt;
  final List<FoodItem> items;
  bool isOn(DateTime day) => createdAt.year == day.year && createdAt.month == day.month && createdAt.day == day.day;
  Map<String, Object?> toJson() => {
    'name': name,
    'kcal': kcal,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'staple': items.where((e) => e.staple).map((e) => e.name).toList(),
  };
  static FoodEntry fromJson(Map<String, dynamic> j) => FoodEntry(
    j['name'] as String? ?? '一餐',
    (j['kcal'] as num?)?.round() ?? 0,
    createdAt: DateTime.tryParse('${j['createdAt']}') ?? DateTime.fromMillisecondsSinceEpoch(0),
    items: (j['items'] as List?)?.map(FoodItem.fromJson).whereType<FoodItem>().toList() ?? const [],
  );
}

class WishData {
  WishData({
    required this.food,
    required this.water,
    required this.contacts,
    required this.ledger,
    required this.medicine,
    required this.reading,
    required this.timerSeconds,
  });

  final List<FoodEntry> food;
  final int water;
  final List<String> contacts;
  final List<String> ledger;
  final String medicine;
  final int reading;
  final int timerSeconds;

  int get foodKcal => food.where((e) => e.isOn(DateTime.now())).fold(0, (s, e) => s + e.kcal);
  int get ledgerCents => ledger.fold(0, (s, e) => s + ((int.tryParse(e) ?? 0) * 100));

  WishData copyWith({
    List<FoodEntry>? food,
    int? water,
    List<String>? contacts,
    List<String>? ledger,
    String? medicine,
    int? reading,
    int? timerSeconds,
  }) => WishData(
    food: food ?? this.food,
    water: water ?? this.water,
    contacts: contacts ?? this.contacts,
    ledger: ledger ?? this.ledger,
    medicine: medicine ?? this.medicine,
    reading: reading ?? this.reading,
    timerSeconds: timerSeconds ?? this.timerSeconds,
  );

  Map<String, Object?> toJson() => {
    'food': food.map((e) => e.toJson()).toList(),
    'water': water,
    'contacts': contacts,
    'ledger': ledger,
    'medicine': medicine,
    'reading': reading,
    'timer': timerSeconds,
  };

  static WishData seeded() => WishData(
    food: const [],
    water: 5,
    contacts: const ['王总', '李姐', '陈工'],
    ledger: const ['128', '56', '240'],
    medicine: '20:00',
    reading: 3,
    timerSeconds: 1500,
  );

  static WishData fromJson(Map<String, dynamic> j) {
    final food = (j['food'] as List?)
        ?.whereType<Map>()
        .map((e) => FoodEntry.fromJson(e.cast<String, dynamic>()))
        .toList();
    return WishData(
      food: food ?? const [],
      water: (j['water'] as num?)?.round() ?? 5,
      contacts: (j['contacts'] as List?)?.whereType<String>().toList() ?? const ['王总', '李姐', '陈工'],
      ledger: (j['ledger'] as List?)?.whereType<String>().toList() ?? const ['128', '56', '240'],
      medicine: (j['medicine'] as String?) ?? '20:00',
      reading: (j['reading'] as num?)?.round() ?? 3,
      timerSeconds: (j['timer'] as num?)?.round() ?? 1500,
    );
  }
}

/// 作品数据：只在本机 SharedPreferences，不上传。
class WishStore {
  static const _key = 'wish.state.v1';
  static SharedPreferences? _prefs;
  static WishData? _cached;

  static Future<SharedPreferences> _p() async => _prefs ??= await SharedPreferences.getInstance();

  static Future<WishData> load() async {
    if (_cached != null) return _cached!;
    final raw = (await _p()).getString(_key);
    if (raw == null) return _cached = WishData.seeded();
    try {
      return _cached = WishData.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return _cached = WishData.seeded();
    }
  }

  static Future<WishData> save(WishData data) async {
    final saved = await (await _p()).setString(_key, jsonEncode(data.toJson()));
    if (!saved) throw StateError('save-failed');
    _cached = data;
    return data;
  }

  static Future<WishData> addFood(int kcal, {String name = '这一餐', List<FoodItem> items = const []}) async {
    final d = await load();
    return save(
      d.copyWith(
        food: [
          ...d.food,
          FoodEntry(name, kcal, items: items),
        ],
      ),
    );
  }

  static Future<WishData> addWater(int delta) async {
    final d = await load();
    return save(d.copyWith(water: (d.water + delta).clamp(0, 20)));
  }

  static Future<WishData> addContact(String name) async {
    final d = await load();
    if (name.trim().isEmpty) return d;
    return save(d.copyWith(contacts: [...d.contacts, name.trim()]));
  }

  static Future<WishData> markContactDone() async {
    final d = await load();
    if (d.contacts.isEmpty) return d;
    return save(d.copyWith(contacts: d.contacts.sublist(1)));
  }

  static Future<WishData> addLedger(String amount) async {
    final d = await load();
    final n = int.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (n <= 0) return d;
    return save(d.copyWith(ledger: [...d.ledger, '$n']));
  }

  static Future<WishData> setMedicine(String time) async {
    final d = await load();
    return save(d.copyWith(medicine: time));
  }

  static Future<WishData> addReading() async {
    final d = await load();
    return save(d.copyWith(reading: d.reading + 1));
  }

  static Future<WishData> setTimer(int seconds) async {
    final d = await load();
    return save(d.copyWith(timerSeconds: seconds));
  }

  static Future<WishData> reset() async {
    _cached = WishData.seeded();
    await (await _p()).remove(_key);
    return _cached!;
  }
}
