import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/wish/wish_capabilities_page.dart';
import 'package:dsh_app/ui/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  var reminders = false;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    reminders = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dsh/wish/device'),
      (call) async {
        calls.add(call);
        if (call.method == 'status') {
          return {
            'phone': false,
            'reminders': reminders,
            'notifications': true,
            'exact': true,
            'phoneStatus': {'enabled': false, 'a11y': {}},
          };
        }
        if (call.method == 'setup.info') {
          return {
            'brand': 'xiaomi',
            'sdkInt': 36,
            'appLabel': 'DSH AnyApp',
            'accessibility': {'enabled': false, 'serviceConnected': false},
            'permissions': {'overlay': false},
            'notifications': {'enabled': true},
          };
        }
        if (call.method == 'works.get') return {'actions': []};
        if (call.method == 'actions.state') return {'shown': false};
        if (call.method == 'grant') {
          reminders = (call.arguments as Map)['enabled'] == true;
          return true;
        }
        return true;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dsh/wish/permissions'),
      (_) async => {'camera': false, 'microphone': false, 'notifications': true},
    );
  });
  testWidgets('work capability center changes one native namespace and schedules a persistent test reminder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ProviderScope(child: child!),
        theme: buildDarkTheme(glassBlur: false, instantPages: true),
        home: const WishCapabilitiesPage(projectId: 'local-test'),
      ),
    );
    await tester.pumpAndSettle();
    final reminderGrant = find.byKey(const ValueKey('grant-reminders'));
    await tester.scrollUntilVisible(reminderGrant, 250);
    await Scrollable.ensureVisible(tester.element(reminderGrant), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(reminderGrant);
    await tester.pumpAndSettle();
    final grant = calls.firstWhere((c) => c.method == 'grant');
    expect(grant.arguments, {'work': 'local-test', 'capability': 'reminders', 'enabled': true});
    final test = find.text('发送测试提醒（10 秒后）');
    await tester.scrollUntilVisible(test, 200);
    await Scrollable.ensureVisible(tester.element(test), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(test);
    await tester.pumpAndSettle();
    final alarm = calls.firstWhere((c) => c.method == 'reminders.schedule');
    expect((alarm.arguments as Map)['work'], 'local-test');
    expect((alarm.arguments as Map)['at'], greaterThan(DateTime.now().millisecondsSinceEpoch));
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('background scheduling has an explicit per-work grant control', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ProviderScope(child: child!),
        theme: buildDarkTheme(glassBlur: false, instantPages: true),
        home: const WishCapabilitiesPage(projectId: 'local-test'),
      ),
    );
    await tester.pumpAndSettle();
    final more = find.byKey(const ValueKey('capabilities-more'));
    expect(find.byKey(const ValueKey('grant-background')), findsNothing);
    await tester.scrollUntilVisible(more, 250);
    await Scrollable.ensureVisible(tester.element(more), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(more);
    await tester.pumpAndSettle();
    final control = find.byKey(const ValueKey('grant-background'));
    await tester.scrollUntilVisible(control, 250);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(control), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(calls.where((c) => c.method == 'grant').last.arguments, {
      'work': 'local-test',
      'capability': 'background',
      'enabled': true,
    });
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('actions are reached through the capability center with the same work namespace', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ProviderScope(child: child!),
        theme: buildDarkTheme(glassBlur: false, instantPages: true),
        home: const WishCapabilitiesPage(projectId: 'local-test'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('悬浮与桌面动作'));
    await tester.pumpAndSettle();
    expect(calls.firstWhere((c) => c.method == 'works.get').arguments, {'work': 'local-test'});
    expect(find.text('悬浮入口'), findsOneWidget);
    expect(calls.where((c) => c.method == 'grant'), isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('权限与动作'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('global capability center never grants a work implicitly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDarkTheme(glassBlur: false, instantPages: true),
          home: const WishCapabilitiesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('global-floating-entry')), findsOneWidget);
    expect(find.byKey(const ValueKey('grant-phone')), findsNothing);
    expect(calls.where((c) => c.method == 'grant'), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('permission instructions expand in place and back returns to the work settings', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDarkTheme(glassBlur: false, instantPages: true),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('work settings'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const WishCapabilitiesPage(projectId: 'local-test')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('work settings'));
    await tester.pumpAndSettle();
    final topic = find.byKey(const ValueKey('setup-inline-accessibility'));
    await tester.scrollUntilVisible(topic, 200);
    await tester.ensureVisible(topic);
    await tester.tap(topic);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('setup-enable-accessibility')), findsOneWidget);
    expect(find.text('返回能力列表'), findsNothing);
    expect(find.text('让手机，更懂你'), findsNothing);
    expect(calls.where((call) => call.method == 'setup.open'), isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('work settings'), findsOneWidget);
    expect(find.text('权限与动作'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
