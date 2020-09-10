import 'package:flutter/material.dart';

class SortGroup extends StatefulWidget {
  final List<String> children;
  final Function onChange;
  final int currentIndex;

  const SortGroup(
      {Key key,
      @required this.children,
      @required this.onChange,
      this.currentIndex})
      : super(key: key);

  @override
  _SortGroupState createState() => _SortGroupState();
}

class _SortGroupState extends State<SortGroup> {
  int index = 0;

  @override
  void initState() {
    this.index = widget.currentIndex??0;
    super.initState();
  }

  @override
  void didUpdateWidget(SortGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != index) {
      setState(() {
        this.index = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (var i in widget.children)
          ActionChip(
            elevation: 4.0,
            label: Text(
              i,
              style: TextStyle(
                  color: index == widget.children.indexOf(i)
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyText1.color),
            ),
            backgroundColor: index == widget.children.indexOf(i)
                ? Theme.of(context).accentColor
                : Colors.transparent,
            onPressed: () {
              int ii = widget.children.indexOf(i);
              widget.onChange(index);
              if (mounted)
                setState(() {
                  this.index = ii;
                });
            },
          )
      ],
    );
  }
}
