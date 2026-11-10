import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dsh_app/wish/wish_icon_art.dart';
import 'package:dsh_app/wish/wish_preferences.dart';
import 'package:dsh_app/wish/wish_material.dart';
import 'package:dsh_app/wish/wish_create.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('full creator default never resets a saved user choice', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await WishPreferences.permissionPreset(), 'danger-full-access');
    await WishPreferences.setFullCreator(false);
    expect(await WishPreferences.permissionPreset(), 'workspace-write');
    expect(await WishPreferences.fullCreator(), false);
  });
  testWidgets('controlled icon renderer returns a real square PNG and rejects arbitrary code', (tester) async {
    final value = await tester.runAsync(() => WishIconArt.render({'glyph': 'cart', 'palette': 'mint', 'variant': 1}));
    final bytes = base64Decode(value!['bitmap'] as String);
    expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    expect((bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19], 256);
    await expectLater(WishIconArt.render({'glyph': '<script>bad</script>'}), throwsStateError);
  });
  testWidgets('raised action keeps keyboard and screen reader interaction and one tap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WishRitualButton(label: '创造', onPressed: () => tapped++),
        ),
      ),
    );
    await tester.tap(find.text('创造'));
    await tester.pumpAndSettle();
    expect(tapped, 1);
    expect(find.bySemanticsLabel('创造'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('creation page fits a narrow viewport with the keyboard present', (tester) async {
    tester.view.physicalSize = const Size(384, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: WishCreatePage())));
    await tester.enterText(find.byType(TextField), '做一个我的旅行助手');
    tester.view.viewInsets = FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
