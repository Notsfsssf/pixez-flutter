import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_staggered_grid_view/src/rendering/sliver_staggered_grid.dart';
import 'package:flutter_staggered_grid_view/src/rendering/sliver_variable_size_box_adaptor.dart';
import 'package:flutter_staggered_grid_view/src/widgets/staggered_tile.dart';

/// A base class for sliver that have multiple variable size box children.
///
/// Helps subclasses build their children lazily using a [SliverVariableSizeChildDelegate].
abstract class SliverVariableSizeBoxAdaptorWidget
    extends SliverWithKeepAliveWidget {
  /// Initializes fields for subclasses.
  const SliverVariableSizeBoxAdaptorWidget({
    Key key,
    @required this.delegate,
  }) : super(key: key);

  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this widget to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [SliverChildBuilderDelegate] and [SliverChildListDelegate], which are
  ///    commonly used subclasses of [SliverChildDelegate] that use a builder
  ///    callback and an explicit child list, respectively.
  final SliverChildDelegate delegate;

  @override
  SliverVariableSizeBoxAdaptorElement createElement() =>
      new SliverVariableSizeBoxAdaptorElement(this);

  @override
  RenderSliverVariableSizeBoxAdaptor createRenderObject(BuildContext context);

  /// Returns an estimate of the max scroll extent for all the children.
  ///
  /// Subclasses should override this function if they have additional
  /// information about their max scroll extent.
  ///
  /// This is used by [SliverMultiBoxAdaptorElement] to implement part of the
  /// [RenderSliverBoxChildManager] API.
  ///
  /// The default implementation defers to [delegate] via its
  /// [SliverChildDelegate.estimateMaxScrollOffset] method.
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    assert(lastIndex >= firstIndex);
    return delegate.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        new DiagnosticsProperty<SliverChildDelegate>('delegate', delegate));
  }
}

