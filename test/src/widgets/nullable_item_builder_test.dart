import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for upstream issue #301:
// "Allow itemBuilder to return nullable Widget and handle it like
// ListView.builder". Returning null from the item builder must signal the
// end of the list when no itemCount is provided (ported from upstream
// PR #365 by @angcyo, extended to every builder-based masonry constructor).
void main() {
  Widget buildItem(int index) {
    return SizedBox(
      height: 40.0 + (index % 3) * 20.0,
      child: Text('item $index'),
    );
  }

  testWidgets(
    'MasonryGridView.builder ends the list at the first null (no itemCount)',
    (tester) async {
      final builtIndexes = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: MasonryGridView.builder(
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              builtIndexes.add(index);
              if (index >= 6) return null;
              return buildItem(index);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 6; i++) {
        expect(find.text('item $i'), findsOneWidget, reason: 'item $i missing');
      }
      expect(find.text('item 6'), findsNothing);
      // The builder may be probed once past the end (index 6) to learn the
      // list is over, but it must never be asked for anything beyond that.
      expect(builtIndexes.where((i) => i > 6), isEmpty);

      // Scroll to the very end: still exactly 6 items, no error, finite
      // scroll extent.
      final state = tester.state<ScrollableState>(find.byType(Scrollable));
      state.position.jumpTo(state.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(state.position.maxScrollExtent.isFinite, isTrue);
      for (var i = 0; i < 6; i++) {
        expect(find.text('item $i'), findsWidgets);
      }
    },
  );

  testWidgets(
    'MasonryGridView.count ends the list at the first null (no itemCount)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MasonryGridView.count(
            crossAxisCount: 2,
            itemBuilder: (context, index) =>
                index >= 4 ? null : buildItem(index),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        expect(find.text('item $i'), findsOneWidget);
      }
      expect(find.text('item 4'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'MasonryGridView.extent ends the list at the first null (no itemCount)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MasonryGridView.extent(
            maxCrossAxisExtent: 200,
            itemBuilder: (context, index) =>
                index >= 4 ? null : buildItem(index),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        expect(find.text('item $i'), findsOneWidget);
      }
      expect(find.text('item 4'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'SliverMasonryGrid.count ends the list at the first null (no childCount)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                itemBuilder: (context, index) =>
                    index >= 4 ? null : buildItem(index),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        expect(find.text('item $i'), findsOneWidget);
      }
      expect(find.text('item 4'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Non-null builders with an explicit itemCount keep working unchanged',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MasonryGridView.count(
            crossAxisCount: 2,
            itemCount: 3,
            itemBuilder: (context, index) => buildItem(index),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        expect(find.text('item $i'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
