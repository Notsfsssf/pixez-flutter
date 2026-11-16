import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/desktop/desktop_layout.dart';
import 'package:pixez/desktop/desktop_shell.dart';

void main() {
  test('gallery density uses the content pane and preserves preferences', () {
    expect(desktopGridColumns(200), 1);
    expect(desktopGridColumns(720), 3);
    expect(desktopGridColumns(1200), 5);
    expect(desktopGridColumns(720, preferredColumns: 6), 4);
    expect(desktopGridColumns(720, preferredWidth: 300), 2);
    expect(desktopGridColumns(10000), 12);
  });

  Future<void> showShell(
    WidgetTester tester,
    Size size,
    ValueChanged<int> onSelected,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          selectedIndex: 0,
          labels: const ['Home', 'Rank', 'Library', 'Search', 'Settings'],
          onSelected: onSelected,
          accountLabel: 'Sign in',
          accountBuilder: (_) => const Scaffold(body: Text('Account page')),
          searchBuilder: (_) =>
              const Scaffold(body: TextField(autofocus: true)),
          links: const [],
          contentBuilder: (context) => Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Artwork detail')),
                ),
              ),
              child: const Text('Open artwork'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('detail navigation keeps sidebar and returns to the gallery', (
    tester,
  ) async {
    final selections = <int>[];
    await showShell(tester, const Size(1280, 820), selections.add);
    await tester.tap(find.text('Open artwork'));
    await tester.pumpAndSettle();
    expect(find.text('Artwork detail'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.text('Open artwork'), findsOneWidget);
    await tester.tap(find.text('Open artwork'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(selections, [2]);
    expect(find.text('Open artwork'), findsOneWidget);
    expect(find.text('Artwork detail'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact window fits and supports keyboard search and back', (
    tester,
  ) async {
    final selections = <int>[];
    await showShell(tester, const Size(720, 560), selections.add);
    expect(find.text('PixEz'), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(selections, [1]);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.text('Open artwork'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
