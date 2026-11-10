import 'package:dsh_app/analytics/anyapp_analytics.dart';
import 'package:dsh_app/analytics/anyapp_analytics_ui.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Store implements AnyappAnalyticsStore {
  String? text;
  bool fail = false;
  @override
  Future<String?> read() async => text;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('disk-unavailable');
    text = value;
  }
}

void main() {
  testWidgets('local-only choice stays optional and an opt-out save failure can be retried directly', (tester) async {
    final store = _Store();
    final container = ProviderContainer(
      overrides: [anyappAnalyticsConfigProvider.overrideWithValue(AnyappAnalyticsConfig(store: store))],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: wishTheme(ThemeData.dark()),
          home: const Scaffold(body: SingleChildScrollView(child: AnyappAnalyticsNotice())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(container.read(anyappAnalyticsProvider).enabled, isTrue);
    expect(container.read(anyappAnalyticsProvider).endpointConfigured, isFalse);
    store.fail = true;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.text('重试保存'), findsOneWidget);
    store.fail = false;
    await tester.tap(find.text('重试保存'));
    await tester.pumpAndSettle();
    expect(container.read(anyappAnalyticsProvider).status, AnyappAnalyticsStatus.disabled);
    expect(find.text('重试保存'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('diagnostic page fits narrow large text and shows unconfigured status honestly', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = _Store();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [anyappAnalyticsConfigProvider.overrideWithValue(AnyappAnalyticsConfig(store: store))],
        child: MaterialApp(
          theme: wishTheme(ThemeData.dark()),
          builder: (_, child) => MediaQuery(
            data: const MediaQueryData(size: Size(320, 640), textScaler: TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const AnyappAnalyticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('导出诊断记录'), 200);
    expect(find.text('尚未配置独立统计服务，记录不会自动离开手机。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
