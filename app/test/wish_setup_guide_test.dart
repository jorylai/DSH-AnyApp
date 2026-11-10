import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/state/phone_state.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_setup_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  var info = <String, dynamic>{};
  var fallback = false;
  var readFailure = false;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    fallback = false;
    readFailure = false;
    info = {
      'appLabel': 'DSH AnyApp 测试',
      'manufacturer': 'Xiaomi',
      'brand': 'Redmi',
      'vendor': 'xiaomi',
      'sdkInt': 36,
      'release': '16',
      'developerOptions': null,
      'usbDebugging': null,
      'wirelessDebugging': null,
      'accessibility': {'enabled': false, 'serviceConnected': false},
      'notifications': {'enabled': false, 'listenerEnabled': false},
      'permissions': {'camera': false, 'microphone': false},
      'vendorSettings': {'autostart': null, 'background': null, 'popup': null},
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (
      call,
    ) async {
      calls.add(call);
      if (call.method == 'setup.info') {
        if (readFailure) throw PlatformException(code: 'read-failed');
        return info;
      }
      if (call.method == 'setup.open') {
        return {
          'opened': true,
          'fallback': fallback,
          'resolvedTarget': fallback ? 'appDetails' : (call.arguments as Map)['target'],
        };
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dsh/wish/permissions'),
      (call) async {
        calls.add(call);
        return {'camera': false, 'microphone': false, 'notifications': false};
      },
    );
  });
  tearDown(() {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(WishDevice.channel, null);
    messenger.setMockMethodCallHandler(const MethodChannel('dsh/wish/permissions'), null);
  });

  Future<void> show(WidgetTester tester, {String? topic, bool onboarding = false, bool largeText = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          builder: largeText
              ? (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                )
              : null,
          home: WishSetupGuidePage(initialTopic: topic, onboarding: onboarding, onDone: () {}, onSkip: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String? status(WidgetTester tester) => tester.widget<Text>(find.byKey(const ValueKey('setup-detail-status'))).data;

  testWidgets('a direct permission entry returns to its caller without inserting the guide catalog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('origin'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const WishSetupGuidePage(initialTopic: 'accessibility')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('origin'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('origin'), findsOneWidget);
    expect(find.byKey(const ValueKey('setup-group-phone')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reading guidance never requests a permission or opens settings', (tester) async {
    await show(tester);
    expect(calls.map((call) => call.method), ['setup.info']);
    expect(find.byKey(const ValueKey('setup-group-advanced')), findsOneWidget);
    expect(find.byKey(const ValueKey('setup-finish')), findsNothing);
    expect(find.byKey(const ValueKey('setup-skip')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('enabled accessibility waits for service and rechecks on returning to the app', (tester) async {
    info['accessibility'] = {'enabled': true, 'serviceConnected': false};
    await show(tester, topic: 'accessibility');
    expect(status(tester), appL10n.phoneSetupServiceWaiting);
    info['accessibility'] = {'enabled': true, 'serviceConnected': true};
    for (final phase in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(phase);
    }
    await tester.pumpAndSettle();
    expect(status(tester), appL10n.phoneSetupOn);
    expect(calls.where((call) => call.method == 'setup.info'), hasLength(2));
    expect(calls.where((call) => call.method != 'setup.info'), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opening an OEM switch records a visit but never claims a grant', (tester) async {
    fallback = true;
    await show(tester, topic: 'autostart');
    expect(status(tester), appL10n.phoneSetupUnknown);
    final enable = find.byKey(const ValueKey('setup-enable-autostart'));
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect(calls.singleWhere((call) => call.method == 'setup.open').arguments, {'target': 'autostart'});
    expect(status(tester), appL10n.phoneSetupVisited);
    expect(find.text(appL10n.phoneSetupFallback), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getStringList('anyapp.setup.visited.v1'), ['autostart']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('camera guidance provides app details after denial without inventing success', (tester) async {
    await show(tester, topic: 'camera');
    final enable = find.byKey(const ValueKey('setup-enable-camera'));
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect(status(tester), appL10n.phoneSetupOff);
    expect(find.text(appL10n.anySetupDenied), findsOneWidget);
    await tester.ensureVisible(find.text(appL10n.phoneSetupAppDetails));
    await tester.tap(find.text(appL10n.phoneSetupAppDetails));
    await tester.pumpAndSettle();
    expect(calls.singleWhere((call) => call.method == 'setup.open').arguments, {'target': 'appDetails'});
    expect(status(tester), appL10n.phoneSetupOff);
    expect(calls.where((call) => call.method == 'requestCamera'), hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('developer and USB status stay unknown when Android cannot expose them', (tester) async {
    await show(tester, topic: 'developerOptions');
    expect(status(tester), appL10n.phoneSetupUnknown);
    expect(find.text(appL10n.phoneSetupAdvancedOnly), findsOneWidget);
    expect(calls.where((call) => call.method != 'setup.info'), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed recheck clears an old granted state instead of keeping a green result', (tester) async {
    info['permissions'] = {'camera': true};
    await show(tester, topic: 'camera');
    expect(status(tester), appL10n.phoneSetupOn);
    readFailure = true;
    await tester.tap(find.byTooltip(appL10n.phoneSetupRecheck));
    await tester.pumpAndSettle();
    expect(status(tester), appL10n.phoneSetupUnknown);
    expect(find.text(appL10n.phoneSetupReadFailed), findsOneWidget);
    expect(find.text(appL10n.phoneSetupOn), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('declining accessibility disclosure never launches system settings or enables phone control', (
    tester,
  ) async {
    await show(tester, topic: 'accessibility');
    final enable = find.byKey(const ValueKey('setup-enable-accessibility'));
    await tester.scrollUntilVisible(enable, 250);
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text(appL10n.anySetupDisclosureLater)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(calls.where((call) => call.method != 'setup.info'), isEmpty);
    expect((await SharedPreferences.getInstance()).getBool(PhoneController.disclosureKey), isNull);
    expect(status(tester), appL10n.phoneSetupOff);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('onboarding resumes its active permission after recreation and clears progress only on finish', (
    tester,
  ) async {
    await show(tester, topic: 'overlay', onboarding: true);
    final enable = find.byKey(const ValueKey('setup-enable-overlay'));
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pumpAndSettle();
    expect((await SharedPreferences.getInstance()).getString('anyapp.setup.resume.v1'), 'overlay');
    await tester.pumpWidget(const SizedBox.shrink());
    await show(tester, onboarding: true);
    expect(find.byKey(const ValueKey('setup-enable-overlay')), findsOneWidget);
    expect(status(tester), appL10n.phoneSetupVisited);
    final skip = find.byKey(const ValueKey('setup-skip'));
    await tester.scrollUntilVisible(skip, 250);
    await tester.tap(skip);
    await tester.pumpAndSettle();
    expect((await SharedPreferences.getInstance()).getString('anyapp.setup.resume.v1'), isNull);
    expect(calls.where((call) => call.method == 'setup.open'), hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('large text landscape keeps detailed guidance and its actions scrollable', (tester) async {
    tester.view.physicalSize = const Size(700, 350);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, topic: 'restrictedSettings', onboarding: true, largeText: true);
    final enable = find.byKey(const ValueKey('setup-enable-restrictedSettings'));
    await tester.scrollUntilVisible(enable, 250);
    await Scrollable.ensureVisible(tester.element(enable), alignment: .5);
    await tester.pumpAndSettle();
    expect(tester.getRect(enable).center.dy, lessThan(350));
    await tester.scrollUntilVisible(find.byKey(const ValueKey('setup-skip')), 250);
    expect(tester.widget<TextButton>(find.byKey(const ValueKey('setup-skip'))).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('first run offers relevant optional benefits without debugging or broad file access', (tester) async {
    await show(tester, onboarding: true);
    expect(find.byKey(const ValueKey('setup-topic-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('setup-topic-accessibility')), findsOneWidget);
    expect(find.byKey(const ValueKey('setup-topic-overlay')), findsOneWidget);
    expect(find.byKey(const ValueKey('setup-topic-files')), findsNothing);
    expect(find.byKey(const ValueKey('setup-group-advanced')), findsNothing);
    expect(calls.map((call) => call.method), ['setup.info']);
    await tester.tap(find.byKey(const ValueKey('setup-skip')));
    await tester.pumpAndSettle();
    expect(calls.map((call) => call.method), ['setup.info']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('file guidance directs to the document picker and never requests all storage', (tester) async {
    await show(tester, topic: 'files');
    expect(find.byKey(const ValueKey('setup-enable-files')), findsNothing);
    expect(find.text(appL10n.anySetupFilesActionHelp), findsOneWidget);
    expect(status(tester), appL10n.phoneSetupWhenUsed);
    expect(calls.map((call) => call.method), ['setup.info']);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('precise reminder guidance uses its real alarm settings instructions', (tester) async {
    await show(tester, topic: 'exact');
    expect(find.text(appL10n.phoneBrandGuideExactFind), findsOneWidget);
    expect(find.text(appL10n.phoneBrandGuideExactVerify), findsOneWidget);
    expect(find.text(appL10n.phoneSetupManualSearch), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('overlay guidance identifies the exact install and uses actual state after return', (tester) async {
    info['permissions'] = {'overlay': false};
    await show(tester, topic: 'overlay');
    expect(find.text(appL10n.anySetupInstalledApp('DSH AnyApp 测试')), findsOneWidget);
    expect(find.text(appL10n.anySetupOverlayListHelp), findsOneWidget);
    expect(find.text(appL10n.anySetupOverlayAfterGrant), findsOneWidget);
    expect(status(tester), appL10n.phoneSetupOff);
    info['permissions'] = {'overlay': true};
    await tester.tap(find.byTooltip(appL10n.phoneSetupRecheck));
    await tester.pumpAndSettle();
    expect(status(tester), appL10n.phoneSetupOn);
    expect(calls.where((call) => call.method == 'actions.show'), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('already granted permission returns to the list instead of requesting again', (tester) async {
    info['notifications'] = {'enabled': true};
    await show(tester, topic: 'notifications', onboarding: true);
    expect(status(tester), appL10n.phoneSetupOn);
    expect(find.byKey(const ValueKey('setup-finish')), findsNothing);
    final action = find.byKey(const ValueKey('setup-enable-notifications'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('setup-finish')), findsOneWidget);
    expect(calls.map((call) => call.method), ['setup.info']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
