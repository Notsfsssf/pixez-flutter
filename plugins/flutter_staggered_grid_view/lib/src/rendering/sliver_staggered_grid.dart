import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_staggered_grid_view/src/widgets/staggered_tile.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_variable_size_box_adaptor.dart';

/// Signature for a function that creates [StaggeredTile] for a given index.
typedef StaggeredTile IndexedStaggeredTileBuilder(int index);

/// Specifies how a staggered grid is configured.
@immutable
class StaggeredGridConfiguration {
  ///  Creates an object that holds the configuration of a staggered grid.
  StaggeredGridConfiguration({
    @required this.crossAxisCount,
    @required this.staggeredTileBuilder,
    @required this.cellExtent,
    @required this.mainAxisSpacing,
    @required this.crossAxisSpacing,
    @required this.reverseCrossAxis,
    @required this.staggeredTileCount,
    this.mainAxisOffsetsCacheSize = 3,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(staggeredTileBuilder != null),
        assert(cellExtent != null && cellExtent >= 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(
            mainAxisOffsetsCacheSize != null && mainAxisOffsetsCacheSize > 0),
        cellStride = cellExtent + crossAxisSpacing;

  /// The maximum number of children in the cross axis.
  final int crossAxisCount;

  /// The number of pixels from the leading edge of one cell to the trailing
  /// edge of the same cell in both axis.
  final double cellExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// Called to get the tile at the specified index for the
  /// [SliverGridStaggeredTileLayout].
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  /// The total number of tiles this delegate can provide.
  ///
  /// If null, the number of tiles is determined by the least index for which
  /// [builder] returns null.
  final int staggeredTileCount;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  final double cellStride;

  /// The number of pages necessary to cache a mainAxisOffsets value.
  final int mainAxisOffsetsCacheSize;

  List<double> generateMainAxisOffsets() =>
      new List.generate(crossAxisCount, (i) => 0.0);

  /// Gets a normalized tile for the given index.
  StaggeredTile getStaggeredTile(int index) {
    StaggeredTile tile;
    if (staggeredTileCount == null || index < staggeredTileCount) {
      // There is maybe a tile for this index.
      tile = _normalizeStaggeredTile(staggeredTileBuilder(index));
    }
    return tile;
  }

  /// Computes the main axis extent of any staggered tile.
  double _getStaggeredTileMainAxisExtent(StaggeredTile tile) {
    return tile.mainAxisExtent ??
        (tile.mainAxisCellCount * cellExtent) +
            (tile.mainAxisCellCount - 1) * mainAxisSpacing;
  }

  /// Creates a staggered tile with the computed extent from the given tile.
  StaggeredTile _normalizeStaggeredTile(StaggeredTile staggeredTile) {
    if (staggeredTile == null) {
      return null;
    } else {
      int crossAxisCellCount =
          staggeredTile.crossAxisCellCount.clamp(0, crossAxisCount);
      if (staggeredTile.fitContent) {
        return new StaggeredTile.fit(crossAxisCellCount);
      } else {
        return new StaggeredTile.extent(
            crossAxisCellCount, _getStaggeredTileMainAxisExtent(staggeredTile));
      }
    }
  }
}

class _Block {
  const _Block(this.index, this.crossAxisCount, this.minOffset, this.maxOffset);

  final int index;
  final int crossAxisCount;
  final double minOffset;
  final double maxOffset;
}

const double _epsilon = 0.0001;

bool _nearEqual(double d1, double d2) {
  return (d1 - d2).abs() < _epsilon;
}

/// Describes the placement of a child in a [RenderSliverStaggeredGrid].
///
/// See also:
///
///  * [RenderSliverStaggeredGrid], which uses this class during its
///    [RenderSliverStaggeredGrid.performLayout] method.
@immutable
class SliverStaggeredGridGeometry extends SliverGridGeometry {
  /// Creates an object that describes the placement of a child in a [RenderSliverStaggeredGrid].
  const SliverStaggeredGridGeometry({
    @required scrollOffset,
    @required crossAxisOffset,
    @required mainAxisExtent,
    @required crossAxisExtent,
    @required this.crossAxisCellCount,
    @required this.blockIndex,
  }) : super(
            scrollOffset: scrollOffset,
            crossAxisOffset: crossAxisOffset,
            mainAxisExtent: mainAxisExtent,
            crossAxisExtent: crossAxisExtent);

  final int crossAxisCellCount;

  final int blockIndex;

  bool get hasTrailingScrollOffset => mainAxisExtent != null;

  SliverStaggeredGridGeometry copyWith({
    double scrollOffset,
    double crossAxisOffset,
    double mainAxisExtent,
    double crossAxisExtent,
    int crossAxisCellCount,
    int blockIndex,
  }) {
    return new SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset ?? this.scrollOffset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      mainAxisExtent: mainAxisExtent ?? this.mainAxisExtent,
      crossAxisExtent: crossAxisExtent ?? this.crossAxisExtent,
      crossAxisCellCount: crossAxisCellCount ?? this.crossAxisCellCount,
      blockIndex: blockIndex ?? this.blockIndex,
    );
  }

  /// Returns a tight [BoxConstraints] that forces the child to have the
  /// required size.
  @override
  BoxConstraints getBoxConstraints(SliverConstraints constraints) {
    return constraints.asBoxConstraints(
      minExtent: mainAxisExtent ?? 0.0,
      maxExtent: mainAxisExtent ?? double.infinity,
      crossAxisExtent: crossAxisExtent,
    );
  }

  @override
  String toString() {
    return 'SliverStaggeredGridGeometry('
        'scrollOffset: $scrollOffset, '
        'crossAxisOffset: $crossAxisOffset, '
        'mainAxisExtent: $mainAxisExtent, '
        'crossAxisExtent: $crossAxisExtent, '
        'crossAxisCellCount: $crossAxisCellCount, '
        'startIndex: $blockIndex'
        ')';
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [RenderSliverGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// See also:
///
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
class RenderSliverStaggeredGrid extends RenderSliverVariableSizeBoxAdaptor {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [configuration] and [childManager] arguments must not be null.
  RenderSliverStaggeredGrid({
    @required RenderSliverVariableSizeBoxChildManager childManager,
    @required SliverStaggeredGridDelegate gridDelegate,
  })  : assert(gridDelegate != null),
        _gridDelegate = gridDelegate,
        _pageSizeToViewportOffsets =
            new HashMap<double, SplayTreeMap<int, _ViewportOffsets>>(),
        super(childManager: childManager);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverVariableSizeBoxAdaptorParentData) {
      var data = new SliverVariableSizeBoxAdaptorParentData();

      // By default we will keep it true.
      //data.keepAlive = true;
      child.parentData = data;
    }
  }

  /// The delegate that controls the configuration of the staggered grid.
  SliverStaggeredGridDelegate get gridDelegate => _gridDelegate;
  SliverStaggeredGridDelegate _gridDelegate;
  set gridDelegate(SliverStaggeredGridDelegate value) {
    assert(value != null);
    if (_gridDelegate == value) return;
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) markNeedsLayout();
    _gridDelegate = value;
  }

  HashMap<double, SplayTreeMap<int, _ViewportOffsets>>
      _pageSizeToViewportOffsets;

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    bool reachedEnd = false;
    double trailingScrollOffset = 0.0;
    double leadingScrollOffset = double.infinity;
    bool visible = false;
    int firstIndex = 0;
    int lastIndex = 0;

    StaggeredGridConfiguration configuration =
        _gridDelegate.getConfiguration(constraints);

    double pageSize = configuration.mainAxisOffsetsCacheSize *
        constraints.viewportMainAxisExtent;
    if (pageSize == 0.0) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }
    int pageIndex = scrollOffset ~/ pageSize;
    assert(pageIndex >= 0);

    // If the viewport is resized, we keep the in memory the old offsets caches. (Useful if only the orientation changes multiple times).
    SplayTreeMap<int, _ViewportOffsets> viewportOffsets =
        _pageSizeToViewportOffsets.putIfAbsent(
            pageSize, () => new SplayTreeMap<int, _ViewportOffsets>());

    _ViewportOffsets viewportOffset;
    if (viewportOffsets.isEmpty) {
      viewportOffset = new _ViewportOffsets(
          configuration.generateMainAxisOffsets(), pageSize);
      viewportOffsets[0] = viewportOffset;
    } else {
      int smallestKey = viewportOffsets.lastKeyBefore(pageIndex + 1);
      viewportOffset = viewportOffsets[smallestKey];
    }

    // A staggered grid always have to layout the child from the zero-index based one to the last visible.
    var mainAxisOffsets = viewportOffset.mainAxisOffsets.toList();
    HashSet<int> visibleIndices = new HashSet<int>();

    // Iterate through all children while they can be visible.
    for (var index = viewportOffset.firstChildIndex;
        mainAxisOffsets.any((o) => o <= targetEndScrollOffset);
        index++) {
      SliverStaggeredGridGeometry geometry =
          getSliverStaggeredGeometry(index, configuration, mainAxisOffsets);
      if (geometry == null) {
        // There are either no children, or we are past the end of all our children.
        reachedEnd = true;
        break;
      }

      final bool hasTrailingScrollOffset = geometry.hasTrailingScrollOffset;
      RenderBox child;
      if (!hasTrailingScrollOffset) {
        // Layout the child to compute its tailingScrollOffset.
        BoxConstraints constraints =
            new BoxConstraints.tightFor(width: geometry.crossAxisExtent);
        child = addAndLayoutChild(index, constraints, parentUsesSize: true);
        geometry = geometry.copyWith(mainAxisExtent: paintExtentOf(child));
      }

      if (!visible &&
          targetEndScrollOffset >= geometry.scrollOffset &&
          scrollOffset <= geometry.trailingScrollOffset) {
        visible = true;
        leadingScrollOffset = geometry.scrollOffset;
        firstIndex = index;
      }

      if (visible && hasTrailingScrollOffset) {
        child =
            addAndLayoutChild(index, geometry.getBoxConstraints(constraints));
      }

      if (child != null) {
        SliverVariableSizeBoxAdaptorParentData childParentData =
            child.parentData;
        childParentData.layoutOffset = geometry.scrollOffset;
        childParentData.crossAxisOffset = geometry.crossAxisOffset;
        assert(childParentData.index == index);
      }

      if (visible && indices.contains(index)) {
        visibleIndices.add(index);
      }

      if (geometry.trailingScrollOffset >=
          viewportOffset.trailingScrollOffset) {
        int nextPageIndex = viewportOffset.pageIndex + 1;
        var nextViewportOffset = new _ViewportOffsets(mainAxisOffsets,
            (nextPageIndex + 1) * pageSize, nextPageIndex, index);
        viewportOffsets[nextPageIndex] = nextViewportOffset;
        viewportOffset = nextViewportOffset;
      }

      final double endOffset =
          geometry.trailingScrollOffset + configuration.mainAxisSpacing;
      for (var i = 0; i < geometry.crossAxisCellCount; i++) {
        mainAxisOffsets[i + geometry.blockIndex] = endOffset;
      }

      trailingScrollOffset = mainAxisOffsets.reduce(math.max);
      lastIndex = index;
    }

    collectGarbage(visibleIndices);

    if (!visible) {
      if (scrollOffset > viewportOffset.trailingScrollOffset) {
        // We are outside the bounds, we have to correct the scroll.
        double viewportOffsetScrollOffset = pageSize * viewportOffset.pageIndex;
        double correction = viewportOffsetScrollOffset - scrollOffset;
        geometry = new SliverGeometry(
          scrollOffsetCorrection: correction,
        );
      } else {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
      }
      return;
    }

    double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = trailingScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      );
      assert(estimatedMaxScrollOffset >=
          trailingScrollOffset - leadingScrollOffset);
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    geometry = new SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: trailingScrollOffset > targetEndScrollOffset ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == trailingScrollOffset)
      childManager.setDidUnderflow(true);
    childManager.didFinishLayout();
  }

  static SliverStaggeredGridGeometry getSliverStaggeredGeometry(int index,
      StaggeredGridConfiguration configuration, List<double> offsets) {
    var tile = configuration.getStaggeredTile(index);
    if (tile == null) return null;

    var block = _findFirstAvailableBlockWithCrossAxisCount(
        tile.crossAxisCellCount, offsets);

    var scrollOffset = block.minOffset;
    var blockIndex = block.index;
    if (configuration.reverseCrossAxis) {
      blockIndex =
          configuration.crossAxisCount - tile.crossAxisCellCount - blockIndex;
    }
    var crossAxisOffset = blockIndex * configuration.cellStride;
    var geometry = new SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: tile.mainAxisExtent,
      crossAxisExtent: configuration.cellStride * tile.crossAxisCellCount -
          configuration.crossAxisSpacing,
      crossAxisCellCount: tile.crossAxisCellCount,
      blockIndex: block.index,
    );
    return geometry;
  }

  /// Finds the first available block with at least the specified [crossAxisCount] in the [offsets] list.
  static _Block _findFirstAvailableBlockWithCrossAxisCount(
      int crossAxisCount, List<double> offsets) {
    return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
        crossAxisCount, new List.from(offsets));
  }

  /// Finds the first available block with at least the specified [crossAxisCount].
  static _Block _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
      int crossAxisCount, List<double> offsets) {
    _Block block = _findFirstAvailableBlock(offsets);
    if (block.crossAxisCount < crossAxisCount) {
      // Not enough space for the specified cross axis count.
      // We have to fill this block and try again.
      for (var i = 0; i < block.crossAxisCount; ++i) {
        offsets[i + block.index] = block.maxOffset;
      }
      return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(
          crossAxisCount, offsets);
    } else {
      return block;
    }
  }

  /// Finds the first available block for the specified [offsets] list.
  static _Block _findFirstAvailableBlock(List<double> offsets) {
    int index = 0;
    double minBlockOffset = double.infinity;
    double maxBlockOffset = double.infinity;
    int crossAxisCount = 1;
    bool contiguous = false;

    // We have to use the _nearEqual function because of floating-point arithmetic.
    // Ex: 0.1 + 0.2 = 0.30000000000000004 and not 0.3.

    for (var i = index; i < offsets.length; ++i) {
      double offset = offsets[i];
      if (offset < minBlockOffset && !_nearEqual(offset, minBlockOffset)) {
        index = i;
        maxBlockOffset = minBlockOffset;
        minBlockOffset = offset;
        crossAxisCount = 1;
        contiguous = true;
      } else if (_nearEqual(offset, minBlockOffset) && contiguous) {
        crossAxisCount++;
      } else if (offset < maxBlockOffset &&
          offset > minBlockOffset &&
          !_nearEqual(offset, minBlockOffset)) {
        contiguous = false;
        maxBlockOffset = offset;
      } else {
        contiguous = false;
      }
    }

    return new _Block(index, crossAxisCount, minBlockOffset, maxBlockOffset);
  }
}

