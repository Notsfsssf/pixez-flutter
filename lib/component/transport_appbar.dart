import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TransportAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new IconButton(
                icon: new Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
                onPressed: () =>
                    Navigator.canPop(context) ? Navigator.pop(context) : null,
              ),
              new IconButton(
                icon: new Icon(
                  Icons.more_vert,
                  color: Colors.black54,
                ),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }
}