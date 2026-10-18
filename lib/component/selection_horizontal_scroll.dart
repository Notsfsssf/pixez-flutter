import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Place inside a SelectionArea to let touch drags scroll its horizontal parent.
/// Long presses and mouse drags remain available for text selection.
class SelectionHorizontalScroll extends StatefulWidget {
  const SelectionHorizontalScroll({super.key, required this.child});

  final Widget child;

  @override
  State<SelectionHorizontalScroll> createState() =>
      _SelectionHorizontalScrollState();
}

class _SelectionHorizontalScrollState extends State<SelectionHorizontalScroll> {
  Drag? _drag;

  @override
  void dispose() {
    _drag?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context, axis: Axis.horizontal);
    if (scrollable == null || !scrollable.position.physics.allowUserScrolling) {
      return widget.child;
    }

    // This recognizer is below SelectionArea's horizontal selection recognizer
    // in the hit test path, so it can win the drag and drive the actual PageView.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      supportedDevices: const {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
      },
      onHorizontalDragStart: (details) {
        _drag?.cancel();
        if (!scrollable.position.physics.shouldAcceptUserOffset(
          scrollable.position,
        )) {
          return;
        }
        _drag = scrollable.position.drag(details, () => _drag = null);
      },
      onHorizontalDragUpdate: (details) => _drag?.update(details),
      onHorizontalDragEnd: (details) {
        _drag?.end(details);
        _drag = null;
      },
      onHorizontalDragCancel: () {
        _drag?.cancel();
        _drag = null;
      },
      child: widget.child,
    );
  }
}