class _ViewportOffsets {
  _ViewportOffsets(
    List<double> mainAxisOffsets,
    this.trailingScrollOffset, [
    this.pageIndex = 0,
    this.firstChildIndex = 0,
  ]) : this.mainAxisOffsets = new List.from(mainAxisOffsets);

  final int pageIndex;

  final int firstChildIndex;

  final double trailingScrollOffset;

  final List<double> mainAxisOffsets;

  @override
  String toString() =>
      '[$pageIndex-$trailingScrollOffset] ($firstChildIndex, $mainAxisOffsets)';
}

/// Creates staggered grid layouts.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [StaggeredGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverStaggeredGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverStaggeredGrid], which can use this delegate to control the layout of
///    its tiles.
abstract class SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts
  ///
  /// All of the arguments must not be null. The [mainAxisSpacing] and
  /// [crossAxisSpacing] arguments must not be negative.
  const SliverStaggeredGridDelegate({
    @required this.staggeredTileBuilder,
    this.mainAxisSpacing: 0.0,
    this.crossAxisSpacing: 0.0,
    this.staggeredTileCount,
  })  : assert(staggeredTileBuilder != null),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// Called to get the tile at the specified index for the
  /// [RenderSliverStaggeredGrid].
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  /// The total number of tiles this delegate can provide.
  ///
  /// If null, the number of tiles is determined by the least index for which
  /// [builder] returns null.
  final int staggeredTileCount;

  bool _debugAssertIsValid() {
    assert(staggeredTileBuilder != null);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  /// Returns information about the staggered grid configuration.
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints);

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(SliverStaggeredGridDelegate oldDelegate) {
    return oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.staggeredTileCount != staggeredTileCount ||
        oldDelegate.staggeredTileBuilder != staggeredTileBuilder;
  }
}

