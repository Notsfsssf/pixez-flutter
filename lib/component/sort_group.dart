import 'package:flutter/widgets.dart';
import 'package:pixez/component/sort_group/fluent_state.dart';
import 'package:pixez/component/sort_group/material_state.dart';
import 'package:pixez/constants.dart';

class SortGroup extends StatefulWidget {
  final List<String> children;
  final Function onChange;

  const SortGroup({Key? key, required this.children, required this.onChange})
      : super(key: key);

  @override
  SortGroupStateBase createState() {
    if (Constants.isFluentUI)
      return FluentSortGroupState();
    else
      return MaterialSortGroupState();
  }
}

abstract class SortGroupStateBase extends State<SortGroup> {
  int index = 0;

  @override
  void initState() {
    super.initState();
  }
}
