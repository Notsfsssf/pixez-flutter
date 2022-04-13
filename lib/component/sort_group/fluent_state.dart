import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/component/sort_group.dart';

class FluentSortGroupState extends SortGroupStateBase {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (var i in widget.children)
          Chip(
            // elevation: 4.0,
            text: Text(
              i,
              style: TextStyle(
                  color: index == widget.children.indexOf(i)
                      ? Colors.white
                      : FluentTheme.of(context).typography.body?.color),
            ),
            // backgroundColor: index == widget.children.indexOf(i)
            //     ? Theme.of(context).colorScheme.primary
            //     : Colors.transparent,
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
