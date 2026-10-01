import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/component/detail_jump_button.dart';

Widget harness({required GlobalKey anchorKey, required ScrollController c}) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: c,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SizedBox(
                    height: 400,
                    child: Text('page $i'),
                  ),
                  childCount: 10, // 4000px of "images"
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: anchorKey,
                  height: 50,
                  child: const Text('DETAIL'),
                ),
              ),
              SliverToBoxAdapter(
                child: const SizedBox(height: 2000, child: Text('grid')),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: DetailJumpButton(anchorKey: anchorKey, scrollController: c),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('jump lands on anchor when it is below the viewport',
      (tester) async {
    final anchorKey = GlobalKey();
    final c = ScrollController();
    await tester.pumpWidget(harness(anchorKey: anchorKey, c: c));
    await tester.pumpAndSettle();

    expect(c.offset, 0); // at top, anchor far below
    await tester.tap(find.byType(DetailJumpButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // viewport 600, anchor top at 4000 -> expected offset 4000 - 300 = 3700
    expect((c.offset - 3700).abs() < 40, isTrue,
        reason: 'offset was ${c.offset}');
  });

  testWidgets('icon flips direction based on anchor position',
      (tester) async {
    final anchorKey = GlobalKey();
    final c = ScrollController();
    await tester.pumpWidget(harness(anchorKey: anchorKey, c: c));
    await tester.pumpAndSettle();

    // anchor below -> chevron down
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    await tester.tap(find.byType(DetailJumpButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    // anchor now visible (centered) -> chevron up
    expect(find.byIcon(Icons.expand_less), findsOneWidget);

    // scroll back to top -> anchor below again -> chevron down
    c.jumpTo(0);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('jump works from below the anchor (scrolls up)',
      (tester) async {
    final anchorKey = GlobalKey();
    final c = ScrollController();
    await tester.pumpWidget(harness(anchorKey: anchorKey, c: c));
    await tester.pumpAndSettle();

    c.jumpTo(c.position.maxScrollExtent); // deep in the grid
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.expand_less), findsOneWidget);

    await tester.tap(find.byType(DetailJumpButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect((c.offset - 3700).abs() < 40, isTrue,
        reason: 'offset was ${c.offset}');
  });
}