/// An element that lazily builds children for a [SliverVariableSizeBoxAdaptorWidget].
///
/// Implements [RenderSliverVariableSizeBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverVariableSizeBoxAdaptor].
class SliverVariableSizeBoxAdaptorElement extends RenderObjectElement
    implements RenderSliverVariableSizeBoxChildManager {
  /// Creates an element that lazily builds children for the given widget.
  SliverVariableSizeBoxAdaptorElement(SliverVariableSizeBoxAdaptorWidget widget)
      : super(widget);

  @override
  SliverVariableSizeBoxAdaptorWidget get widget => super.widget;

  @override
  RenderSliverVariableSizeBoxAdaptor get renderObject => super.renderObject;

  @override
  void update(covariant SliverVariableSizeBoxAdaptorWidget newWidget) {
    final SliverVariableSizeBoxAdaptorWidget oldWidget = widget;
    super.update(newWidget);
    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) performRebuild();
  }

  // We inflate widgets at two different times:
  //  1. When we ourselves are told to rebuild (see performRebuild).
  //  2. When our render object needs a new child (see createChild).
  // In both cases, we cache the results of calling into our delegate to get the widget,
  // so that if we do case 2 later, we don't call the builder again.
  // Any time we do case 1, though, we reset the cache.

  final Map<int, Widget> _childWidgets = new HashMap<int, Widget>();
  final SplayTreeMap<int, Element> _childElements =
      new SplayTreeMap<int, Element>();

  @override
  void performRebuild() {
    _childWidgets.clear(); // Reset the cache, as described above.
    super.performRebuild();
    assert(_currentlyUpdatingChildIndex == null);
    try {
      int firstIndex = _childElements.firstKey();
      int lastIndex = _childElements.lastKey();
      if (_childElements.isEmpty) {
        firstIndex = 0;
        lastIndex = 0;
      } else if (_didUnderflow) {
        lastIndex += 1;
      }
      for (int index = firstIndex; index <= lastIndex; ++index) {
        _currentlyUpdatingChildIndex = index;
        final Element newChild =
            updateChild(_childElements[index], _build(index), index);
        if (newChild != null) {
          _childElements[index] = newChild;
        } else {
          _childElements.remove(index);
        }
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
    }
  }

  Widget _build(int index) {
    return _childWidgets.putIfAbsent(
        index, () => widget.delegate.build(this, index));
  }

  @override
  void createChild(int index) {
    assert(_currentlyUpdatingChildIndex == null);
    owner.buildScope(this, () {
      Element newChild;
      try {
        _currentlyUpdatingChildIndex = index;
        newChild = updateChild(_childElements[index], _build(index), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
      }
    });
  }

  @override
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
    final SliverVariableSizeBoxAdaptorParentData oldParentData =
        child?.renderObject?.parentData;
    final Element newChild = super.updateChild(child, newWidget, newSlot);
    final SliverVariableSizeBoxAdaptorParentData newParentData =
        newChild?.renderObject?.parentData;

    // set keepAlive to true in order to populate the cache
    if (newParentData != null) {
      newParentData.keepAlive = true;
    }

    // Preserve the old layoutOffset if the renderObject was swapped out.
    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }

    return newChild;
  }

  @override
  void forgetChild(Element child) {
    assert(child != null);
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    final int childCount = this.childCount;
    if (childCount == null) return double.infinity;
    if (lastIndex == childCount - 1) return trailingScrollOffset;
    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent =
        (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  }) {
    return widget.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        );
  }

  @override
  int get childCount => widget.delegate.estimatedChildCount;

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    final int firstIndex = _childElements.firstKey() ?? 0;
    final int lastIndex = _childElements.lastKey() ?? 0;
    widget.delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final SliverVariableSizeBoxAdaptorParentData childParentData =
        child.parentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertChildRenderObject(covariant RenderObject child, int slot) {
    assert(slot != null);
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject[_currentlyUpdatingChildIndex] = child;
    assert(() {
      final SliverVariableSizeBoxAdaptorParentData childParentData =
          child.parentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveChildRenderObject(covariant RenderObject child, int slot) {
    // TODO(ianh): At some point we should be better about noticing when a
    // particular LocalKey changes slot, and handle moving the nodes around.
    assert(false);
  }

  @override
  void removeChildRenderObject(covariant RenderObject child) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(_currentlyUpdatingChildIndex);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    assert(!_childElements.values.any((Element child) => child == null));
    _childElements.values.toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.where((Element child) {
      final SliverMultiBoxAdaptorParentData parentData =
          child.renderObject.parentData;
      double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject.paintBounds.height;
          break;
      }

      return parentData.layoutOffset <
              renderObject.constraints.scrollOffset +
                  renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset + itemExtent >
              renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [SliverStaggeredGrid] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// The main axis direction of a grid is the direction in which it scrolls; the
/// cross axis direction is the orthogonal direction.
///
/// ## Sample code
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows 8 boxes:
///
/// ```dart
///new SliverStaggeredGrid.count(
///  crossAxisCount: 4,
///  mainAxisSpacing: 4.0,
///  crossAxisSpacing: 4.0,
///  children: const <Widget>[
///    const Text('1'),
///    const Text('2'),
///    const Text('3'),
///    const Text('4'),
///    const Text('5'),
///    const Text('6'),
///    const Text('7'),
///    const Text('8'),
///  ],
///  staggeredTiles: const <StaggeredTile>[
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///    const StaggeredTile.count(2, 2),
///    const StaggeredTile.count(2, 1),
///  ],
///)
/// ```
///
/// See also:
///
///  * [SliverList], which places its children in a linear array.
///  * [SliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
class SliverStaggeredGrid extends SliverVariableSizeBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const SliverStaggeredGrid({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.gridDelegate,
  }) : super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.count], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.count({
    Key key,
    @required int crossAxisCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    List<Widget> children: const <Widget>[],
    List<StaggeredTile> staggeredTiles: const <StaggeredTile>[],
  })  : gridDelegate = new SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles?.length,
        ),
        super(
            key: key,
            delegate: new SliverChildListDelegate(children,
                addAutomaticKeepAlives: true));

  /// Creates a sliver that builds multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate], and a [SliverVariableSizeChildBuilderDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.countBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.countBuilder({
    Key key,
    @required int crossAxisCount,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    @required IndexedWidgetBuilder itemBuilder,
    @required int itemCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
  })  : gridDelegate = new SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        );

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverVariableSizeChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.extent], the equivalent constructor for [StaggeredGridView] widgets.
  SliverStaggeredGrid.extent({
    Key key,
    @required double maxCrossAxisExtent,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
    List<Widget> children: const <Widget>[],
    List<StaggeredTile> staggeredTiles: const <StaggeredTile>[],
  })  : gridDelegate = new SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles?.length,
        ),
        super(
            key: key,
            delegate: new SliverChildListDelegate(children,
                addAutomaticKeepAlives: true));

  /// Creates a sliver that builds multiple box children in a two dimensional
  /// arrangement with tiles that each have a maximum cross-axis extent.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithMaxCrossAxisExtent] as the
  /// [gridDelegate], and a [SliverVariableSizeChildBuilderDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new StaggeredGridView.extentBuilder], the equivalent constructor for
  ///  [StaggeredGridView] widgets.
  SliverStaggeredGrid.extentBuilder({
    Key key,
    @required double maxCrossAxisExtent,
    @required IndexedStaggeredTileBuilder staggeredTileBuilder,
    @required IndexedWidgetBuilder itemBuilder,
    @required int itemCount,
    double mainAxisSpacing: 0.0,
    double crossAxisSpacing: 0.0,
  })  : gridDelegate = new SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          key: key,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        );

  /// The delegate that controls the size and position of the children.
  final SliverStaggeredGridDelegate gridDelegate;

  @override
  RenderSliverStaggeredGrid createRenderObject(BuildContext context) {
    final SliverVariableSizeBoxAdaptorElement element = context;
    return new RenderSliverStaggeredGrid(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverStaggeredGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return super.estimateMaxScrollOffset(
      constraints,
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }
}
