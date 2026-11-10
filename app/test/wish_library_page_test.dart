import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/runtime/runtime_bridge.dart';
import 'package:dsh_app/runtime/runtime_state.dart';
import 'package:dsh_app/wish/wish_create.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnavailableRuntime extends RuntimeBridge {
  int attempts = 0;
  @override
  Future<RuntimeStatus> status() async {
    attempts++;
    throw StateError('runtime-not-installed');
  }
}

Map<String, dynamic> _package() {
  final bytes = utf8.encode('{"name":"@local/local-shared"}');
  final files = [
    {'path': 'package.json', 'data': base64Encode(bytes), 'sha256': sha256.convert(bytes).toString()},
  ];
  return {
    'format': 'dsh-anyapp-plugin/1',
    'api': 2,
    'portable': true,
    'sourceId': 'local-shared',
    'title': 'Shared app',
    'hash': sha256.convert(utf8.encode(jsonEncode(files))).toString(),
    'files': files,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _UnavailableRuntime runtime;
  late Future<dynamic> Function() pick;
  var picks = 0;

  setUp(() {
    AppLocale.use(AppLocale.zhCN);
    SharedPreferences.setMockInitialValues({});
    runtime = _UnavailableRuntime();
    picks = 0;
    pick = () async => null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (
      call,
    ) async {
      if (call.method == 'files.pick') {
        picks++;
        return pick();
      }
      return null;
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      null,
    );
  });

  Future<void> show(WidgetTester tester, {double scale = 1}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [runtimeBridgeProvider.overrideWithValue(runtime)],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
            child: child!,
          ),
          home: const WishLibraryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('guide fits a narrow screen at large type and has no starter installation cards', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, scale: 1.6);
    expect(find.text(appL10n.anyappGuideTitle), findsOneWidget);
    expect(find.text(appL10n.wishPresets), findsNothing);
    for (final label in [
      appL10n.anyappGuideShopTitle,
      appL10n.anyappGuideFocusTitle,
      appL10n.anyappGuideStepThreeTitle,
    ]) {
      await tester.scrollUntilVisible(find.text(label), 250);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('file selection starts import immediately and a failed attempt can continue', (tester) async {
    pick = () async => {'data': base64Encode(utf8.encode(jsonEncode(_package())))};
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('library-import')));
    await tester.pumpAndSettle();
    expect(picks, 1);
    expect(runtime.attempts, 1, reason: 'installation starts from selection, without a second confirmation');
    expect(find.text(appL10n.wishInstallNewWork), findsNothing);
    expect(find.text('Shared app'), findsOneWidget);
    await tester.ensureVisible(find.text(appL10n.anyappGuideImportRetry));
    await tester.tap(find.text(appL10n.anyappGuideImportRetry));
    await tester.pumpAndSettle();
    expect(runtime.attempts, 2);
    expect(picks, 1, reason: 'retry continues the selected import rather than selecting another file');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('picker cancellation does not install, and repeated taps open only one picker', (tester) async {
    final pending = Completer<dynamic>();
    pick = () => pending.future;
    await show(tester);
    final importer = find.byKey(const ValueKey('library-import'));
    await tester.tap(importer);
    await tester.tap(importer, warnIfMissed: false);
    await tester.pump();
    expect(picks, 1);
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(runtime.attempts, 0);
    expect(find.text(appL10n.anyappGuideImportRetry), findsNothing);
    expect(find.byKey(const ValueKey('library-import')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an idea opens creation with its concrete request already filled', (tester) async {
    await show(tester);
    await tester.scrollUntilVisible(find.text(appL10n.anyappGuideFocusTitle), 250);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(appL10n.anyappGuideFocusTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(appL10n.anyappGuideFocusTitle));
    await tester.pumpAndSettle();
    expect(find.byType(WishCreatePage), findsOneWidget);
    expect(tester.widget<WishCreatePage>(find.byType(WishCreatePage)).initialRequest, appL10n.anyappGuideFocusPrompt);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
