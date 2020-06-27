import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/src/rendering/tile_container_render_object_mixin.dart';

/// A delegate used by [RenderSliverVariableSizeBoxAdaptor] to manage its children.
///
/// [RenderSliverVariableSizeBoxAdaptor] objects reify their children lazily to avoid
/// spending resources on children that are not visible in the viewport. This
/// delegate lets these objects create and remove children as well as estimate
/// the total scroll offset extent occupied by the full child list.
abstract class RenderSliverVariableSizeBoxChildManager {
  /// Called during layout when a new child is needed. The child should be
  /// inserted into the child list in the appropriate position. Its index and
  /// scroll offsets will automatically be set appropriately.
  ///
  /// The `index` argument gives the index of the child to show. It is possible
  /// for negative indices to be requested. For example: if the user scrolls
  /// from child 0 to child 10, and then those children get much smaller, and
  /// then the user scrolls back up again, this method will eventually be asked
  /// to produce a child for index -1.
  ///
  /// If no child corresponds to `index`, then do nothing.
  ///
  /// Which child is indicated by index zero depends on the [GrowthDirection]
  /// specified in the [RenderSliverVariableSizeBoxAdaptor.constraints]. For example
  /// if the children are the alphabet, then if
  /// [SliverConstraints.growthDirection] is [GrowthDirection.forward] then
  /// index zero is A, and index 25 is Z. On the other hand if
  /// [SliverConstraints.growthDirection] is [GrowthDirection.reverse]
  /// then index zero is Z, and index 25 is A.
  ///
  /// During a call to [createChild] it is valid to remove other children from
  /// the [RenderSliverVariableSizeBoxAdaptor] object if they were not created during
  /// this frame and have not yet been updated during this frame. It is not
  /// valid to add any other children to this render object.
  ///
  /// If this method does not create a child for a given `index` greater than or
  /// equal to zero, then [computeMaxScrollOffset] must be able to return a
  /// precise value.
  void createChild(int index);

  /// Remove the given child from the child list.
  ///
  /// Called by [RenderSliverVariableSizeBoxAdaptor.collectGarbage], which itself is
  /// called from [RenderSliverVariableSizeBoxAdaptor.performLayout].
  ///
  /// The index of the given child can be obtained using the
  /// [RenderSliverVariableSizeBoxAdaptor.indexOf] method, which reads it from the
  /// [SliverVariableSizeBoxAdaptorParentData.index] field of the child's
  /// [RenderObject.parentData].
  void removeChild(RenderBox child);

  /// Called to estimate the total scrollable extents of this object.
  ///
  /// Must return the total distance from the start of the child with the
  /// earliest possible index to the end of the child with the last possible
  /// index.
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  });

  /// Called to obtain a precise measure of the total number of children.
  ///
  /// Must return the number that is one greater than the greatest `index` for
  /// which `createChild` will actually create a child.
  ///
  /// This is used when [createChild] cannot add a child for a positive `index`,
  /// to determine the precise dimensions of the sliver. It must return an
  /// accurate and precise non-null value. It will not be called if
  /// [createChild] is always able to create a child (e.g. for an infinite
  /// list).
  int get childCount;

  /// Called during [RenderSliverVariableSizeBoxAdaptor.adoptChild].
  ///
  /// Subclasses must ensure that the [SliverVariableSizeBoxAdaptorParentData.index]
  /// field of the child's [RenderObject.parentData] accurately reflects the
  /// child's index in the child list after this function returns.
  void didAdoptChild(RenderBox child);

  /// Called during layout to indicate whether this object provided insufficient
  /// children for the [RenderSliverVariableSizeBoxAdaptor] to fill the
  /// [SliverConstraints.remainingPaintExtent].
  ///
  /// Typically called unconditionally at the start of layout with false and
  /// then later called with true when the [RenderSliverVariableSizeBoxAdaptor]
  /// fails to create a child required to fill the
  /// [SliverConstraints.remainingPaintExtent].
  ///
  /// Useful for subclasses to determine whether newly added children could
  /// affect the visible contents of the [RenderSliverVariableSizeBoxAdaptor].
  void setDidUnderflow(bool value);

  /// Called at the beginning of layout to indicate that layout is about to
  /// occur.
  void didStartLayout() {}

  /// Called at the end of layout to indicate that layout is now complete.
  void didFinishLayout() {}

  /// In debug mode, asserts that this manager is not expecting any
  /// modifications to the [RenderSliverVariableSizeBoxAdaptor]'s child list.
  ///
  /// This function always returns true.
  ///
  /// The manager is not required to track whether it is expecting modifications
  /// to the [RenderSliverVariableSizeBoxAdaptor]'s child list and can simply return
  /// true without making any assertions.
  bool debugAssertChildListLocked() => true;
}

