import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Issue #221: with crossAxisCount 3 and pattern [1x1, 1x1, 2x2], the
  // pattern computation selected the first column with the minimum offset
  // without checking that a 2-wide tile fits there, writing past the end of
  // the offsets list (RangeError) or producing overlapping tiles.
  testWidgets('Quilted pattern with a wide tile that does not fit in the '
      'shortest remaining column', (WidgetTester tester) async {
    await binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.custom(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            pattern: const [
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(2, 2),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) => Tile(index: index),
            childCount: 3,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    // Cell extent: (800 + 4) / 3 - 4 = 264. Stride: 268.
    // Tile 0: 1x1 at (0, 0). Tile 1: 1x1 at (268, 0).
    // Tile 2: 2x2 cannot start at column 2 (only one column left), so it is
    // placed at columns 0-1, below the first row: (0, 268), size 532x532.
    expect(tester.getSize(find.text('0')), const Size(264, 264));
    expect(tester.getTopLeft(find.text('0')), const Offset(0, 0));
    expect(tester.getSize(find.text('1')), const Size(264, 264));
    expect(tester.getTopLeft(find.text('1')), const Offset(268, 0));
    expect(tester.getSize(find.text('2')), const Size(532, 532));
    expect(tester.getTopLeft(find.text('2')), const Offset(0, 268));
  });
}
