import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelRankPage extends StatefulWidget {
  @override
  _NovelRankPageState createState() => _NovelRankPageState();
}

class _NovelRankPageState extends State<NovelRankPage>
    with AutomaticKeepAliveClientMixin {
  final modeList = [
    "day",
    "day_male",
    "day_female",
    "week",
    "week_ai",
    "week_ai_r18",
    "day_r18",
    "week_r18",
    "week_r18g"
  ];
  late FutureGet futureGet;

  @override
  void initState() {
    futureGet = () {
      return apiClient.getNovelRanking(modeList.first, null);
    };
    super.initState();
  }

  String? toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  String? dateTime;
  DateTime nowDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> w = I18n.of(context).novel_mode_list.split(" ");
    return DefaultTabController(
      length: modeList.length,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              tabs: [
                for (var i in w)
                  Tab(
                    text: i,
                  )
              ]),
          actions: [
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () async {
                var nowdate = DateTime.now();
                var date = await showDatePicker(
                    context: context,
                    initialDate: nowDateTime,
                    locale: userSetting.locale,
                    firstDate: DateTime(2007, 8),
                    //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
                    lastDate: nowdate);
                if (date != null && mounted) {
                  nowDateTime = date;
                  setState(() {
                    this.dateTime = toRequestDate(date);
                  });
                }
              },
            ),
          ],
        ),
        body: TabBarView(children: [
          for (var i in modeList)
            NovelLightingList(
              futureGet: () => apiClient.getNovelRanking(i, dateTime),
            )
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
