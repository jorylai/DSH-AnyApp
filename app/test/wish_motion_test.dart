import 'package:dsh_app/wish/wish_material.dart';
import 'package:dsh_app/wish/wish_motion.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget scene(Widget child, {bool reduced = false, bool visible = true, double textScale = 1}) => MaterialApp(
  theme: wishTheme(ThemeData.dark()),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced, textScaler: TextScaler.linear(textScale)),
    child: TickerMode(
      enabled: visible,
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

double scale(WidgetTester tester) => tester
    .widget<Transform>(find.descendant(of: find.byType(WishPressable).first, matching: find.byType(Transform)).first)
    .transform
    .storage[0];

void main() {
  testWidgets('press responds without delaying the action or duplicating semantics', (tester) async {
    var taps = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(scene(WishRitualButton(label: '开始创造', onPressed: () => taps++)));
    final target = find.byType(WishRitualButton);
    final original = tester.getSize(target);
    final pointer = await tester.startGesture(tester.getCenter(target));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(scale(tester), lessThan(1));
    expect(taps, 0);
    expect(tester.getSize(target), original);
    expect(find.bySemanticsLabel('开始创造'), findsOneWidget);
    await pointer.up();
    expect(taps, 1, reason: 'activation happens at release, before the visual settling finishes');
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
    expect(tester.binding.transientCallbackCount, 0);
    semantics.dispose();
  });

  testWidgets('busy feedback keeps the action label anchored beside large type', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget action(bool busy) =>
        scene(WishRitualButton(label: '保存并继续', busy: busy, onPressed: () {}), textScale: 1.8, reduced: true);
    await tester.pumpWidget(action(false));
    final before = tester.getTopLeft(find.text('保存并继续'));
    await tester.pumpWidget(action(true));
    expect(tester.getTopLeft(find.text('保存并继续')), before);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scrolling releases a depressed card and does not trigger a tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      scene(
        SingleChildScrollView(
          child: SizedBox(
            height: 2000,
            child: Align(
              alignment: Alignment.topCenter,
              child: WishPressable(
                child: InkWell(
                  onTap: () => taps++,
                  child: const SizedBox(width: 240, height: 160, child: Text('作品')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final pointer = await tester.startGesture(tester.getCenter(find.text('作品')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    expect(scale(tester), lessThan(1));
    await pointer.moveBy(const Offset(0, -80));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(scale(tester), 1);
    await pointer.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('pointer cancellation, live reduced motion and disable stop press feedback', (tester) async {
    Widget button({bool reduced = false, bool enabled = true}) => scene(
      WishPressable(
        enabled: enabled,
        child: const SizedBox(width: 200, height: 100, child: Text('动作')),
      ),
      reduced: reduced,
    );
    await tester.pumpWidget(button());
    var pointer = await tester.startGesture(tester.getCenter(find.text('动作')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    expect(scale(tester), lessThan(1));
    await pointer.cancel();
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
    pointer = await tester.startGesture(tester.getCenter(find.text('动作')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpWidget(button(reduced: true));
    await tester.pump();
    expect(scale(tester), 1);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.transientCallbackCount, 0);
    await pointer.up();
    await tester.pumpWidget(button(enabled: false));
    pointer = await tester.startGesture(tester.getCenter(find.text('动作')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    expect(scale(tester), 1);
    await pointer.up();
  });

  testWidgets('keyboard activation remains owned by the real button', (tester) async {
    var taps = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      scene(
        WishPressable(
          child: FilledButton(focusNode: focus, onPressed: () => taps++, child: const Text('启动')),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(scale(tester), 1);
  });

  testWidgets('a hidden or background entrance pauses, resumes and eventually has no ticker', (tester) async {
    const child = WishEntrance(order: 3, child: Text('新作品'));
    await tester.pumpWidget(scene(child));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpWidget(scene(child, visible: false));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(scene(child));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.binding.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(WishEntrance), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
  });

  testWidgets('reduced motion never hides an entrance even on a newly built page', (tester) async {
    await tester.pumpWidget(scene(const WishEntrance(order: 5, child: Text('立即可读')), reduced: true));
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(WishEntrance), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('keyboard appearance settles an entrance without rebuilding or stealing its field', (tester) async {
    final focus = FocusNode();
    final text = TextEditingController(text: '正在完善的想法');
    addTearDown(focus.dispose);
    addTearDown(text.dispose);
    final field = WishEntrance(
      order: 5,
      child: TextField(key: const ValueKey('draft-input'), focusNode: focus, controller: text),
    );
    await tester.pumpWidget(scene(field));
    await tester.pump(const Duration(milliseconds: 80));
    final before = tester.element(find.byKey(const ValueKey('draft-input')));
    focus.requestFocus();
    await tester.pump();
    addTearDown(tester.view.resetViewInsets);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(WishEntrance), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 1);
    expect(tester.element(find.byKey(const ValueKey('draft-input'))), same(before));
    expect(focus.hasFocus, isTrue);
    expect(text.text, '正在完善的想法');
    tester.view.resetViewInsets();
    await tester.pump();
    expect(
      tester
          .widget<Opacity>(find.descendant(of: find.byType(WishEntrance), matching: find.byType(Opacity)).first)
          .opacity,
      1,
      reason: 'closing the keyboard never replays an entrance',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('new content presented above a keyboard is immediately visible', (tester) async {
    addTearDown(tester.view.resetViewInsets);
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpWidget(scene(const WishEntrance(order: 5, child: Text('输入不会等动效'))));
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(WishEntrance), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('changing actual status keeps outgoing actions and announcements inactive', (tester) async {
    final semantics = tester.ensureSemantics();
    Widget status(String title) => scene(
      WishContentTransition(
        child: TextButton(key: ValueKey(title), onPressed: () {}, child: Text(title)),
      ),
    );
    await tester.pumpWidget(status('准备环境'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(status('加载界面'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final outgoing = find.ancestor(of: find.text('准备环境'), matching: find.byType(IgnorePointer));
    expect(tester.widgetList<IgnorePointer>(outgoing).any((widget) => widget.ignoring), isTrue);
    expect(find.bySemanticsLabel('准备环境'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('准备环境'), findsNothing);
    expect(find.text('加载界面'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    semantics.dispose();
  });

  test('the shared page style preserves the existing predictive-back route implementation', () {
    final theme = wishTheme(ThemeData.dark());
    expect(theme.pageTransitionsTheme.builders[TargetPlatform.android], isA<WishPageTransitionsBuilder>());
    expect(theme.pageTransitionsTheme.builders[TargetPlatform.android]!.transitionDuration, WishMotion.route);
    expect(const WishPageTransitionsBuilder(instant: true).transitionDuration, Duration.zero);
  });
}