/// Creates staggered grid layouts with a fixed number of cells in the cross
/// axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [SliverStaggeredGridDelegate], which creates staggered grid layouts.
///  * [StaggeredGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverStaggeredGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverStaggeredGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverStaggeredGridDelegateWithFixedCrossAxisCount
    extends SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts with a fixed number
  /// of tiles in the cross axis.
  ///
  /// All of the arguments must not be null. The [mainAxisSpacing] and
  /// [crossAxisSpacing] arguments must not be negative. The [crossAxisCount]
  /// argument must be greater than zero.
  const SliverStaggeredGridDelegateWithFixedCrossAxisCount({
    @required this.crossAxisCount,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    int staggeredTileCount,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        super(
          staggeredTileBuilder: staggeredTileBuilder,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileCount: staggeredTileCount,
        );

  /// The number of children in the cross axis.
  final int crossAxisCount;

  @override
  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    return super._debugAssertIsValid();
  }

  @override
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return new StaggeredGridConfiguration(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      staggeredTileCount: staggeredTileCount,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      covariant SliverStaggeredGridDelegateWithFixedCrossAxisCount
          oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        super.shouldRelayout(oldDelegate);
  }
}

/// Creates staggered grid layouts with tiles that each have a maximum
/// cross-axis extent.
///
/// This delegate will select a cross-axis extent for the tiles that is as
/// large as possible subject to the following conditions:
///
///  - The extent evenly divides the cross-axis extent of the grid.
///  - The extent is at most [maxCrossAxisExtent].
///
/// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
/// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
/// columns that are 125.0 pixels wide.
///
/// This delegate creates grids with variable sized but equally spaced tiles.
///
/// See also:
///
///  * [SliverStaggeredGridDelegate], which creates staggered grid layouts.
///  * [StaggeredGridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverStaggeredGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverStaggeredGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverStaggeredGridDelegateWithMaxCrossAxisExtent
    extends SliverStaggeredGridDelegate {
  /// Creates a delegate that makes staggered grid layouts with tiles that
  /// have a maximum cross-axis extent.
  ///
  /// All of the arguments must not be null. The [maxCrossAxisExtent],
  /// [mainAxisSpacing] and [crossAxisSpacing] arguments must not be negative.
  const SliverStaggeredGridDelegateWithMaxCrossAxisExtent({
    @required this.maxCrossAxisExtent,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    int staggeredTileCount,
  })  : assert(maxCrossAxisExtent != null && maxCrossAxisExtent > 0),
        super(
          staggeredTileBuilder: staggeredTileBuilder,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileCount: staggeredTileCount,
        );

  /// The maximum extent of tiles in the cross axis.
  ///
  /// This delegate will select a cross-axis extent for the tiles that is as
  /// large as possible subject to the following conditions:
  ///
  ///  - The extent evenly divides the cross-axis extent of the grid.
  ///  - The extent is at most [maxCrossAxisExtent].
  ///
  /// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
  /// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
  /// columns that are 125.0 pixels wide.
  final double maxCrossAxisExtent;

  @override
  bool _debugAssertIsValid() {
    assert(maxCrossAxisExtent >= 0);
    return super._debugAssertIsValid();
  }

  @override
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final int crossAxisCount =
        ((constraints.crossAxisExtent + crossAxisSpacing) /
                (maxCrossAxisExtent + crossAxisSpacing))
            .ceil();

    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);

    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return new StaggeredGridConfiguration(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      staggeredTileCount: staggeredTileCount,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      covariant SliverStaggeredGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        super.shouldRelayout(oldDelegate);
  }
}
