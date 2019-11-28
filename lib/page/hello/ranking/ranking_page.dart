import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/ranking_mode_page.dart';

class RankingPage extends StatefulWidget {


  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final modeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_r18",
    "week_r18"
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: modeList.length,
        child: Column(
          children: <Widget>[
            Container(
              color: Theme
                  .of(context)
                  .primaryColor,
              child: TabBar(isScrollable: true, tabs: modeList.map((f) {
                return Tab(text: f,);
              }).toList()),
            ),
            Expanded(child: TabBarView(
                children: modeList.map((f) {
                  return RankingModePage(mode: f,);
                }).toList()),)
          ],
        ));
  }
}
