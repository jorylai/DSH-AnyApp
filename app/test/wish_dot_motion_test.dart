import 'package:dsh_app/wish/wish_dot_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget scene(Widget child, {bool reduced = false, bool visible = true, double textScale = 1}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduced, textScaler: TextScaler.linear(textScale)),
  child: TickerMode(
    enabled: visible,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  ),
);

CustomPainter painter(WidgetTester tester) => tester.widget<CustomPaint>(find.byType(CustomPaint)).painter!;

void main() {
  testWidgets('loader animates only its paint and exposes the real localized phase', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(scene(const WishDotLoader(size: 96, phase: '正在连接作品')));
    final graphic = tester.widget<CustomPaint>(find.byType(CustomPaint));
    var paints = 0;
    graphic.painter!.addListener(() => paints++);
    await tester.pump(const Duration(milliseconds: 100));
    expect(paints, greaterThan(0));
    expect(identical(tester.widget<CustomPaint>(find.byType(CustomPaint)), graphic), isTrue);
    expect(find.bySemanticsLabel('正在连接作品'), findsOneWidget);
    expect(tester.getSize(find.byType(CustomPaint)), const Size(96, 96));
    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });

  testWidgets('reduced animations keep a static constellation with no ticking callbacks', (tester) async {
    await tester.pumpWidget(scene(const WishDotLoader(), reduced: true));
    var paints = 0;
    painter(tester).addListener(() => paints++);
    await tester.pump(const Duration(seconds: 8));
    expect(paints, 0);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TickerMode pauses motion and resumes it when the page becomes visible', (tester) async {
    await tester.pumpWidget(scene(const WishDotMark()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(scene(const WishDotMark(), visible: false));
    var hiddenPaints = 0;
    painter(tester).addListener(() => hiddenPaints++);
    await tester.pump(const Duration(seconds: 5));
    expect(hiddenPaints, 0);
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(scene(const WishDotMark()));
    var visiblePaints = 0;
    painter(tester).addListener(() => visiblePaints++);
    await tester.pump(const Duration(milliseconds: 100));
    expect(visiblePaints, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('inactive and paused lifecycle states stop the controller until resume', (tester) async {
    await tester.pumpWidget(scene(const WishDotLoader()));
    await tester.pump(const Duration(milliseconds: 100));
    for (final lifecycle in [AppLifecycleState.inactive, AppLifecycleState.paused]) {
      tester.binding.handleAppLifecycleStateChanged(lifecycle);
      await tester.pump();
      var paints = 0;
      painter(tester).addListener(() => paints++);
      await tester.pump(const Duration(seconds: 2));
      expect(paints, 0, reason: lifecycle.name);
      expect(tester.binding.transientCallbackCount, 0);
    }
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    var paints = 0;
    painter(tester).addListener(() => paints++);
    await tester.pump(const Duration(milliseconds: 100));
    expect(paints, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('inactive mark and a live reduced-motion preference stop immediately', (tester) async {
    await tester.pumpWidget(scene(const WishDotMark()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(scene(const WishDotMark(active: false)));
    var paints = 0;
    painter(tester).addListener(() => paints++);
    await tester.pump(const Duration(seconds: 3));
    expect(paints, 0);
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(scene(const WishDotMark()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(scene(const WishDotMark(), reduced: true));
    paints = 0;
    painter(tester).addListener(() => paints++);
    await tester.pump(const Duration(seconds: 3));
    expect(paints, 0);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('arrival settles without a perpetual frame loop', (tester) async {
    await tester.pumpWidget(scene(const WishDotMark()));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('graphics keep their bounds beside large type on a 384px screen', (tester) async {
    tester.view.physicalSize = const Size(384, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      scene(
        const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WishDotMark(size: 128, active: false),
              SizedBox(height: 20),
              Text('让想法慢慢发光', textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        reduced: true,
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CustomPaint)), const Size(128, 128));
    final bounds = tester.getRect(find.byType(CustomPaint));
    expect(bounds.left, greaterThanOrEqualTo(24));
    expect(bounds.right, lessThanOrEqualTo(360));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
