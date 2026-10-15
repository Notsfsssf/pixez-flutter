import 'package:flutter/material.dart';
import 'package:pixez/utils/haptic_util.dart';

/// Top-bar button that jumps to the detail (author info) anchor of the
/// illust detail page. Tracks whether the anchor sits below or above the
/// current viewport and flips its chevron accordingly.
class DetailJumpButton extends StatefulWidget {
  final GlobalKey anchorKey;
  final ScrollController scrollController;

  const DetailJumpButton({
    super.key,
    required this.anchorKey,
    required this.scrollController,
  });

  @override
  State<DetailJumpButton> createState() => _DetailJumpButtonState();
}

class _DetailJumpButtonState extends State<DetailJumpButton> {
  bool _anchorBelow = true;
  double? _screenH;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenH = MediaQuery.of(context).size.height;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Notification callbacks run before the frame re-layouts, so geometry
    // read here is stale. Defer the computation to after the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshAnchorState();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Recompute the anchor direction from fresh layout; rebuild on change.
  /// Safe to call from async completions and post-frame callbacks.
  void _refreshAnchorState() {
    final ro = widget.anchorKey.currentContext?.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return;
    final below = ro.localToGlobal(Offset.zero).dy > (_screenH ?? 800);
    if (below != _anchorBelow) {
      _anchorBelow = below;
      if (mounted) setState(() {});
    }
  }

  Future<void> _reveal() async {
    final anchorContext = widget.anchorKey.currentContext;
    final ro = anchorContext?.findRenderObject();
    if (anchorContext == null || ro is! RenderBox || !ro.attached) return;
    await Scrollable.ensureVisible(
      anchorContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
    // clamped = anchor still below the viewport (related-works grid still
    // loading -> max extent too small). wait once and correct, else stay.
    // note: a successful landing puts the anchor top at ~screenH/2 - h/2.
    if (ro.localToGlobal(Offset.zero).dy > (_screenH ?? 800) - 24) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || !ro.attached) return;
      await Scrollable.ensureVisible(
        anchorContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  Future<void> _jump() async {
    HapticUtil.selectionClick();
    final anchorContext = widget.anchorKey.currentContext;
    final ro = anchorContext?.findRenderObject();
    if (anchorContext != null && ro != null && ro.attached) {
      await _reveal();
      _refreshAnchorState();
      return;
    }
    // anchor not laid out yet (below many pages in expanded view):
    // jump to the bottom to force layout of the tail, then fine-position
    final pos = widget.scrollController.position;
    await widget.scrollController.animateTo(
      pos.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    await _reveal();
    _refreshAnchorState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_anchorBelow ? Icons.expand_more : Icons.expand_less),
      onPressed: _jump,
    );
  }
}
