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
    return GestureDetector(
      child: IconButton(
        icon: BackButtonIcon(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      onLongPress: () {
        Leader.popUtilHome(context);
      },
    );
  }
}
