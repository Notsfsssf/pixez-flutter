import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Quality_Setting),
      ),
      body: Container(
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    child: Text(I18n.of(context).Large_preview_zoom_quality),
                    padding: EdgeInsets.all(16),
                  ),
                  Observer(builder: (_) {
                    return TabBar(
                      labelColor: Theme.of(context).textTheme.headline6.color,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          text: I18n.of(context).Large,
                        ),
                        Tab(
                          text: I18n.of(context).Source,
                        )
                      ],
                      onTap: (index) {
                        userSetting.change(index);
                      },
                      controller: TabController(
                          length: 2,
                          vsync: this,
                          initialIndex: userSetting.zoomQuality),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
                child: Column(
              children: <Widget>[
                Padding(
                  child: Text("Language"),
                  padding: EdgeInsets.all(16),
                ),
                Observer(builder: (_) {
                  return Theme(
                    data: Theme.of(context).copyWith(tabBarTheme: TabBarTheme(
                        labelColor: Colors.black
                    )),
                    child: TabBar(
                      labelColor: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .color,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          text: "en-US",
                        ),
                        Tab(
                          text: "zh-CN",
                        ),
                        Tab(
                          text: "zh-TW",
                        )
                      ],
                      onTap: (index) async {
                        await userSetting.setLanguageNum(index);
                        setState(() {});
                      },
                      controller: TabController(
                          length: 3,
                          vsync: this,
                          initialIndex: userSetting.languageNum),
                    ),
                  );
                })
              ],
            )),
          )
        ]),
      ),
    );
  }
}
