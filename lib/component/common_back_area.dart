import 'package:flutter/material.dart';
import 'package:pixez/er/leader.dart';

class CommonBackArea extends StatefulWidget {
  const CommonBackArea({super.key});

  @override
  State<CommonBackArea> createState() => _CommonBackAreaState();
}

class _CommonBackAreaState extends State<CommonBackArea> {
  bool _isLongPress = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IconButton(
        icon: _isLongPress ? Icon(Icons.home) : BackButtonIcon(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      onLongPress: () {
        setState(() {
          _isLongPress = true;
        });
        Leader.popUtilHome(context);
      },
    );
  }
}
