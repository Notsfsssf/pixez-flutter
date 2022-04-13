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

import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/guide_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/fluent_setting_page.dart';
import 'package:pixez/page/login/fluent_login_page.dart';
import 'package:pixez/page/preview/fluent_preview_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/widgetkit_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FluentHelloPage extends StatefulWidget {
  @override
  _FluentHelloPageState createState() => _FluentHelloPageState();
}

class _FluentHelloPageState extends State<FluentHelloPage> {
  late List<Widget> _pageList;
  late StreamSubscription _sub;
  late int index;
  late PageController _pageController;
  DateTime? _preTime;

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Constants.type = 0;
    fetcher.context = context;
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: userSetting.welcomePageNum);
    super.initState();
    saveStore.context = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    WidgetkitPlugin.notify();
  }

  Future<void> initPlatformState() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(FluentPageRoute(builder: (context) => GuidePage()));
    }
  }

  List<Widget> _lists = <Widget>[
    Observer(builder: (context) {
      if (accountStore.now != null)
        return RecomSpolightPage();
      else
        return FluentPreviewPage();
    }),
    Observer(builder: (context) {
      if (accountStore.now != null)
        return RankPage();
      else
        return Column(
            children: [Text('rank(day)'), Expanded(child: PreviewPage())]);
    }),
    NewPage(),
    // SearchPage(),
    FluentSettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      // TODO: 登录部分待修复
      // if (accountStore.now != null) {
      return _buildNavigationView(context);
      // }
      // return FluentLoginPage();
    });
  }

  Widget _buildNavigationView(BuildContext context) {
    return NavigationView(
        pane: NavigationPane(
            size: NavigationPaneSize(openMaxWidth: 250.0),
            selected: index,
            onChanged: (i) => setState(() => index = i),
            autoSuggestBox: AutoSuggestBox(
              controller: TextEditingController(),
              items: const ['Item 1', 'Item 2', 'Item 3', 'Item 4'],
              placeholder: "Search...",
              trailingIcon: Icon(FluentIcons.search),
            ),
            items: <NavigationPaneItem>[
              PaneItem(
                  icon: Icon(FluentIcons.home),
                  title: Text(I18n.of(context).home)),
              PaneItem(
                  icon: Icon(CustomIcons.leaderboard),
                  title: Text(I18n.of(context).rank)),
              PaneItem(
                  icon: Icon(FluentIcons.bookmarks),
                  title: Text(I18n.of(context).quick_view)),
              // PaneItem(
              //     icon: Icon(FluentIcons.search),
              //     title: Text(I18n.of(context).search)),
            ],
            footerItems: [
              PaneItemSeparator(),
              PaneItem(
                  icon: Icon(FluentIcons.settings),
                  title: Text(I18n.of(context).setting)),
            ]),
        content: NavigationBody(index: index, children: _lists));
  }
}
