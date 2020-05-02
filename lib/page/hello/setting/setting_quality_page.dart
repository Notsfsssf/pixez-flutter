import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/store/user_setting.dart';

final UserSetting userSetting = UserSetting();

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ListView(children: [
          Card(
            child: Column(
              children: <Widget>[
                Padding(
                  child: Text("data"),
                  padding: EdgeInsets.all(16),
                ),
                TabBar(
                  tabs: [
                    Tab(
                      text: "s",
                    ),
                    Tab(
                      text: "s",
                    )
                  ],
                  onTap: (index) {
                    userSetting.change(index);
                  },
                  controller: TabController(length: 2, vsync: this),
                )
              ],
            ),
          ),
          Card(
            child: Column(
              children: <Widget>[
                Observer(builder: (_) {
                  return Text("data"+userSetting.zoomQuality.toString());
                }),
                TabBar(
                  tabs: [
                    Tab(
                      text: "s",
                    ),
                    Tab(
                      text: "s",
                    )
                  ],
                  onTap: (index) {
                    userSetting.change(index);
                  },
                  controller: TabController(length: 2, vsync: this),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
