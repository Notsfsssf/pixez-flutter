import 'package:fluent_ui/fluent_ui.dart';

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
      children: [for (var i in widget.children) _buildChild(i)],
    );
  }

  Widget _buildChild(String i) {
    final text = Text(
      i,
      style: TextStyle(
          color: index == widget.children.indexOf(i)
              ? Colors.white
              : FluentTheme.of(context).typography.body!.color),
    );
    final onPressed = () {
      int ii = widget.children.indexOf(i);
      widget.onChange(ii);
      if (mounted)
        setState(() {
          this.index = ii;
        });
    };
    if (index == widget.children.indexOf(i))
      return ToggleButton(
        checked: true,
        child: text,
        onChanged: (v) => onPressed(),
      );
    else
      return ToggleButton(
        checked: false,
        child: text,
        onChanged: (v) => onPressed(),
      );
  }
}
