import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// [showModalBottomSheet] on touch platforms; a centered dialog on macOS,
/// where a sheet rising from the bottom of a wide window reads as a mobile
/// pattern. The builder and its `Navigator.pop(result)` work unchanged.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool isScrollControlled = false,
  bool useSafeArea = false,
}) {
  if (!Platform.isMacOS) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
    );
  }
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      final screen = MediaQuery.sizeOf(dialogContext);
      final maxHeight = screen.height * 0.8;
      Widget child = builder(dialogContext);
      // Sheets that asked for a fixed height (e.g. the bookmark tag editor)
      // keep it, capped to the window.
      final fixedHeight = constraints?.minHeight;
      if (fixedHeight != null && fixedHeight > 0) {
        child = SizedBox(height: min(fixedHeight, maxHeight), child: child);
      }
      return Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
          child: child,
        ),
      );
    },
  );
}
