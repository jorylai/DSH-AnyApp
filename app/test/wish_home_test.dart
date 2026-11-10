import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsh_app/runtime/runtime_bridge.dart';
import 'package:dsh_app/runtime/runtime_state.dart';
import 'package:dsh_app/state/settings_state.dart';
import 'package:dsh_app/wish/wish_home.dart';
import 'package:dsh_app/wish/wish_creator.dart';
import 'package:dsh_app/wish/wish_food_ai.dart';
import 'package:dsh_app/wish/wish_store.dart';
import 'package:dsh_app/wish/wish_settings.dart';
import 'package:dsh_app/ui/theme/theme.dart';
import 'package:dsh_app/wish/wish_web_bridge.dart';
import 'package:dsh_app/wish/wish_preset_bootstrap.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_gallery.dart';
import 'package:dsh_app/ui/web/web_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('the wall hides only recorded old starter copies and keeps both original works on disk', (tester) async {
    final support = Directory.systemTemp.createTempSync('anyapp-starter-wall-');
    const paths = MethodChannel('plugins.flutter.io/path_provider');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(paths, (_) async => support.path);
    messenger.setMockMethodCallHandler(WishDevice.channel, (call) async {
      if (call.method == 'works.all') return <String, dynamic>{};
      if (call.method == 'works.describe') return <String, dynamic>{};
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(paths, null);
      messenger.setMockMethodCallHandler(WishDevice.channel, null);
      support.deleteSync(recursive: true);
    });
    final projects = File('${support.path}/runtime/rootfs/root/.dsh/wish/projects.json');
    projects.parent.createSync(recursive: true);
    final source = jsonEncode([
      {'id': 'local-builtin-voyo', 'title': 'Voyo Trip 示例', 'state': 'published'},
      {'id': 'local-builtin-calorie', 'title': '热量教练示例', 'state': 'published'},
      {'id': 'local-voyo-original', 'title': 'Voyo Trip 原作', 'state': 'published'},
      {'id': 'local-hnyg9h8gg9-10nd8po', 'title': '热量教练原作', 'state': 'published'},
    ]);
    projects.writeAsStringSync(source);
    SharedPreferences.setMockInitialValues({
      WishPresetBootstrap.preferenceKey: jsonEncode({
        'version': 2,
        'mode': 'skipped',
        'ids': <String, dynamic>{},
        'progress': <String, dynamic>{},
        'legacyPlan': {
          'version': 1,
          'mode': 'complete',
          'ids': {'voyo': 'local-builtin-voyo', 'calorie': 'local-builtin-calorie'},
          'progress': <String, dynamic>{},
        },
      }),
    });
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: WishHomePage())));
    // Filesystem completions use the real event loop; each pump also releases
    // the mocked preference/platform futures awaited between file reads.
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(() async => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
      if (tester.widget<WishGallery>(find.byType(WishGallery)).items.isNotEmpty) break;
    }
    await tester.pumpAndSettle();
    final wall = tester.widget<WishGallery>(find.byType(WishGallery));
    expect(wall.error, isNull);
    expect(wall.items.map((item) => item.id).toSet(), {'local-voyo-original', 'local-hnyg9h8gg9-10nd8po'});
    expect(wall.items.map((item) => item.title).toSet(), {'Voyo Trip 原作', '热量教练原作'});
    expect(projects.readAsStringSync(), source);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Wish settings expose product pages and direct AI policy without a copied chat shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildDarkTheme(glassBlur: false, instantPages: true), home: const WishSettingsPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('模型账号'), findsWidgets);
    expect(find.text('公共手机能力'), findsOneWidget);
    expect(find.text('DSH 对话'), findsNothing);
    expect(find.text('API Key / 模型 / 余额'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test('Creator receives real capability facts and the shipped design kit contract', () {
    final brief = buildWishBrief('做一个手机助手', capabilities: {'accessibilityConnected': true, 'aiDirect': true});
    expect(brief, contains('"accessibilityConnected":true'));
    expect(brief, contains('/opt/dsh-app/wish-design/CREATOR.md'));
    expect(brief, contains('window.dshWish.ui'));
    expect(brief, contains('不再逐次弹出 AI 发送确认'));
    expect(brief, isNot(contains('宿主会显示发送确认')));
  });
  test('an auto-start during a transition keeps the requested form profile', () async {
    final bridge = _ProfileBridge();
    final container = ProviderContainer(
      overrides: [runtimeBridgeProvider.overrideWithValue(bridge), settingsProvider.overrideWith(_LoadedSettings.new)],
    );
    addTearDown(container.dispose);
    final runtime = container.read(localRuntimeProvider.notifier);
    container.read(localRuntimeProfileProvider.notifier).select('app-local-test');
    await runtime.start();
    await runtime.start();
    expect(bridge.profiles, ['app-local-test', 'app-local-test']);
    await runtime.start(profile: 'web');
    expect(container.read(localRuntimeProfileProvider), 'web');
  });
  testWidgets('wall removes unused food template and exposes persistent sorting', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: WishHomePage())));
    await tester.pumpAndSettle();
    expect(find.text('食物相机'), findsNothing);
    expect(find.text('最新添加'), findsOneWidget);
    await tester.tap(find.byTooltip('作品排序'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: find.text('最近使用'), matching: find.byWidgetPredicate((widget) => widget is PopupMenuEntry)),
    );
    await tester.pumpAndSettle();
    expect((await SharedPreferences.getInstance()).getString('wish-wall-sort'), 'recent');
    expect(find.text('待安装'), findsNothing);
    expect(find.text('420 kcal'), findsNothing);
    expect(find.text('今日饮食'), findsNothing);
    expect(find.text('开始创造'), findsOneWidget);
    expect(find.text('DSH Creator 作品'), findsNothing);
  });
  test('non-Latin requests get distinct host-issued IDs and retain their intent', () {
    final ids = List.generate(500, (_) => newWishId());
    expect(ids.toSet().length, ids.length);
    expect(ids.every((id) => RegExp(r'^local-[a-z0-9-]+$').hasMatch(id)), isTrue);
    final brief = buildWishBrief('做一个太空主题的聊天伙伴', id: ids.first);
    expect(brief, contains('做一个太空主题的聊天伙伴'));
    expect(brief, isNot(contains('"name": "食物相机"')));
    expect(brief, contains('app-${ids.first}'));
    expect(brief, contains('完整 DSH Web Client'));
    expect(brief, isNot(contains('组件只支持 text、input')));
    expect(brief, contains('window.dshWish'));
  });
  test('Creator plugin panels survive target serialization and external pages cannot match the bridge origin', () {
    final target = DshWebTarget(customPanel: 'local-plants', panelLabel: 'Rainforest');
    expect(target.toJson()['panel'], 'local-plants');
    expect(target.inSession('session-a').toJson()['panelLabel'], 'Rainforest');
    expect(target.isHome, false);
    final base = Uri.parse('http://127.0.0.1:3080');
    expect(WishWebBridge.sameOrigin(base, 'http://127.0.0.1:3080/'), true);
    expect(WishWebBridge.sameOrigin(base, 'http://127.0.0.1:3081/'), false);
    expect(WishWebBridge.sameOrigin(base, 'https://example.com/'), false);
    expect(WishWebBridge.sameOrigin(base, 'file:///data/private'), false);
  });
  test('recognition derives total from items and flags uncertain output', () {
    final result = FoodRecognition.fromJson({
      'items': [
        {'name': 'rice', 'kcal': 174, 'staple': true},
      ],
      'totalKcal': 999,
      'confidence': 0.2,
    });
    expect(result.totalKcal, 174);
    expect(result.needsManual, isTrue);
    expect(
      () => FoodRecognition.fromJson({
        'items': [
          {'name': 'bad', 'kcal': -1},
        ],
      }),
      throwsFormatException,
    );
  });
  test('vision cache is isolated by form, model, hint and locale', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final baseline = FoodVision.cacheId(bytes);
    expect(FoodVision.cacheId(bytes), baseline);
    expect(FoodVision.cacheId(bytes, namespace: 'local-other'), isNot(baseline));
    expect(FoodVision.cacheId(bytes, model: 'different'), isNot(baseline));
    expect(FoodVision.cacheId(bytes, portionHint: 'half'), isNot(baseline));
    expect(FoodVision.cacheId(bytes, locale: 'en'), isNot(baseline));
  });
  test('a cache miss cannot upload without explicit consent', () async {
    SharedPreferences.setMockInitialValues({});
    await expectLater(
      FoodVision.recognize(jpeg: Uint8List(3), complete: (_, _) async => throw StateError('must-not-upload')),
      throwsStateError,
    );
  });
  test('empty and legacy records never create a fictitious breakfast today', () {
    expect(WishData.seeded().foodKcal, 0);
    expect(WishData.fromJson({'food': []}).food, isEmpty);
    expect(
      WishData.fromJson({
        'food': [
          {'name': 'undated history', 'kcal': 420},
        ],
      }).foodKcal,
      0,
    );
  });
}

class _LoadedSettings extends SettingsController {
  @override
  AppSettings build() => const AppSettings(loaded: true);
}

class _ProfileBridge extends RuntimeBridge {
  final profiles = <String?>[];
  @override
  Stream<RuntimeEvent> get events => const Stream.empty();
  @override
  Future<RuntimeStatus> status() async => const RuntimeStatus(phase: RuntimePhase.installed);
  @override
  Future<RuntimeLogSnapshot> logSnapshot({int lines = 300}) async => const RuntimeLogSnapshot([], 0);
  @override
  Future<void> start({
    Map<String, String> env = const {},
    bool phoneStorage = false,
    EngineMode? mode,
    bool visualReplies = true,
    String? profile,
  }) async {
    profiles.add(profile);
  }
}
