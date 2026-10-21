import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for the upstream multi-sliver scrolling family
// (#338 and its duplicates #335, #299, #286, #265).
//
// Root cause: in RenderSliverMasonryGrid.performLayout, the search for the
// first visible child used `scrollOffsets.any((x) => x > scrollOffset)`,
// where scrollOffsets entries for columns that have no retained child yet
// are double.infinity. A masonry sliver that starts below the viewport (or
// was garbage-collected down to a single child) has mostly infinite seeds,
// so the loop wrongly tried to fetch leading children and, finding none,
// returned a bogus scrollOffsetCorrection of -scrollOffset. When jumping
// to the (initially over-estimated) maxScrollExtent with two masonry
// sections, this cascade landed the viewport mid-list (offset 250 instead
// of the true max 970) and the second grid was never laid out.
void main() {
  double heightA(int i) => [90.0, 140.0, 60.0, 110.0][i % 4];
  double heightB(int i) => [70.0, 120.0, 50.0][i % 3];

  Widget section(
    String prefix,
    int crossAxisCount,
    int childCount,
    double Function(int) height,
  ) {
    return SliverMasonryGrid.count(
      crossAxisCount: crossAxisCount,
      itemBuilder: (context, i) => SizedBox(
        key: ValueKey('$prefix$i'),
        height: height(i),
        child: Text('$prefix$i'),
      ),
      childCount: childCount,
    );
  }

  for (final scrollCacheExtent in <ScrollCacheExtent?>[
    null,
    const ScrollCacheExtent.pixels(0),
  ]) {
    testWidgets(
      'jumpTo(maxScrollExtent) reaches the end with two SliverMasonryGrid '
      'sections (#338, scrollCacheExtent: $scrollCacheExtent)',
      (tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          MaterialApp(
            home: CustomScrollView(
              controller: controller,
              scrollCacheExtent: scrollCacheExtent,
              slivers: [
                section('A', 2, 20, heightA),
                section('B', 3, 18, heightB),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The initial maxScrollExtent is an over-estimate (1726.67 for a
        // true max of 970 in this fixture). Jumping to it must still land
        // exactly on the true end of the list, with the last item of the
        // second grid laid out.
        controller.jumpTo(controller.position.maxScrollExtent);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          controller.offset,
          closeTo(controller.position.maxScrollExtent, 0.5),
          reason: 'viewport did not settle at the end of the list',
        );
        expect(find.byKey(const ValueKey('B17')), findsOneWidget);
        var bCount = 0;
        for (var i = 0; i < 18; i++) {
          if (find.byKey(ValueKey('B$i')).evaluate().isNotEmpty) bCount++;
        }
        expect(bCount, greaterThan(0));

        // Back to the top: the first item of the first grid is at the
        // origin again and no items overlap.
        controller.jumpTo(0);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getRect(find.byKey(const ValueKey('A0'))).top, 0.0);
        final rects = <Rect>[];
        for (var i = 0; i < 8; i++) {
          final finder = find.byKey(ValueKey('A$i'));
          if (finder.evaluate().isNotEmpty) rects.add(tester.getRect(finder));
        }
        for (var i = 0; i < rects.length; i++) {
          for (var j = i + 1; j < rects.length; j++) {
            final a = rects[i], b = rects[j];
            expect(
              a.left < b.right &&
                  b.left < a.right &&
                  a.top < b.bottom &&
                  b.top < a.bottom,
              isFalse,
              reason: 'items $i and $j overlap after the round trip',
            );
          }
        }
      },
    );
  }

  testWidgets(
    'jumpTo(maxScrollExtent) reaches the end when a SliverMasonryGrid '
    'follows a tall header',
    (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            controller: controller,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 1200)),
              section('B', 3, 18, heightB),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        controller.offset,
        closeTo(controller.position.maxScrollExtent, 0.5),
        reason: 'viewport did not settle at the end of the list',
      );
      expect(find.byKey(const ValueKey('B17')), findsOneWidget);
    },
  );
}
