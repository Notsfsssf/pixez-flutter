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
import 'package:url_launcher/url_launcher.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  Widget _languageTranlator;
  @override
  void initState() {
    _languageTranlator = _group[userSetting.languageNum];
    super.initState();
  }

  var _group = [
    InkWell(
      onTap: () {
        try {
          launch('https://github.com/itzXian');
        } catch (e) {}
      },
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://avatars1.githubusercontent.com/u/34748039?s=400&u=9e784e6754531c9ecadc5d92ed6bc58647053657&v=4'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Xian'),
          ),
          Icon(Icons.translate)
        ],
      ),
    ),
    Container(),
    InkWell(
      onTap: () {
        try {
          launch('https://github.com/TragicLifeHu');
        } catch (e) {}
      },
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://avatars3.githubusercontent.com/u/16817202?s=460&v=4'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Tragic Life'),
          ),
          Icon(Icons.translate)
        ],
      ),
    ),
  ];
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
                  child: Row(
                    children: <Widget>[
                      Text("Language"),
                      _languageTranlator,
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  padding: EdgeInsets.all(16),
                ),
                Observer(builder: (_) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                        tabBarTheme: TabBarTheme(labelColor: Colors.black)),
                    child: TabBar(
                      labelColor: Theme.of(context).textTheme.headline6.color,
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
                        setState(() {
                          _languageTranlator = _group[index];
                        });
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Observer(builder: (_) {
              return SwitchListTile(
                  value: userSetting.disableBypassSni,
                  title: Text(I18n.of(context).Disable_Sni_Bypass),
                  subtitle: Text(I18n.of(context).Disable_Sni_Bypass_Message),
                  onChanged: (value) async {
                    if (value) {
                      final result = await showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text(I18n.of(context).Please_Note_That),
                              content: Text(
                                  I18n.of(context).Please_Note_That_Content),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop('OK');
                                    },
                                    child: Text('ok')),
                                FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop('OK');
                                    },
                                    child: Text('cancel'))
                              ],
                            );
                          });
                      if (result == 'OK') {
                        userSetting.setDisableBypassSni(value);
                      }
                    } else {
                      userSetting.setDisableBypassSni(value);
                    }
                  });
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Observer(builder: (_) {
              return SwitchListTile(
                  value: userSetting.hIsNotAllow,
                  title:
                      Text(userSetting.hIsNotAllow ? 'H是不行的！' : 'H是可以的！(ˉ﹃ˉ)'),
                  onChanged: (value) async {
                    userSetting.setHIsNotAllow(value);
                  });
            }),
          )
        ]),
      ),
    );
  }
}
