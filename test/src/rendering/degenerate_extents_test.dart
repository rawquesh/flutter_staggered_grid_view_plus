import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

// Regression tests for upstream issue #362 and the same degenerate-extent
// family: when the available extent is smaller than the spacing (or zero),
// tile extents computed as `stride * cellCount - spacing` become negative,
// cross axis counts computed with `.ceil()` can be zero, and patterns can
// end up with a zero main axis extent. All of these used to crash layout
// with negative BoxConstraints, division by zero, or
// "Infinity or NaN toInt" errors.
//
// Note: the zero-width boxes are wrapped in an Align so that the incoming
// constraints are loose; otherwise the test root's tight constraints would
// override the zero width.
void main() {
  testWidgets('StaggeredGrid.count lays out at zero width (#362)', (
    WidgetTester tester,
  ) async {
    // Exact scenario from #362: crossAxisCount 4, spacing 4, width 0 gives a
    // stride of 1 and a tile extent of -3.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 0,
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: const [
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Tile(index: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('StaggeredGrid.extent lays out at zero width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 0,
            child: StaggeredGrid.extent(
              maxCrossAxisExtent: 200,
              children: const [
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Tile(index: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty StaggeredGrid with mainAxisSpacing has zero height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: const [],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('MasonryGridView.count lays out at zero width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 0,
            height: 600,
            child: MasonryGridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: 4,
              itemBuilder: (context, index) => Tile(index: index, height: 10),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('AlignedGridView.extent lays out at zero width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 0,
            height: 600,
            child: AlignedGridView.extent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: 2,
              itemBuilder: (context, index) => Tile(index: index, height: 10),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quilted grid lays out at zero width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 0,
            height: 600,
            child: GridView.custom(
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                pattern: const [QuiltedGridTile(1, 1)],
              ),
              childrenDelegate: SliverChildListDelegate(const [Tile(index: 0)]),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  test('Staired pattern layout tolerates a zero cross axis extent (#361)', () {
    final delegate = SliverStairedGridDelegate(
      pattern: const [StairedGridTile(1, 1)],
    );
    final layout = delegate.getLayout(
      const SliverConstraints(
        axisDirection: AxisDirection.down,
        growthDirection: GrowthDirection.forward,
        userScrollDirection: ScrollDirection.idle,
        scrollOffset: 0,
        precedingScrollExtent: 0,
        overlap: 0,
        remainingPaintExtent: 600,
        crossAxisExtent: 0,
        crossAxisDirection: AxisDirection.right,
        viewportMainAxisExtent: 600,
        remainingCacheExtent: 600,
        cacheOrigin: 0,
      ),
    );
    // The pattern main axis extent is 0 here; converting a scroll offset to
    // a child index must not throw "Infinity or NaN toInt".
    expect(layout.getMinChildIndexForScrollOffset(100), 0);
    expect(layout.getMaxChildIndexForScrollOffset(100), 0);
  });
}
