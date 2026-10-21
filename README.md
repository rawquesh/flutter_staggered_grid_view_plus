# flutter_staggered_grid_view_plus

> **Migration & Maintenance Notice:**  
> This package is a maintained successor and drop-in migration of [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) (GitHub: [letsar/flutter_staggered_grid_view](https://github.com/letsar/flutter_staggered_grid_view)).  
> The original package has not received a release since July 2023 (v0.7.0).  
> `flutter_staggered_grid_view_plus` aims to be 100% API-compatible for modern Flutter releases.
>
> **Migration Steps:**
> 1. In `pubspec.yaml`, replace `flutter_staggered_grid_view` with `flutter_staggered_grid_view_plus`.
> 2. Change your import line from:  
>    `import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';`  
>    to:  
>    `import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view_plus.dart';`
>
> Full credit and attribution to the original author, Romain Rastel ([@letsar](https://github.com/letsar)). The original MIT License is preserved.

Provides a collection of Flutter grids layouts.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flutter_staggered_grid_view_plus: <latest_version>
```

In your library add the following import:

```dart
import 'package:flutter_staggered_grid_view_plus/flutter_staggered_grid_view_plus.dart';
```

For help getting started with Flutter, view the online [documentation][flutter_documentation].

## Layouts

This package contains various grid layouts. In the following section, you'll discover each one of them.
The explanation of the layout will always considered a top-to-bottom and left-to-right directions to simplify the description. However it is possible to change these directions in the code. 

### **Staggered**
![Staggered Grid Layout][staggered_preview]

This layout is intended for a small number of items. 
I didn't find, for the moment, a performant algorithm which would work in a `Sliver` context, that's why this is not a GridView and therefore there are no `SliverStaggeredGrid`.

#### **Grid properties**
- Evenly divided in *n* columns
- Small number of items
- Not scrollable

#### **Tile properties**
- Must occupy 1 to *n* columns

#### **Placement algorithm**
- Top-most and then left-most

#### **Example**
Below you'll find the code to create this grid layout:

![Staggered example][staggered_example]

```dart
StaggeredGrid.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  children: const [
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: Tile(index: 0),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1,
      child: Tile(index: 1),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Tile(index: 2),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Tile(index: 3),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 4,
      mainAxisCellCount: 2,
      child: Tile(index: 4),
    ),
  ],
);
```

### **Masonry**
![Masonry Grid Layout][masonry_preview]

This layout facilitates the browsing of uncropped peer content. Container heights are sized based on the widget size.

This is a complete separate grid and not a `SliverGridDelegate` for performance reasons. The `SliverGrid` is great but it needs to have a layout which does not depends on the size of its children. Otherwise we have to compute the size to all children before the end of the cache, which is really not performant for a masonry layout.

#### **Grid properties**
- Evenly divided in *n* columns

#### **Tile properties**
- Must occupy 1 column only

#### **Placement algorithm**
- Top-most and then left-most

#### **Example**
Below you'll find the code to create this grid layout:

![Masonry example][masonry_example]

```dart
MasonryGridView.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  itemBuilder: (context, index) {
    return Tile(
      index: index,
      extent: (index % 5 + 1) * 100,
    );
  },
);
```

### **Quilted**
![Quilted Grid Layout][quilted_preview]

This layout emphasizes certain items over others in a collection. It creates hierarchy using varied container sizes and ratios.

**This is a specific delegate for the built-in `GridView` (or `SliverGrid`) widget. That's why the example below will create such a layout with a `GridView`.**

#### **Grid properties**
- Evenly divided in *n* columns
- The height of each row is equal to the width of each column
- A pattern defines the size of the tiles and different mode of repetition are possible

#### **Tile properties**
- Must occupy 1 to *n* columns
- Must occupy 1 or more entire rows

#### **Placement algorithm**
- Top-most and then left-most

#### **Example**
Below you'll find the code to create this grid layout:

![Quilted example][quilted_example]

```dart
GridView.custom(
  gridDelegate: SliverQuiltedGridDelegate(
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    repeatPattern: QuiltedGridRepeatPattern.inverted,
    pattern: [
      QuiltedGridTile(2, 2),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 2),
    ],
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => Tile(index: index),
  ),
);
```

### **Woven**
![Woven Grid Layout][woven_preview]

This layout facilitates the browsing of peer content. The items are displayed in containers of varying ratios to create a rhythmic layout.

**This is a specific delegate for the built-in `GridView` (or `SliverGrid`) widget. That's why the example below will create such a layout with a `GridView`.**

#### **Grid properties**
- Evenly divided in *n* columns
- The height the rows is the maximum height of the tiles
- A pattern defines the size of the tiles
- The size of the tiles follows the pattern in a 'z' sequence.

#### **Tile properties**
- The height is defined by an `aspectRatio` (width/height)
- The width is defined by a `crossAxisRatio` (width/column's width) between 0 (exclusive) and 1 (inclusive)
- Each tile can define how it is aligned within the available space

#### **Placement algorithm**
- Top-most and then left-most

#### **Example**
Below you'll find the code to create this grid layout:

![Woven example][woven_example]

```dart
GridView.custom(
  gridDelegate: SliverWovenGridDelegate.count(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    pattern: [
      WovenGridTile(1),
      WovenGridTile(
        5 / 7,
        crossAxisRatio: 0.9,
        alignment: AlignmentDirectional.centerEnd,
      ),
    ],
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => Tile(index: index),
  ),
);
```

### **Staired**
![Staired Grid Layout][staired_preview]

This layout uses alternating container sizes and ratios to create a rhythmic effect. It's another kind of woven grid layout.

**This is a specific delegate for the built-in `GridView` (or `SliverGrid`) widget. That's why the example below will create such a layout with a `GridView`.**

#### **Grid properties**
- A pattern defines the size of the tiles
- Each tile is shifted from the previous one by a margin in both axis
- The placement follows a 'z' sequence

#### **Tile properties**
- The height is defined by an `aspectRatio` (width/height)
- The width is defined by a `crossAxisRatio` (width/available horizontal space) between 0 (exclusive) and 1 (inclusive)

#### **Placement algorithm**
- In a 'z' sequence

#### **Example**
Below you'll find the code to create this grid layout:

![Staired example][staired_example]

```dart
GridView.custom(
  gridDelegate: SliverStairedGridDelegate(
    crossAxisSpacing: 48,
    mainAxisSpacing: 24,
    startCrossAxisDirectionReversed: true,
    pattern: [
      StairedGridTile(0.5, 1),
      StairedGridTile(0.5, 3 / 4),
      StairedGridTile(1.0, 10 / 4),
    ],
  ),
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => Tile(index: index),
  ),
);
```

### **Aligned**
![Aligned Grid Layout][aligned_preview]

This layout is also called CSS Grid. This is a common grid layout on the web, where each item within a track has the maximum cross axis extent of its siblings.

#### **Grid properties**
- Evenly divided in *n* columns
- The rows can have differents heights

#### **Tile properties**
- Must occupy 1 column only
- Each tile has the same height as the tallest one of the row.

#### **Placement algorithm**
- Top-most and then left-most

#### **Example**
Below you'll find the code to create this grid layout:

![Aligned example][aligned_example]

```dart
AlignedGridView.count(
  crossAxisCount: 4,
  mainAxisSpacing: 4,
  crossAxisSpacing: 4,
  itemBuilder: (context, index) {
    return Tile(
      index: index,
      extent: (index % 7 + 1) * 30,
    );
  },
);
```

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

<!-- Links -->
[github_action_badge]: https://github.com/rawquesh/flutter_staggered_grid_view_plus/workflows/Build/badge.svg
[github_action]: https://github.com/rawquesh/flutter_staggered_grid_view_plus/actions
[pub_badge]: https://img.shields.io/pub/v/flutter_staggered_grid_view_plus.svg
[pub]: https://pub.dev/packages/flutter_staggered_grid_view_plus
[codecov]: https://codecov.io/gh/rawquesh/flutter_staggered_grid_view_plus
[codecov_badge]: https://codecov.io/gh/rawquesh/flutter_staggered_grid_view_plus/branch/master/graph/badge.svg
[issue]: https://github.com/rawquesh/flutter_staggered_grid_view_plus/issues
[pr]: https://github.com/rawquesh/flutter_staggered_grid_view_plus/pulls
[flutter_documentation]: https://docs.flutter.dev/
[staggered_preview]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/staggered.png
[masonry_preview]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/masonry.png
[quilted_preview]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/quilted.png
[woven_preview]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/woven.png
[staired_preview]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/staired.png
[aligned_preview]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/aligned.png
[staggered_example]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/staggered_example.png
[masonry_example]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/masonry_example.png
[quilted_example]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/quilted_example.png
[woven_example]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/woven_example.png
[staired_example]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/staired_example.png
[aligned_example]: https://raw.githubusercontent.com/rawquesh/flutter_staggered_grid_view_plus/master/docs/images/aligned_example.png