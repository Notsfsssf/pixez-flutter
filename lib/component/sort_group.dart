import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
          WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return Theme.of(context).colorScheme.secondaryContainer;
        }
        return Theme.of(context).colorScheme.surface;
      })),
      segments: [
        for (var (index, i) in widget.children.indexed)
          ButtonSegment(value: index, label: Text(i)),
      ],
      selected: {index},
      onSelectionChanged: (p0) {
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
          backgroundColor: WidgetStateProperty.all<Color>(
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
