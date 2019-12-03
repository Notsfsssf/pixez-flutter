import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/ranking_mode_page.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
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
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: modeList.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rank"),
        bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: modeList.map((f) {
              return Tab(
                text: f,
              );
            }).toList()),
      ),
      body: TabBarView(
          controller: _tabController,
          children: modeList.map((f) {
            return RankingModePage(
              mode: f,
            );
          }).toList()),
    );
  }
}
