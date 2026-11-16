import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:pixez/desktop/desktop_layout.dart';
import 'package:pixez/desktop/desktop_list_target.dart';
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

  Future<void> pressMeta(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('repeated Cmd+F reuses the open search page', (tester) async {
    await showShell(tester, const Size(1200, 800), (_) {});
    await pressMeta(tester, LogicalKeyboardKey.keyF);
    await pressMeta(tester, LogicalKeyboardKey.keyF);
    expect(find.byType(TextField), findsOneWidget);
    await pressMeta(tester, LogicalKeyboardKey.bracketLeft);
    expect(find.text('Open artwork'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('detail pages hide the section title and open in the pane', (
    tester,
  ) async {
    await showShell(tester, const Size(1200, 800), (_) {});
    expect(find.text('Home'), findsNWidgets(2));
    expect(
      DesktopShell.open((_) => const Scaffold(body: Text('Jobs'))),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(find.text('Jobs'), findsOneWidget);
    // Sidebar entry only; the header no longer repeats the section name.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('PixEz'), findsOneWidget);
  });

  testWidgets('Cmd+R refreshes only the visible list', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final visible = _CountingController();
    final hidden = _CountingController();
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          selectedIndex: 0,
          labels: const ['Home', 'Rank', 'Library', 'Search', 'Settings'],
          onSelected: (_) {},
          accountLabel: 'Sign in',
          accountBuilder: (_) => const SizedBox(),
          searchBuilder: (_) => const SizedBox(),
          links: const [],
          contentBuilder: (_) => Stack(
            children: [
              DesktopListTarget(
                refreshController: visible,
                child: const Text('first'),
              ),
              // Like a kept-alive PageView neighbour: laid out off screen.
              Transform.translate(
                offset: const Offset(5000, 0),
                child: DesktopListTarget(
                  refreshController: hidden,
                  child: const Text('second'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await pressMeta(tester, LogicalKeyboardKey.keyR);
    expect(visible.refreshes, 1);
    expect(hidden.refreshes, 0);
  });

  testWidgets('arrow keys scroll the visible list instead of moving focus', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final visible = ScrollController();
    final hidden = ScrollController();
    addTearDown(visible.dispose);
    addTearDown(hidden.dispose);
    Widget list(ScrollController controller) => DesktopListTarget(
      scrollController: controller,
      child: ListView(
        controller: controller,
        children: [
          for (var i = 0; i < 40; i++)
            TextButton(onPressed: () {}, child: Text('item $i')),
        ],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DesktopShell(
          selectedIndex: 0,
          labels: const ['Home', 'Rank', 'Library', 'Search', 'Settings'],
          onSelected: (_) {},
          accountLabel: 'Sign in',
          accountBuilder: (_) => const SizedBox(),
          searchBuilder: (_) => const SizedBox(),
          links: const [],
          contentBuilder: (_) => Stack(
            children: [
              list(visible),
              Transform.translate(
                offset: const Offset(5000, 0),
                child: list(hidden),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final focused = FocusManager.instance.primaryFocus;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(visible.offset, 80);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(visible.offset, visible.position.maxScrollExtent);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(visible.offset, 0);
    expect(hidden.offset, 0);
    expect(FocusManager.instance.primaryFocus, focused);
  });
}

class _CountingController extends EasyRefreshController {
  int refreshes = 0;

  @override
  Future callRefresh({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) async {
    refreshes++;
  }
}
