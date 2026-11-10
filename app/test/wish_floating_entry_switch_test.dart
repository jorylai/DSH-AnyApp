import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_floating_entry_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var granted = true, shown = false;
  final calls = <MethodCall>[];
  setUp(() {
    granted = true;
    shown = false;
    calls.clear();
    WishDevice.entryVisibility.value = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (
      c,
    ) async {
      calls.add(c);
      if (c.method == 'status') return {'overlay': granted};
      if (c.method == 'actions.state') return {'shown': shown};
      if (c.method == 'actions.show') {
        shown = true;
        return true;
      }
      if (c.method == 'actions.hide') {
        shown = false;
        return true;
      }
      throw StateError(c.method);
    });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      null,
    ),
  );
  Future<void> mount(WidgetTester tester, {Future<void> Function()? request, bool external = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WishFloatingEntrySwitch(requestPermission: request ?? () async {}, waitForSystemResume: external),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('global switch immediately shows and hides the shared entry without granting work access', (t) async {
    await mount(t);
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(shown, true);
    expect(calls.singleWhere((c) => c.method == 'actions.show').arguments, {'userInitiated': true});
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(shown, false);
    expect(calls.where((c) => c.method == 'grant'), isEmpty);
    await t.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('returning from a permission guide completes the requested entry once', (t) async {
    granted = false;
    await mount(
      t,
      request: () async {
        granted = true;
      },
    );
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(shown, true);
    expect(calls.where((c) => c.method == 'actions.show'), hasLength(1));
    await t.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('external system settings waits for resume rather than discarding the requested enable', (t) async {
    granted = false;
    await mount(t, external: true);
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(shown, false);
    granted = true;
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      t.binding.handleAppLifecycleStateChanged(state);
      await t.pump();
    }
    await t.pumpAndSettle();
    expect(shown, true);
    expect(calls.where((c) => c.method == 'actions.show'), hasLength(1));
    await t.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('denial and simply viewing the control never start a ball or task', (t) async {
    granted = false;
    await mount(t);
    expect(calls.where((c) => c.method == 'actions.show'), isEmpty);
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(shown, false);
    expect(calls.where((c) => c.method == 'actions.show'), isEmpty);
    await t.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('hiding the ball outside settings updates the switch', (t) async {
    shown = true;
    await mount(t);
    WishDevice.entryVisibility.value = {'shown': false};
    await t.pumpAndSettle();
    expect(t.widget<Switch>(find.byType(Switch)).value, false);
    await t.pumpWidget(const SizedBox.shrink());
  });
}
