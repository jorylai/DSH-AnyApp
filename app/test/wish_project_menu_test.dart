import 'package:dsh_app/wish/wish_project_menu.dart';
import 'package:dsh_app/wish/wish_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('open and continue creation lead the menu; low-frequency management needs expansion', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: wishTheme(ThemeData.dark()),
        home: Scaffold(
          body: WishProjectMenu(title: '比价雷达', creator: false, published: true, onSelected: selected.add),
        ),
      ),
    );
    final primary = tester.widgetList<ListTile>(find.byType(ListTile)).map((tile) => tile.key).toList();
    expect(primary[1], const ValueKey('work-menu-preview'));
    expect(primary[2], const ValueKey('work-menu-creator'));
    expect(find.byKey(const ValueKey('work-menu-actions')), findsNothing);
    expect(find.byKey(const ValueKey('work-menu-permissions')), findsOneWidget);
    for (final action in ['records', 'publish', 'task', 'models', 'versions']) {
      expect(find.byKey(ValueKey('work-menu-$action')), findsNothing);
    }
    await tester.tap(find.byKey(const ValueKey('work-menu-more')));
    await tester.pumpAndSettle();
    for (final action in ['records', 'publish', 'task', 'models', 'versions']) {
      expect(find.byKey(ValueKey('work-menu-$action')), findsOneWidget);
    }
    final task = find.byKey(const ValueKey('work-menu-task'));
    await tester.ensureVisible(task);
    await tester.tap(task);
    expect(selected, ['task']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the expanded work menu remains scrollable with large text on a small screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final selected = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: wishTheme(ThemeData.dark()),
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 600), textScaler: TextScaler.linear(1.7)),
          child: Scaffold(
            body: WishProjectMenu(title: '一个名字很长的作品', creator: true, published: false, onSelected: selected.add),
          ),
        ),
      ),
    );
    final more = find.byKey(const ValueKey('work-menu-more'));
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    final publish = find.byKey(const ValueKey('work-menu-publish'));
    await tester.ensureVisible(publish);
    await tester.tap(publish);
    expect(selected, ['publish']);
    expect(tester.takeException(), isNull);
  });
}
