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

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/network/network_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
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
    Row(
      children: [
        InkWell(
          onTap: () {
            try {
              if (Platform.isAndroid && !Constants.isGooglePlay)
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
            ],
          ),
        ),
        InkWell(
          onTap: () {
            try {
              if (Platform.isAndroid && !Constants.isGooglePlay)
                launch('https://github.com/takase1121');
            } catch (e) {}
          },
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://avatars0.githubusercontent.com/u/20792268?s=400&u=0abbfec835713da83699ec3a6ae619df4a72a722&v=4'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Takase'),
              ),
              Icon(Icons.translate)
            ],
          ),
        ),
      ],
    ),
    InkWell(
      onTap: () {
        try {
          if (Platform.isAndroid && !Constants.isGooglePlay)
            launch('https://github.com/Skimige');
        } catch (e) {}
      },
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://avatars0.githubusercontent.com/u/9017470?s=460&v=4'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Skimige'),
          ),
          Icon(Icons.translate)
        ],
      ),
    ),
    InkWell(
      onTap: () {
        try {
          if (Platform.isAndroid && !Constants.isGooglePlay)
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
    InkWell(
      onTap: () {
        try {
          if (Platform.isAndroid && !Constants.isGooglePlay)
            launch('https://github.com/karin722');
        } catch (e) {}
      },
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://avatars3.githubusercontent.com/u/54385201?s=460&v=4'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('karin722'),
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
        title: Text(I18n.of(context).quality_setting),
      ),
      body: Container(
        child: ListView(children: [
          if (Platform.isAndroid)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ListTile(
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(I18n.of(context).platform_special_setting),
                    subtitle: Text(
                      "For Android",
                      style: TextStyle(color: Colors.green),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PlatformPage()));
                    },
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: ListTile(
                  trailing: Icon(Icons.keyboard_arrow_right),
                  title: Text(I18n.of(context).network),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NetworkPage(automaticallyImplyLeading: true,)));
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    child: Text(I18n.of(context).large_preview_zoom_quality),
                    padding: EdgeInsets.all(16),
                  ),
                  Observer(builder: (_) {
                    return Container(
                      child: TabBar(
                        indicatorColor: Theme.of(context).accentColor,
                        labelColor: Theme.of(context).textTheme.headline6.color,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(
                            text: I18n.of(context).large,
                          ),
                          Tab(
                            text: I18n.of(context).source,
                          )
                        ],
                        onTap: (index) {
                          userSetting.change(index);
                        },
                        controller: TabController(
                            length: 2,
                            vsync: this,
                            initialIndex: userSetting.zoomQuality),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    child:
                        Text(I18n.of(context).illustration_detail_page_quality),
                    padding: EdgeInsets.all(16),
                  ),
                  Observer(builder: (_) {
                    return TabBar(
                      labelColor: Theme.of(context).textTheme.headline6.color,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).accentColor,
                      tabs: [
                        Tab(
                          text: I18n.of(context).medium,
                        ),
                        Tab(
                          text: I18n.of(context).large,
                        ),
                      ],
                      onTap: (index) {
                        userSetting.setPictureQuality(index);
                      },
                      controller: TabController(
                          length: 2,
                          vsync: this,
                          initialIndex: userSetting.pictureQuality),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    child: Text(I18n.of(context).manga_detail_page_quality),
                    padding: EdgeInsets.all(16),
                  ),
                  Observer(builder: (_) {
                    return TabBar(
                      labelColor: Theme.of(context).textTheme.headline6.color,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).accentColor,
                      tabs: [
                        Tab(
                          text: I18n.of(context).medium,
                        ),
                        Tab(
                          text: I18n.of(context).large,
                        ),
                        Tab(
                          text: I18n.of(context).source,
                        ),
                      ],
                      onTap: (index) {
                        userSetting.setMangaQuality(index);
                      },
                      controller: TabController(
                          length: 3,
                          vsync: this,
                          initialIndex: userSetting.mangaQuality),
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
                      indicatorColor: Theme.of(context).accentColor,
                      tabs: [
                        Tab(
                          text: "en-US",
                        ),
                        Tab(
                          text: "zh-CN",
                        ),
                        Tab(
                          text: "zh-TW",
                        ),
                        Tab(
                          text: "ja",
                        ),
                      ],
                      onTap: (index) async {
                        await userSetting.setLanguageNum(index);
                        setState(() {
                          _languageTranlator = _group[index];
                        });
                      },
                      controller: TabController(
                          length: 4,
                          vsync: this,
                          initialIndex: userSetting.languageNum),
                    ),
                  );
                })
              ],
            )),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
                child: Column(
              children: <Widget>[
                Padding(
                  child: Text(I18n.of(context).welcome_page),
                  padding: EdgeInsets.all(16),
                ),
                Observer(builder: (_) {
                  var tablist = Platform.isAndroid
                      ? [
                          Tab(
                            text: I18n.of(context).home,
                          ),
                          Tab(
                            text: I18n.of(context).rank,
                          ),
                          Tab(
                            text: I18n.of(context).quick_view,
                          ),
                          Tab(
                            text: I18n.of(context).search,
                          ),
                          Tab(
                            text: I18n.of(context).setting,
                          ),
                        ]
                      : [
                          Tab(
                            text: I18n.of(context).home,
                          ),
                          Tab(
                            text: I18n.of(context).quick_view,
                          ),
                          Tab(
                            text: I18n.of(context).search,
                          ),
                          Tab(
                            text: I18n.of(context).setting,
                          ),
                        ];
                  return Theme(
                    data: Theme.of(context).copyWith(
                        tabBarTheme: TabBarTheme(labelColor: Colors.black)),
                    child: TabBar(
                      labelColor: Theme.of(context).textTheme.headline6.color,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).accentColor,
                      tabs: tablist,
                      onTap: (index) {
                        userSetting.setWelcomePageNum(index);
                      },
                      controller: TabController(
                          length: tablist.length,
                          vsync: this,
                          initialIndex: userSetting.welcomePageNum),
                    ),
                  );
                })
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    child: Text(I18n.of(context).crosscount),
                    padding: EdgeInsets.all(16),
                  ),
                  Observer(builder: (_) {
                    return TabBar(
                      labelColor: Theme.of(context).textTheme.headline6.color,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).accentColor,
                      tabs: [
                        Tab(
                          text: '2',
                        ),
                        Tab(
                          text: '4',
                        )
                      ],
                      onTap: (index) {
                        userSetting.setCrossCount(index == 0 ? 2 : 4);
                        BotToast.showText(
                            text: I18n.of(context).need_to_restart_app);
                      },
                      controller: TabController(
                          length: 2,
                          vsync: this,
                          initialIndex: userSetting.crossCount == 2 ? 0 : 1),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Observer(builder: (_) {
                return SwitchListTile(
                    activeColor: Theme.of(context).accentColor,
                    value: userSetting.isBangs,
                    title: Text(I18n.of(context).special_shaped_screen),
                    subtitle: Text('--v--'),
                    onChanged: (value) async {
                      userSetting.setIsBangs(value);
                    });
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Observer(builder: (_) {
                return SwitchListTile(
                    activeColor: Theme.of(context).accentColor,
                    value: userSetting.hIsNotAllow,
                    title: Text('H是不行的！'),
                    onChanged: (value) async {
                      if (!value) BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                      userSetting.setHIsNotAllow(value);
                    });
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Observer(builder: (_) {
                return SwitchListTile(
                    activeColor: Theme.of(context).accentColor,
                    value: userSetting.isReturnAgainToExit,
                    title: Text(I18n.of(context).return_again_to_exit),
                    onChanged: (value) async {
                      userSetting.setIsReturnAgainToExit(value);
                    });
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Observer(builder: (_) {
                return SwitchListTile(
                    activeColor: Theme.of(context).accentColor,
                    value: userSetting.followAfterStar,
                    title: Text(I18n.of(context).follow_after_star),
                    onChanged: (value) async {
                      userSetting.setFollowAfterStar(value);
                    });
              }),
            ),
          )
        ]),
      ),
    );
  }
}