/// Parent data structure used by [RenderSliverVariableSizeBoxAdaptor].
class SliverVariableSizeBoxAdaptorParentData
    extends SliverMultiBoxAdaptorParentData {
  /// The offset of the child in the non-scrolling axis.
  ///
  /// If the scroll axis is vertical, this offset is from the left-most edge of
  /// the parent to the left-most edge of the child. If the scroll axis is
  /// horizontal, this offset is from the top-most edge of the parent to the
  /// top-most edge of the child.
  double crossAxisOffset;

  /// Whether the widget is currently in the
  /// [RenderSliverVariableSizeBoxAdaptor._keepAliveBucket].
  bool _keptAlive = false;

  @override
  String toString() => 'crossAxisOffset=$crossAxisOffset; ${super.toString()}';
}

/// A sliver with multiple variable size box children.
///
/// [RenderSliverVariableSizeBoxAdaptor] is a base class for slivers that have multiple
/// variable size box children. The children are managed by a [RenderSliverBoxChildManager],
/// which lets subclasses create children lazily during layout. Typically
/// subclasses will create only those children that are actually needed to fill
/// the [SliverConstraints.remainingPaintExtent].
///
/// The contract for adding and removing children from this render object is
/// more strict than for normal render objects:
///
/// * Children can be removed except during a layout pass if they have already
///   been laid out during that layout pass.
/// * Children cannot be added except during a call to [childManager], and
///   then only if there is no child corresponding to that index (or the child
///   child corresponding to that index was first removed).
///
/// See also:
///
///  * [RenderSliverToBoxAdapter], which has a single box child.
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [RenderSliverGrid], which places its children in arbitrary positions.
abstract class RenderSliverVariableSizeBoxAdaptor extends RenderSliver
    with
        TileContainerRenderObjectMixin<RenderBox,
            SliverVariableSizeBoxAdaptorParentData>,
        RenderSliverWithKeepAliveMixin,
        RenderSliverHelpers {
  /// Creates a sliver with multiple box children.
  ///
  /// The [childManager] argument must not be null.
  RenderSliverVariableSizeBoxAdaptor(
      {@required RenderSliverVariableSizeBoxChildManager childManager})
      : assert(childManager != null),
        _childManager = childManager;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverVariableSizeBoxAdaptorParentData) {
      child.parentData = new SliverVariableSizeBoxAdaptorParentData();
    }
  }

  /// The delegate that manages the children of this object.
  ///
  /// Rather than having a concrete list of children, a
  /// [RenderSliverVariableSizeBoxAdaptor] uses a [RenderSliverVariableSizeBoxChildManager] to
  /// create children during layout in order to fill the
  /// [SliverConstraints.remainingPaintExtent].
  @protected
  RenderSliverVariableSizeBoxChildManager get childManager => _childManager;
  final RenderSliverVariableSizeBoxChildManager _childManager;

  /// The nodes being kept alive despite not being visible.
  final Map<int, RenderBox> _keepAliveBucket = <int, RenderBox>{};

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    if (!childParentData._keptAlive) childManager.didAdoptChild(child);
  }

  bool _debugAssertChildListLocked() =>
      childManager.debugAssertChildListLocked();

  @override
  void remove(int index) {
    final RenderBox child = this[index];

    // if child is null, it means this element was cached - drop the cached element
    if (child == null) {
      RenderBox cachedChild = _keepAliveBucket[index];
      if (cachedChild != null) {
        dropChild(cachedChild);
        _keepAliveBucket.remove(index);
      }
      return;
    }

    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    if (!childParentData._keptAlive) {
      super.remove(index);
      return;
    }
    assert(_keepAliveBucket[childParentData.index] == child);
    _keepAliveBucket.remove(childParentData.index);
    dropChild(child);
  }

  @override
  void removeAll() {
    super.removeAll();
    _keepAliveBucket.values.forEach(dropChild);
    _keepAliveBucket.clear();
  }

  void _createOrObtainChild(int index) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      if (_keepAliveBucket.containsKey(index)) {
        final RenderBox child = _keepAliveBucket.remove(index);
        final SliverVariableSizeBoxAdaptorParentData childParentData =
            child.parentData;
        assert(childParentData._keptAlive);
        dropChild(child);
        child.parentData = childParentData;
        this[index] = child;
        childParentData._keptAlive = false;
      } else {
        _childManager.createChild(index);
      }
    });
  }

  void _destroyOrCacheChild(int index) {
    final RenderBox child = this[index];
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    if (childParentData.keepAlive) {
      assert(!childParentData._keptAlive);
      remove(index);
      _keepAliveBucket[childParentData.index] = child;
      child.parentData = childParentData;
      super.adoptChild(child);
      childParentData._keptAlive = true;
    } else {
      assert(child.parent == this);
      _childManager.removeChild(child);
      assert(child.parent == null);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _keepAliveBucket.values.forEach((child) => child.attach(owner));
  }

  @override
  void detach() {
    super.detach();
    _keepAliveBucket.values.forEach((child) => child.detach());
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    _keepAliveBucket.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    _keepAliveBucket.values.forEach(visitor);
  }

  bool addChild(int index) {
    assert(_debugAssertChildListLocked());
    _createOrObtainChild(index);
    RenderBox child = this[index];
    if (child != null) {
      assert(indexOf(child) == index);
      return true;
    }
    childManager.setDidUnderflow(true);
    return false;
  }

  RenderBox addAndLayoutChild(
    int index,
    BoxConstraints childConstraints, {
    bool parentUsesSize: false,
  }) {
    assert(_debugAssertChildListLocked());
    _createOrObtainChild(index);
    RenderBox child = this[index];
    if (child != null) {
      assert(indexOf(child) == index);
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      return child;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// Called after layout with the number of children that can be garbage
  /// collected at the head and tail of the child list.
  ///
  /// Children whose [SliverVariableSizeBoxAdaptorParentData.keepAlive] property is
  /// set to true will be removed to a cache instead of being dropped.
  ///
  /// This method also collects any children that were previously kept alive but
  /// are now no longer necessary. As such, it should be called every time
  /// [performLayout] is run, even if the arguments are both zero.
  @protected
  void collectGarbage(Set<int> visibleIndices) {
    assert(_debugAssertChildListLocked());
    assert(childCount >= visibleIndices.length);
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      // We destroy only those which are not visible.
      indices.toSet().difference(visibleIndices).forEach(_destroyOrCacheChild);

      // Ask the child manager to remove the children that are no longer being
      // kept alive. (This should cause _keepAliveBucket to change, so we have
      // to prepare our list ahead of time.)
      _keepAliveBucket.values
          .where((RenderBox child) {
            final SliverVariableSizeBoxAdaptorParentData childParentData =
                child.parentData;
            return !childParentData.keepAlive;
          })
          .toList()
          .forEach(_childManager.removeChild);
      assert(_keepAliveBucket.values.where((RenderBox child) {
        final SliverVariableSizeBoxAdaptorParentData childParentData =
            child.parentData;
        return !childParentData.keepAlive;
      }).isEmpty);
    });
  }

  /// Returns the index of the given child, as given by the
  /// [SliverVariableSizeBoxAdaptorParentData.index] field of the child's [parentData].
  int indexOf(RenderBox child) {
    assert(child != null);
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    assert(childParentData.index != null);
    return childParentData.index;
  }

  /// Returns the dimension of the given child in the main axis, as given by the
  /// child's [RenderBox.size] property. This is only valid after layout.
  @protected
  double paintExtentOf(RenderBox child) {
    assert(child != null);
    assert(child.hasSize);
    switch (constraints.axis) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
    return null;
  }

  @override
  bool hitTestChildren(HitTestResult result,
      {@required double mainAxisPosition, @required double crossAxisPosition}) {
    for (var child in children) {
      if (hitTestBoxChild(BoxHitTestResult.wrap(result), child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition)) return true;
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return childScrollOffset(child) - constraints.scrollOffset;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    return childParentData.crossAxisOffset;
  }

  @override
  double childScrollOffset(RenderObject child) {
    assert(child != null);
    assert(child.parent == this);
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    assert(childParentData.layoutOffset != null);
    return childParentData.layoutOffset;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child, transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount == 0) return;
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    Offset mainAxisUnit, crossAxisUnit, originOffset;
    bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + new Offset(0.0, geometry.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + new Offset(geometry.paintExtent, 0.0);
        addExtent = true;
        break;
    }
    assert(mainAxisUnit != null);
    assert(addExtent != null);

    for (var child in children) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = new Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) childOffset += mainAxisUnit * paintExtentOf(child);
      context.paintChild(child, childOffset);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new DiagnosticsNode.message(childCount > 0
        ? 'currently live children: ${indices.join(',')}'
        : 'no children current live'));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> childList = <DiagnosticsNode>[];
    if (childCount > 0) {
      for (RenderBox child in children) {
        final SliverVariableSizeBoxAdaptorParentData childParentData =
            child.parentData;
        childList.add(child.toDiagnosticsNode(
            name: 'child with index ${childParentData.index}'));
      }
    }
    if (_keepAliveBucket.isNotEmpty) {
      final List<int> indices = _keepAliveBucket.keys.toList()..sort();
      for (int index in indices) {
        childList.add(_keepAliveBucket[index].toDiagnosticsNode(
          name: 'child with index $index (kept alive offstage)',
          style: DiagnosticsTreeStyle.offstage,
        ));
      }
    }
    return childList;
  }
}
