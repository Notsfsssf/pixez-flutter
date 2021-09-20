import 'package:flutter/material.dart';

class AnimExpand extends StatefulWidget {
  final bool expand;
  final Widget child;

  const AnimExpand({Key? key, required this.expand, required this.child})
      : super(key: key);

  @override
  _AnimExpandState createState() => _AnimExpandState();
}

class _AnimExpandState extends State<AnimExpand> {
  bool _expand = false;

  @override
  void initState() {
    _expand = widget.expand;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimExpand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expand != widget.expand)
      setState(() {
        _expand = widget.expand;
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      firstChild: Container(
        height: 100,
        child: widget.child,
      ),
      secondChild: Container(
        child: widget.child,
      ),
      crossFadeState:
          _expand ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    );
  }
}
