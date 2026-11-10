import 'dart:convert';

import 'package:dsh_app/wish/wish_preset_bootstrap.dart';
import 'package:dsh_app/wish/wish_preset_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const filesChannel = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(filesChannel, (_) async {
      throw PlatformException(code: 'files-unavailable');
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(filesChannel, null);
  });
  testWidgets('preparation failure can open the wall without marking starters complete', (tester) async {
    SharedPreferences.setMockInitialValues({
      WishPresetBootstrap.preferenceKey: jsonEncode({
        'version': 1,
        'mode': 'pending',
        'ids': {'voyo': 'local-voyo', 'calorie': 'local-calorie'},
        'progress': {},
      }),
    });
    // No Android files service is mounted in this test: preparation must fail
    // visibly and leave a usable exit rather than claiming successful install.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WishPresetGate(child: Text('Home visible'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home visible'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    await tester.tap(find.text('先去首页'));
    await tester.pumpAndSettle();
    expect(find.text('Home visible'), findsOneWidget);
    expect(await WishPresetBootstrap.pending(), isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('an existing install reaches home without a preset preparing statement', (tester) async {
    SharedPreferences.setMockInitialValues({'wish.onboard.welcome': true});
    await tester.pumpWidget(const MaterialApp(home: WishPresetGate(child: Text('Existing home'))));
    await tester.pumpAndSettle();
    expect(find.text('Existing home'), findsOneWidget);
    expect(find.textContaining('Voyo Trip'), findsNothing);
  });
}
