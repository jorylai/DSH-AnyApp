// Optional renderer: ANYAPP_REVIEW_DIR=/path flutter test tool/visual_review_test.dart
// Uses production widgets with synthetic content; does not contact a model or phone.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/wish/wish_create.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_gallery.dart';
import 'package:dsh_app/wish/wish_library_page.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:dsh_app/wish/wish_wall_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final output = Platform.environment['ANYAPP_REVIEW_DIR'];
  testWidgets('render production screens for visual review', (tester) async {
    if (output == null) return;
    Directory(output).createSync(recursive: true);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    SharedPreferences.setMockInitialValues({});
    AppLocale.use(AppLocale.zhCN);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      (_) async => null,
    );
    await tester.runAsync(() async {
      final cjk = File('/System/Library/Fonts/STHeiti Light.ttc');
      if (cjk.existsSync())
        await (FontLoader('ReviewSans')..addFont(Future.value(ByteData.sublistView(await cjk.readAsBytes())))).load();
      await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final key = GlobalKey();
    Future<void> show(Widget child) async {
      await tester.pumpWidget(
        ProviderScope(
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: wishTheme(
                ThemeData.dark().copyWith(textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'ReviewSans')),
              ),
              builder: (context, child) => Stack(
                children: [
                  child!,
                  if (MediaQuery.viewInsetsOf(context).bottom > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: MediaQuery.viewInsetsOf(context).bottom,
                      child: const ColoredBox(
                        color: Color(0xFF20252F),
                        child: Center(
                          child: Text(
                            '系统输入法区域 · 布局模拟',
                            style: TextStyle(
                              fontFamily: 'ReviewSans',
                              decoration: TextDecoration.none,
                              color: Color(0xFF8E99AA),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              home: child,
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await precacheImage(const AssetImage('assets/brand/mark.png'), key.currentContext!);
        await Future<void>.delayed(const Duration(milliseconds: 120));
      });
      await tester.pumpAndSettle();
    }

    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final picture = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 2);
        final png = await picture.toByteData(format: ui.ImageByteFormat.png);
        await File('$output/$name.png').writeAsBytes(png!.buffer.asUint8List());
        picture.dispose();
      });
    }

    final items = [
      const WishGalleryItem(
        id: 'demo-radar',
        title: '比价雷达',
        description: '把值得买的，留在掌心。',
        status: '随时可用',
        ready: true,
        icon: {'builtin': 'cart', 'palette': 'indigo'},
      ),
      const WishGalleryItem(
        id: 'demo-focus',
        title: '番茄刻度',
        description: '留一段时间，专注当下。',
        status: '随时可用',
        ready: true,
        icon: {'builtin': 'timer', 'palette': 'amber'},
      ),
    ];
    await show(
      WishGallery(
        items: items,
        sort: WishWallSort.added,
        onSort: (_) {},
        onOpen: (_) {},
        onManage: (_) {},
        onCreate: () {},
        onLibrary: () {},
        onSettings: () {},
      ),
    );
    await capture('首页-液态玻璃-模拟预览');
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    for (var i = 0; i < 24; i++) {
      scroll.jumpTo((1 - math.cos(i / 24 * math.pi * 2)) * .5 * 360);
      await tester.pump();
      await capture('glass-${i.toString().padLeft(2, '0')}');
    }
    await show(const WishLibraryPage());
    await capture('灵感-精选起点-模拟预览');
    await show(WishCreatePage(initialRequest: appL10n.wishIdeaPomodoroPrompt));
    await capture('新建-模拟预览');
    await tester.tap(find.byKey(const ValueKey('creation-request')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();
    await capture('新建-键盘布局-模拟预览');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, skip: output == null);
}
