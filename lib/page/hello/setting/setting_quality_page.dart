import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/i18n.dart';
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
                    child: Text("大图预览缩放"),
                    padding: EdgeInsets.all(16),
                  ),
                  Observer(builder: (_) {
                    return TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          text: "大图",
                        ),
                        Tab(
                          text: "原图",
                        )
                      ],
                      onTap: (index) {
                        userSetting.change(index);
                      },
                      controller: TabController(length: 2, vsync: this,initialIndex: userSetting.zoomQuality),
                    );
                  })
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
