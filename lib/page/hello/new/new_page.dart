import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewPage extends StatefulWidget {
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: TabBar(isScrollable: true, tabs: [
                Tab(
                  text: "Illust",
                ),
                Tab(
                  text: "Painter",
                ),
              ]),
            ),
            Expanded(
                child: TabBarView(
              children: [],
            ))
          ],
        ));
  }
}
