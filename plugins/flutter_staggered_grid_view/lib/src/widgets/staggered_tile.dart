/// Holds the dimensions of a [StaggeredGridView]'s tile.
///
/// A [StaggeredTile] always overlaps an exact number of cells in the cross
/// axis of a [StaggeredGridView].
/// The main axis extent can either be a number of pixels or a number of
/// cells to overlap.
class StaggeredTile {
  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisCellCount].
  ///
  /// The main axis extent of this tile will be the length of
  /// [mainAxisCellCount] cells (inner spacings included).
  const StaggeredTile.count(this.crossAxisCellCount, this.mainAxisCellCount)
      : assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        assert(mainAxisCellCount != null && mainAxisCellCount >= 0),
        mainAxisExtent = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisExtent].
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.extent(this.crossAxisCellCount, this.mainAxisExtent)
      : assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        assert(mainAxisExtent != null && mainAxisExtent >= 0),
        mainAxisCellCount = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] that
  /// fit its main axis extent to its content.
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.fit(this.crossAxisCellCount)
      : assert(crossAxisCellCount != null && crossAxisCellCount >= 0),
        mainAxisExtent = null,
        mainAxisCellCount = null;

  /// The number of cells occupied in the cross axis.
  final int crossAxisCellCount;

  /// The number of cells occupied in the main axis.
  final num mainAxisCellCount;

  /// The number of pixels occupied in the main axis.
  final double mainAxisExtent;

  bool get fitContent => mainAxisCellCount == null && mainAxisExtent == null;
}
