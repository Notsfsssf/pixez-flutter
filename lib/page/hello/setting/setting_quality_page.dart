/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
                  child: Text(I18n.of(context).Language),
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
