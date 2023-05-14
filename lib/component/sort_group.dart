import 'package:flutter/material.dart';

class SortGroup extends StatefulWidget {
  final List<String> children;
  final Function onChange;

  const SortGroup({Key? key, required this.children, required this.onChange})
      : super(key: key);

  @override
  _SortGroupState createState() => _SortGroupState();
}

class _SortGroupState extends State<SortGroup> {
  int _index = 0;
  List<String> _children = [];

  @override
  void initState() {
    _children = widget.children;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SortGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children != widget.children) {
      setState(() {
        _children = widget.children;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      selected: {_index},
      segments: [
        for (var i in _children)
          ButtonSegment(value: widget.children.indexOf(i), label: Text(i)),
      ],
      onSelectionChanged: (i) {
        widget.onChange(i.first);
        if (mounted) {
          setState(() {
            this._index = i.first;
          });
        }
      },
    );
  }
}
