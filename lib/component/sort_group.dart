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
    return Wrap(
      spacing: 8,
      children: [for (var i in widget.children) _buildChip(i, context)],
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
