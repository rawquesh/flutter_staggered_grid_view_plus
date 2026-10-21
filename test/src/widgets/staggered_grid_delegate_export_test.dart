import 'package:flutter/widgets.dart';
// This test intentionally imports ONLY the public package entry point.
// Issue #344: StaggeredGrid.custom could not be used from outside the
// package because StaggeredGridDelegate (and its implementations) were not
// exported, even though the public StaggeredGrid.custom constructor requires
// them.
import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

class _FixedCountDelegate extends StaggeredGridDelegate {
  const _FixedCountDelegate(this.count);

  final int count;

  @override
  int getCrossAxisCount(double crossAxisExtent, double crossAxisSpacing) {
    return count;
  }

  @override
  bool shouldRelayout(_FixedCountDelegate oldDelegate) {
    return oldDelegate.count != count;
  }
}

void main() {
  testWidgets('StaggeredGrid.custom is usable through the public API', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.custom(
          delegate: const StaggeredGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          children: [
            const StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 0),
            ),
            const StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 1),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // Screen is 800 wide, 2 columns, no spacing: tiles are 400x400.
    expect(tester.getTopLeft(find.text('1')), const Offset(400, 0));
  });

  testWidgets('StaggeredGrid.custom accepts a user-defined delegate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.custom(
          delegate: const _FixedCountDelegate(4),
          children: [
            const StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 0),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text('0')), const Size(200, 200));
  });

  testWidgets('StaggeredGrid.extent delegate type is publicly nameable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredGrid.custom(
          delegate: const StaggeredGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
          children: [
            const StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Tile(index: 0),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsOneWidget);
  });
}
