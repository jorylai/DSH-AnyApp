import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// 作品墙的一项 = 一个已安装/内置的 DSH App Form。
/// 页面不硬编码：名称、说明、图标、surface、能力都从 composition 清单来。
class WishComposition {
  const WishComposition({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.surfaceKind,
    required this.entry,
    required this.nativeView,
    required this.dshBundle,
    required this.profile,
    required this.capabilities,
    required this.statusMetric,
    required this.collections,
    required this.namespace,
  });

  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final String surfaceKind;
  final String entry;
  final String nativeView;
  final String dshBundle;
  final String profile;
  final List<String> capabilities;
  final String statusMetric;
  final List<String> collections;
  final String namespace;

  static WishComposition fromJson(Map<String, dynamic> j) => WishComposition(
    id: (j['id'] as String?) ?? 'local-app',
    name: (j['name'] as String?) ?? '未命名',
    subtitle: (j['subtitle'] as String?) ?? '',
    icon: (j['icon'] as String?) ?? 'app',
    surfaceKind: ((j['surface'] as Map?)?['kind'] as String?) ?? 'native-m3',
    entry: ((j['surface'] as Map?)?['native'] as Map?)?['entry'] as String? ?? '',
    nativeView: ((j['surface'] as Map?)?['native'] as Map?)?['view'] as String? ?? '',
    dshBundle: ((j['surface'] as Map?)?['dsh'] as Map?)?['bundle'] as String? ?? '',
    profile: ((j['runtime'] as Map?)?['profile'] as String?) ?? '',
    capabilities: (j['capabilities'] as List?)?.whereType<String>().toList() ?? const [],
    statusMetric: (j['statusMetric'] as String?) ?? '',
    collections: ((j['data'] as Map?)?['collections'] as List?)?.whereType<String>().toList() ?? const [],
    namespace: ((j['data'] as Map?)?['namespace'] as String?) ?? '',
  );

  static Future<List<WishComposition>> loadBundled() async {
    final raw = await rootBundle.loadString('assets/compositions/food-camera.json');
    final j = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return [WishComposition.fromJson(j)];
  }
}
