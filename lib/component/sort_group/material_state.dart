import 'package:flutter/material.dart';
import 'package:pixez/component/sort_group.dart';


class MaterialSortGroupState extends SortGroupStateBase {
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
                ? Theme.of(context).colorScheme.primary
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
