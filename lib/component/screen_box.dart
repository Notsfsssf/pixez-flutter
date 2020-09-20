import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/main.dart';

class ScreenBox extends StatelessWidget {
  final Widget child;

  const ScreenBox({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: userSetting.isBangs ? MediaQuery.of(context).padding.top : 0.0),
      child: child,
    );
  }
}
