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
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      style: ButtonStyle(backgroundColor:
          MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Theme.of(context).colorScheme.secondaryContainer;
        }
        return Theme.of(context).colorScheme.surface;
      })),
      segments: [
        for (int index = 0; index < widget.children.length; index++)
          ButtonSegment(value: index, label: Text(widget.children[index])),
      ],
      selected: {index},
      onSelectionChanged: (Set<int> p0) {
        widget.onChange(p0.first);
        if (mounted)
          setState(() {
            this.index = p0.first;
          });
      },
    );
  }

  Widget _buildChip(String i, BuildContext context) {
    final bgColor = index == widget.children.indexOf(i)
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge!.color;
    return ElevatedButton(
      child: Text(
        i,
        style: TextStyle(color: bgColor),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              index == widget.children.indexOf(i)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor)),
      onPressed: () {
        int ii = widget.children.indexOf(i);
        widget.onChange(ii);
        if (mounted)
          setState(() {
            this.index = ii;
          });
      },
    );
  }
}
