import 'dart:ui' as ui;

import 'package:dsh_app/wish/wish_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets('scroll light repaints without layout changes; reduced=$reduced', (tester) async {
      final boundary = GlobalKey();
      const contentKey = ValueKey('glass-content');
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: RepaintBoundary(
              key: boundary,
              child: WishGlassScene(
                child: Center(
                  child: SizedBox(
                    width: 240,
                    height: 160,
                    child: WishGlassSurface(
                      child: Center(child: Text('Readable glass', key: contentKey)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final originalRect = tester.getRect(find.byKey(contentKey));
      Future<List<int>> pixels() async => (await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        return data!.buffer.asUint8List().toList();
      }))!;

      final before = await pixels();
      ScrollUpdateNotification(
        metrics: FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 1000,
          pixels: 400,
          viewportDimension: 600,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        ),
        context: tester.element(find.byKey(contentKey)),
        scrollDelta: 400,
      ).dispatch(tester.element(find.byKey(contentKey)));
      await tester.pump();
      final after = await pixels();
      expect(after, reduced ? orderedEquals(before) : isNot(orderedEquals(before)));
      expect(tester.getRect(find.byKey(contentKey)), originalRect);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('high contrast removes background blur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(highContrast: true),
          child: WishGlassScene(child: WishGlassSurface(child: Text('Clear text'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Clear text'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
