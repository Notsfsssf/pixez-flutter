import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TransportAppBar extends StatelessWidget {
  final List<Widget> actions;

  const TransportAppBar({Key key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.body1.color,
                ),
                onPressed: () =>
                    Navigator.canPop(context) ? Navigator.pop(context) : null,
              ),
              Column(
                children: actions == null ? [] : actions,
              )
            ],
          ),
        ],
      ),
    );
  }
}
