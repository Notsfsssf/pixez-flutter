import 'dart:io';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Keyboard actions the desktop shell sends to the list on screen.
///
/// Flutter's desktop default maps the arrow keys to focus traversal, which
/// jumps between buttons and scrolls whatever gets focus into view. The shell
/// handles the keys itself and scrolls the visible list instead. Cmd+R
/// refreshes it, since pull-to-refresh needs a trackpad on macOS.
class DesktopList {
  static final _targets = <_DesktopListTargetState>[];

  static _DesktopListTargetState? _visible({bool needsScroll = false}) {
    _DesktopListTargetState? best;
    var bestArea = 0.0;
    for (final target in _targets) {
      if (needsScroll && target.widget.scrollController?.hasClients != true) {
        continue;
      }
      final area = target._visibleArea();
      // The largest visible list is the main content, not a nested strip.
      if (area > bestArea) {
        best = target;
        bestArea = area;
      }
    }
    return best;
  }

  static void refresh() => _visible()?.widget.refreshController?.callRefresh();

  /// Returns true when a visible list scrolled.
  static bool scroll(LogicalKeyboardKey key) {
    final controller = _visible(needsScroll: true)?.widget.scrollController;
    if (controller == null) return false;
    final position = controller.positions.last;
    final page = position.viewportDimension * 0.85;
    final target = switch (key) {
      LogicalKeyboardKey.arrowUp => position.pixels - 80,
      LogicalKeyboardKey.arrowDown => position.pixels + 80,
      LogicalKeyboardKey.pageUp => position.pixels - page,
      LogicalKeyboardKey.pageDown ||
      LogicalKeyboardKey.space => position.pixels + page,
      LogicalKeyboardKey.home => position.minScrollExtent,
      LogicalKeyboardKey.end => position.maxScrollExtent,
      _ => null,
    };
    if (target == null) return false;
    position.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
    return true;
  }
}

/// Registers a list for [DesktopList] keyboard scrolling and Cmd+R refresh.
/// Lists kept alive in a PageView or TabBarView are laid out off screen, and
/// lists on a covered route are skipped, so only the one in view responds.
class DesktopListTarget extends StatefulWidget {
  const DesktopListTarget({
    super.key,
    this.refreshController,
    this.scrollController,
    required this.child,
  });

  final EasyRefreshController? refreshController;
  final ScrollController? scrollController;
  final Widget child;

  @override
  State<DesktopListTarget> createState() => _DesktopListTargetState();
}

class _DesktopListTargetState extends State<DesktopListTarget> {
  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS) DesktopList._targets.add(this);
  }

  double _visibleArea() {
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return 0;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return 0;
    final view = View.of(context);
    final screen = Offset.zero & (view.physicalSize / view.devicePixelRatio);
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (!screen.contains(rect.center)) return 0;
    final visible = rect.intersect(screen);
    return max(0, visible.width) * max(0, visible.height);
  }

  @override
  void dispose() {
    DesktopList._targets.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
