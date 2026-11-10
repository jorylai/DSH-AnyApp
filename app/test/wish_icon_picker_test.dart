import 'dart:convert';

import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_emoji_catalog.dart';
import 'package:dsh_app/wish/wish_icon_art.dart';
import 'package:dsh_app/wish/wish_icon_picker.dart';
import 'package:dsh_app/wish/wish_identity.dart';
import 'package:dsh_app/wish/wish_project.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await WishEmojiCatalog.load();
  });
  final writes = <Map>[];
  var emojiSupported = true;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    writes.clear();
    emojiSupported = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (
      call,
    ) async {
      final args = (call.arguments as Map?) ?? {};
      switch (call.method) {
        case 'works.get':
          return {
            'customName': '专注',
            'icon': {'builtin': 'timer'},
          };
        case 'icon.emojiSupported':
          return emojiSupported;
        case 'icon.validate':
          return args['value'];
        case 'works.update':
          writes.add(args);
          return args['value'];
        default:
          throw PlatformException(code: 'unexpected-call');
      }
    });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      null,
    ),
  );

  testWidgets('emoji compound and original vector render real PNGs; invalid content rejected', (tester) async {
    for (final style in <Map<String, dynamic>>[
      {'kind': 'emoji', 'emoji': '👩🏽‍🚀', 'palette': 'mint'},
      {
        'kind': 'vector',
        'palette': 'rose',
        'variant': 2,
        'shapes': [
          {'type': 'circle', 'cx': 32, 'cy': 32, 'r': 18, 'fill': 'foreground'},
          {
            'type': 'path',
            'points': [
              [20, 32],
              [29, 41],
              [44, 22],
            ],
            'stroke': 'background',
            'width': 4,
          },
        ],
      },
    ]) {
      final icon = await tester.runAsync(() => WishIconArt.render(style));
      expect(icon!['kind'], style['kind']);
      if (style['emoji'] != null) expect(icon['emoji'], '👩🏽‍🚀');
      final bytes = base64Decode(icon['bitmap'] as String);
      expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect((bytes[18] << 8) | bytes[19], 256);
      expect(bytes.length, lessThan(260000));
    }
    await tester.runAsync(() async {
      await expectLater(WishIconArt.render({'kind': 'emoji', 'emoji': '😀😀'}), throwsStateError);
      await expectLater(WishIconArt.render({'kind': 'emoji', 'emoji': '<script/>'}), throwsStateError);
      await expectLater(
        WishIconArt.render({
          'kind': 'vector',
          'palette': 'mint',
          'variant': 0,
          'shapes': [],
          'url': 'https://example.com',
        }),
        throwsFormatException,
      );
    });
  });

  for (final scenario in [(384.0, 780.0, 1.0, 300.0), (780.0, 360.0, 1.0, 0.0), (320.0, 600.0, 1.7, 240.0)]) {
    testWidgets('library search and input fit ${scenario.$1}x${scenario.$2} text${scenario.$3}', (tester) async {
      tester.view.physicalSize = Size(scenario.$1, scenario.$2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          theme: wishTheme(ThemeData.dark()),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scenario.$3)),
            child: child!,
          ),
          home: const WishIconPickerPage(),
        ),
      );
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(TextField));
      final searchFocus = tester.widget<EditableText>(find.byType(EditableText)).focusNode;
      expect(searchFocus.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.enterText(find.byType(TextField), '猫');
      tester.view.viewInsets = FakeViewPadding(bottom: scenario.$4);
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode, same(searchFocus));
      expect(searchFocus.hasFocus, isTrue, reason: 'Keyboard resize must not replace or unfocus search');
      expect(tester.testTextInput.isVisible, isTrue);
      expect(find.text('使用这个'), findsOneWidget);
      expect(find.text('🐈'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '👩🏽‍🚀');
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is Text && widget.data == '👩🏽‍🚀'), findsOneWidget);
      expect(find.text('😀'), findsNothing);
      // IME candidate-bar and close/reopen transitions must retain the input
      // element, its focus and query even while the surrounding layout changes.
      for (final inset in [0.0, scenario.$4, 0.0]) {
        tester.view.viewInsets = FakeViewPadding(bottom: inset);
        await tester.pump();
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pumpAndSettle();
        final input = tester.widget<EditableText>(find.byType(EditableText));
        expect(input.focusNode, same(searchFocus));
        expect(input.focusNode.hasFocus, isTrue);
        expect(input.controller.text, '👩🏽‍🚀');
        expect(tester.testTextInput.isVisible, isTrue);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('unsupported emoji keeps prior icon and cannot be applied', (tester) async {
    emojiSupported = false;
    await tester.pumpWidget(const MaterialApp(home: WishIconPickerPage(initialIcon: {'builtin': 'timer'})));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '🚀');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((widget) => widget is Text && widget.data == '🚀'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(find.textContaining('手机系统字体暂不支持'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(of: find.text('使用这个'), matching: find.byWidgetPredicate((widget) => widget is FilledButton)),
    );
    expect(button.onPressed, isNull);
    expect(writes, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('picker apply is staged; only Save writes unchanged work id with name and icon', (tester) async {
    final project = WishProject({'id': 'local-icon-check', 'title': '旧标题', 'request': 'a focus timer'});
    await tester.pumpWidget(
      MaterialApp(
        theme: wishTheme(ThemeData.dark()),
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.push(ctx, MaterialPageRoute(builder: (_) => WishIdentityPage(project: project))),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(find.text('专注'), findsOneWidget);
    await tester.ensureVisible(find.text('浏览 Emoji 与图形'));
    await tester.tap(find.text('浏览 Emoji 与图形'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '🚀');
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.byWidgetPredicate((widget) => widget is Text && widget.data == '🚀'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('使用这个'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(writes, isEmpty);
    expect(find.text('名称与图标'), findsOneWidget);
    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(writes, hasLength(1));
    expect(writes.single['work'], 'local-icon-check');
    final value = writes.single['value'] as Map;
    expect(value['customName'], '专注');
    expect((value['icon'] as Map)['emoji'], '🚀');
    expect((value['icon'] as Map)['bitmap'], isA<String>());
    expect((await SharedPreferences.getInstance()).getStringList('wish.icons.recent.v1'), ['🚀']);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
