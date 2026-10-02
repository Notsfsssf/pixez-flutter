import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class BoundsReportingWidget extends SingleChildRenderObjectWidget {
  final ValueChanged<Rect> onBoundsChanged;

  const BoundsReportingWidget({
    required this.onBoundsChanged,
    super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBoundsReporter(onBoundsChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBoundsReporter renderObject,
  ) {
    renderObject.onBoundsChanged = onBoundsChanged;
  }
}

class RenderBoundsReporter extends RenderProxyBox {
  ValueChanged<Rect> onBoundsChanged;
  Rect? _lastRect;

  RenderBoundsReporter(this.onBoundsChanged);

  @override
  void performLayout() {
    super.performLayout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!attached) return;
      final offset = localToGlobal(Offset.zero);
      final rect = offset & size;
      if (_lastRect != rect) {
        _lastRect = rect;
        onBoundsChanged(rect);
      }
    });
  }
}
