import 'dart:async';

import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_project.dart';
import 'package:dsh_app/wish/wish_project_page.dart';
import 'package:dsh_app/ui/web/local_web_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Completer<Object?> identity;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    identity = Completer<Object?>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      (_) => identity.future,
    );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.textInput,
      null,
    );
  });

  testWidgets('system back during a cached work launch returns home instead of exiting the app', (tester) async {
    var homes = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WishProjectPage(project: WishProject({'id': 'local-radar', 'title': '比价雷达'}), onHome: () => homes++),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LocalWebScreen), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(homes, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    identity.complete({});
    await tester.pump();
  });

  testWidgets('loading screen closes the keyboard before returning to home', (tester) async {
    var homes = 0, hides = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.textInput,
      (call) async {
        if (call.method == 'TextInput.hide') hides++;
        return null;
      },
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WishProjectPage(project: WishProject({'id': 'local-radar', 'title': '比价雷达'}), onHome: () => homes++),
        ),
      ),
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(hides, 1);
    expect(homes, 0);
    tester.view.viewInsets = const FakeViewPadding();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(homes, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    identity.complete({});
    await tester.pump();
  });
}
