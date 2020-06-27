import 'dart:collection';

import 'package:flutter/rendering.dart';

/// Generic mixin for render objects with a list of children.
///
/// Provides a child model for a render object subclass that stores children
/// in a HashMap.
mixin TileContainerRenderObjectMixin<ChildType extends RenderObject,
    ParentDataType extends ParentData> on RenderObject {
  final SplayTreeMap<int, ChildType> _childRenderObjects =
      new SplayTreeMap<int, ChildType>();

  /// The number of children.
  int get childCount => _childRenderObjects.length;

  Iterable<ChildType> get children => _childRenderObjects.values;

  Iterable<int> get indices => _childRenderObjects.keys;

  /// Checks whether the given render object has the correct [runtimeType] to be
  /// a child of this render object.
  ///
  /// Does nothing if assertions are disabled.
  ///
  /// Always returns true.
  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw new FlutterError(
            'A $runtimeType expected a child of type $ChildType but received a '
            'child of type ${child.runtimeType}.\n'
            'RenderObjects expect specific types of children because they '
            'coordinate with their children during layout and paint. For '
            'example, a RenderSliver cannot be the child of a RenderBox because '
            'a RenderSliver does not understand the RenderBox layout protocol.\n'
            '\n'
            'The $runtimeType that expected a $ChildType child was created by:\n'
            '  $debugCreator\n'
            '\n'
            'The ${child.runtimeType} that did not match the expected child type '
            'was created by:\n'
            '  ${child.debugCreator}\n');
      }
      return true;
    }());
    return true;
  }

  ChildType operator [](int index) => _childRenderObjects[index];

  void operator []=(int index, ChildType child) {
    assert(child != null);
    if (index == null || index < 0) throw new ArgumentError(index);
    _removeChild(_childRenderObjects[index]);
    adoptChild(child);
    _childRenderObjects[index] = child;
  }

  void forEachChild(void f(ChildType child)) {
    _childRenderObjects.values.forEach(f);
  }

  /// Remove the child at the specified index from the child list.
  void remove(int index) {
    ChildType child = _childRenderObjects.remove(index);
    _removeChild(child);
  }

  void _removeChild(ChildType child) {
    if (child != null) {
      // Remove the old child.
      dropChild(child);
    }
  }

  /// Remove all their children from this render object's child list.
  ///
  /// More efficient than removing them individually.
  void removeAll() {
    _childRenderObjects.values.forEach(dropChild);
    _childRenderObjects.clear();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _childRenderObjects.values.forEach((child) => child.attach(owner));
  }

  @override
  void detach() {
    super.detach();
    _childRenderObjects.values.forEach((child) => child.detach());
  }

  @override
  void redepthChildren() {
    _childRenderObjects.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _childRenderObjects.values.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    _childRenderObjects.forEach((index, child) =>
        children.add(child.toDiagnosticsNode(name: 'child $index')));
    return children;
  }
}
