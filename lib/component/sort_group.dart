import 'package:flutter/material.dart';

class SortGroup extends StatefulWidget {
  final List<String> children;
  final Function onChange;

  const SortGroup(
      {Key? key,
      required this.children,
      required this.onChange})
      : super(key: key);

  @override
  _SortGroupState createState() => _SortGroupState();
}

class _SortGroupState extends State<SortGroup> {
  int index = 0;

  @override
  void initState() {
    super.initState();
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
                      : Theme.of(context).textTheme.bodyText1!.color),
            ),
            backgroundColor: index == widget.children.indexOf(i)
                ? Theme.of(context).accentColor
                : Colors.transparent,
            onPressed: () {
              int ii = widget.children.indexOf(i);
              widget.onChange(ii);
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
