## 1.0.2
### Fixed
* pub.dev score: shortened the package description to within the 60–180
  character limit and wrapped all single-statement `if`s in braces
  (`curly_braces_in_flow_control_structures`, now also enabled in
  `analysis_options.yaml` so it stays clean). No behavior changes.

## 1.0.1
### Fixed
* Upstream issue #338 (and its duplicates #335, #299, #286, #265): the
  multi-`SliverMasonryGrid` scrolling fix in 1.0.0 was incomplete for
  larger sections. With two 60-item sections, `jumpTo(maxScrollExtent)`
  still landed back at offset 0 and repeated drags could jump back by
  thousands of pixels. Root cause: after such a jump, a masonry sliver
  can be retained as only its last child, leaving a column with no
  retained child to seed its offset from; the backward search for a
  leading child could then never seed that column, exhausted all
  children, and returned a scroll offset correction that reset the
  whole viewport. The search now falls through to a forward layout from
  the first item in that state, which rebuilds the exact column offsets
  and reports the sliver's true extent. Covered by regression tests
  using the exact reported scenario (two 60-item sections, `jumpTo`
  and 45 drags).

## 1.0.0
First release of `flutter_staggered_grid_view_plus`, a maintained fork of
`flutter_staggered_grid_view` 0.7.0. The public API is unchanged: migration
only requires changing the package name and the import line.

### Changed
* Raised the SDK constraints to Dart ^3.13.0 / Flutter >= 3.47.0 and updated
  dependencies.
* Fixed all `flutter analyze` issues.

### Fixed
Upstream issues from https://github.com/letsar/flutter_staggered_grid_view:
* #362: layout crashed with negative BoxConstraints when the available extent
  was smaller than the spacing (or zero). Tile extents are now clamped and
  cross axis counts are never zero.
* #361: patterned layouts (e.g. SliverStairedGridDelegate) could throw
  "Infinity or NaN toInt" when converting a scroll offset with a degenerate
  pattern extent.
* #344: `StaggeredGridDelegate` and its two implementations were not exported,
  which made `StaggeredGrid.custom` unusable from the public API.
* #221: SliverQuiltedGridDelegate threw a RangeError for patterns such as
  [1x1, 1x1, 2x2] with crossAxisCount 3, because a wide tile was placed
  without checking that it fits in the remaining columns.
* #338 (and its duplicates #335, #299, #286, #265): scrolling was broken
  with multiple SliverMasonryGrid sections in one CustomScrollView. When a
  section had columns with no retained child yet, the leading-child search
  treated the placeholder column offsets as real offsets and returned a
  bogus scroll correction for the whole offset, so e.g. jumping to the end
  of the list landed mid-list and the second section never appeared. The
  search now only runs when it can actually fetch a leading child.
  (Informed by upstream PR #277 by @JackyMR.)
* #301: `itemBuilder` of MasonryGridView.builder/.count/.extent and
  SliverMasonryGrid.count/.extent now accepts a nullable return value;
  returning null signals the end of the list, like ListView.builder, when
  no itemCount/childCount is given. (Ported from upstream PR #365 by
  @angcyo.)

## 0.7.0
### Changed
* Bump minimal Flutter version to 3.7.0
### Fixed
* Warning with Scrollable.of

## 0.6.2
### Fixed
* Issue with Quilted layout algorithm. (https://github.com/letsar/flutter_staggered_grid_view/issues/232)

## 0.6.1
### Fixed
* Issue when childCount is 0 with Quilted layout.

## 0.6.0
### Added
* SliverAlignedGrid and AlignedGridView widgets.
### Changed
* Renamed SliverMasonryGridDelegate to SliverSimpleGridDelegate.

## 0.5.1
### Added
* StaggeredTile.fit constructor.

## 0.5.0
### Changed
* Stable release 

## 0.5.0-dev.8
### Changed
* Make the `childCount` parameter of `SliverMasonryGrid` constructors, nullable and not required.

## 0.5.0-dev.7
### Fixed
* Remove position issue with staired pattern.

## 0.5.0-dev.6
### Fixed
* Remove extra space on fixed woven grid.

## 0.5.0-dev.5
### Fixed
* Remove extra space on fixed quilted grid (#216).

## 0.5.0-dev.4
### Fixed
* Issue with Woven pattern layout flow in second run.

## 0.5.0-dev.3
### Fixed
* Issue with Woven pattern and text direction.

## 0.5.0-dev.2
### Fixed
* Issue with Quilted pattern.

## 0.5.0-dev.1
### Changed
* Complete rewriting of the package.
It comes now with 5 differents grid layouts (Staggered, Masonry, Quilted, Woven, Staired).

## 0.4.1
### Changed
* Add option to disable keepAlives

## 0.4.0
### Changed
* Stable null safety version

## 0.4.0-nullsafety.3
### Fixed
* LateInitializationError: Local `firstIndex` has not been initialized. (https://github.com/letsar/flutter_staggered_grid_view/issues/151)

## 0.4.0-nullsafety.2
### Added
* Support for state restoration

## 0.4.0-nullsafety.1
### Added
* Null Safety Support

## 0.3.4
### Fixed
* KeepAliveBucket logic, should improve performances

## 0.3.3
### Added
* Support for state restoration.

## 0.3.2
### Fixed
* Flutter version dependency.

## 0.3.1
### Fixed
* Static analysis issues.

## 0.3.0
### Fixed
* Upgrade to AndroidX and fixes the BoxHitTestResult exception (https://github.com/letsar/flutter_staggered_grid_view/issues/49)

## 0.2.7
### Fixed
* Better fix for the bug where items are built only once.

## 0.2.6
### Fixed
* Fix a bug where items are built only once.

## 0.2.5
### Changed
* Use the new SliverWithKeepAliveWidget.

## 0.2.4
### Fixed
* Dart 2.1 mixin support.

## 0.2.3
### Fixed
* Fix the rtl support (https://github.com/letsar/flutter_staggered_grid_view/issues/17).

## 0.2.2
* Add Dart 2 support.

## 0.2.1
* Fix #10 `StatefulWidget.createState must return a subtype of State<AutomaticKeepAliveVariableSizeBox>`.

## 0.2.0
* Add a way to let the tile's content to define the tile's extent in the main axis.
* Add `fit` constructor to `StaggeredTile`.

## 0.1.4
* Add `countBuilder` and `extendBuilder` constructors to `SliverStaggeredGrid`

## 0.1.3
* Remove Flutter SDK constraint

## 0.1.2
* Remove update Flutter SDK constraint

## 0.1.1
* Fix images in readme
* Add dynamic resizing demo

## 0.1.0
* Initial Open Source release