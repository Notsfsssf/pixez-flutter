import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/er/leader.dart';

class CommonBackArea extends StatefulWidget {
  const CommonBackArea({super.key});

  @override
  State<CommonBackArea> createState() => _CommonBackAreaState();
}

class _CommonBackAreaState extends State<CommonBackArea> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 6,
        ),
        BackButton(),
        IconButton(
            onPressed: () {
              Leader.pushUntilHome(context);
            },
            icon: Icon(Icons.home))
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}
