import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/wish/wish_action_settings.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_setup_guide.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  var granted = true, grantOnOpen = false, shown = false;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    granted = true;
    grantOnOpen = false;
    shown = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (
      call,
    ) async {
      calls.add(call);
      if (call.method == 'works.get')
        return {
          'actions': [
            {'id': 'compare', 'label': '立即比价', 'kind': 'agent'},
          ],
        };
      if (call.method == 'actions.state') return {'shown': shown, 'work': 'local-test'};
      if (call.method == 'status') return {'overlay': granted};
      if (call.method == 'setup.info')
        return {
          'appLabel': 'DSH AnyApp 测试',
          'sdkInt': 36,
          'brand': 'Xiaomi',
          'permissions': {'overlay': granted},
        };
      if (call.method == 'setup.open') {
        granted = grantOnOpen;
        return {'opened': true, 'fallback': false};
      }
      if (call.method == 'actions.show') {
        shown = true;
        return true;
      }
      if (call.method == 'actions.hide') {
        shown = false;
        return true;
      }
      throw StateError(call.method);
    });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      null,
    ),
  );

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: wishTheme(ThemeData.dark()),
          home: const WishActionSettings(work: 'local-test'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('entry settings follow native visibility including hold-to-hide', (tester) async {
    await show(tester);
    expect(find.text('agent'), findsNothing);
    expect(find.textContaining('已隐藏'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(shown, true);
    expect(find.textContaining('已显示'), findsOneWidget);
    expect(calls.singleWhere((call) => call.method == 'actions.show').arguments, {
      'work': 'local-test',
      'userInitiated': true,
    });
    WishDevice.entryVisibility.value = {'shown': false, 'work': 'local-test'};
    await tester.pumpAndSettle();
    expect(find.textContaining('已隐藏'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a user initiated enable resumes after guidance grants real system access', (tester) async {
    granted = false;
    grantOnOpen = true;
    await show(tester);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsOneWidget);
    expect(calls.where((call) => call.method == 'actions.show'), isEmpty);
    final enable = find.byKey(const ValueKey('setup-enable-overlay'));
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect(granted, true);
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsNothing);
    expect(shown, true);
    expect(calls.singleWhere((call) => call.method == 'actions.show').arguments, {
      'work': 'local-test',
      'userInitiated': true,
    });
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancelled overlay setup keeps the entry hidden without starting an action', (tester) async {
    granted = false;
    await show(tester);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsNothing);
    expect(shown, false);
    expect(calls.where((call) => call.method == 'actions.show'), isEmpty);
    expect(find.text(appL10n.anySetupOverlayDeferred), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reading the permission guide never turns on an entry after granting access', (tester) async {
    granted = false;
    grantOnOpen = true;
    await show(tester);
    await tester.tap(find.text(appL10n.wishOverlayPermission));
    await tester.pumpAndSettle();
    final enable = find.byKey(const ValueKey('setup-enable-overlay'));
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect(find.byType(WishSetupGuidePage), findsNothing);
    expect(calls.where((call) => call.method == 'actions.show'), isEmpty);
    expect(find.text(appL10n.anySetupOverlayGrantedHelp), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
