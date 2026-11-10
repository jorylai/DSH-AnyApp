import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/wish/wish_gallery.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:dsh_app/wish/wish_wall_order.dart';

void main() {
  const items = [
    WishGalleryItem(
      id: 'demo-radar',
      title: '比价雷达',
      description: '把值得买的，留在掌心。',
      status: '随时可用',
      ready: true,
      icon: {'builtin': 'cart', 'palette': 'indigo'},
    ),
    WishGalleryItem(
      id: 'demo-time',
      title: '番茄刻度',
      description: '为专注，留一小段时光。',
      status: '随时可用',
      ready: true,
      icon: {'builtin': 'timer', 'palette': 'amber'},
    ),
    WishGalleryItem(
      id: 'demo-notes',
      title: '拾光笔记',
      description: '接住每一个转瞬即逝的想法。',
      status: '随时可用',
      ready: true,
      icon: {'builtin': 'book', 'palette': 'mint'},
    ),
    WishGalleryItem(
      id: 'demo-trip',
      title: 'Voyo Trip',
      description: '下一段旅程，从容出发。',
      status: '继续打磨',
      icon: {'builtin': 'trip', 'palette': 'violet'},
    ),
  ];
  for (final scenario in [(384.0, 1.0), (320.0, 1.5), (780.0, 1.0)]) {
    testWidgets('gallery adapts at ${scenario.$1} / text ${scenario.$2}', (tester) async {
      tester.view.physicalSize = Size(scenario.$1, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var opened = -1, managed = -1, created = 0;
      final key = GlobalKey();
      final output = Platform.environment['ANYAPP_VISUAL_OUTPUT'];
      if (output != null) {
        final font = File('/System/Library/Fonts/STHeiti Light.ttc');
        if (font.existsSync())
          await (FontLoader('ReviewSans')..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())))).load();
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: wishTheme(ThemeData.dark())
              .copyWith(textTheme: ThemeData.dark().textTheme.apply(fontFamily: output == null ? null : 'ReviewSans')),
          builder: (_, child) => MediaQuery(
            data: MediaQueryData(size: Size(scenario.$1, 860), textScaler: TextScaler.linear(scenario.$2)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: key,
            child: WishGallery(
              items: items,
              sort: WishWallSort.added,
              onSort: (_) {},
              onOpen: (i) => opened = i,
              onManage: (i) => managed = i,
              onCreate: () => created++,
              onLibrary: () {},
              onSettings: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('DSH AnyApp'), findsOneWidget);
      expect(find.textContaining('Creator'), findsNothing);
      await tester.tap(find.text('开始创造'));
      await tester.pumpAndSettle();
      expect(created, 1);
      if (output != null && scenario.$1 == 384 && scenario.$2 == 1) {
        await tester.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final shot = await boundary.toImage(pixelRatio: 2);
          final png = await shot.toByteData(format: ui.ImageByteFormat.png);
          await File(output).writeAsBytes(png!.buffer.asUint8List());
          shot.dispose();
        });
      }
      await tester.scrollUntilVisible(find.text('比价雷达'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('比价雷达'));
      await tester.pumpAndSettle();
      expect(opened, 0);
      await tester.longPress(find.text('比价雷达'));
      await tester.pumpAndSettle();
      expect(managed, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
