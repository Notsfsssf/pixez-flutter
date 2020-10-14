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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/init_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  StreamSubscription _sub;
  @override
  void dispose() {
    _sub?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  int index;
  PageController _pageController;
  @override
  void initState() {
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: userSetting.welcomePageNum);
    super.initState();
    saveStore.context = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
  }

  judgePushPage(Uri link) {
    if (link.path.contains("artworks")) {
      List<String> paths = link.pathSegments;
      int index = paths.indexOf("artworks");
      if (index != -1) {
        try {
          int id = int.parse(paths[index + 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return IllustPage(id: id);
          }));
          return;
        } catch (e) {}
      }
    }
    if (link.path.contains("users")) {
      List<String> paths = link.pathSegments;
      int index = paths.indexOf("users");
      if (index != -1) {
        try {
          int id = int.parse(paths[index + 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return IllustPage(id: id);
          }));
        } catch (e) {
          print(e);
        }
      }
    }
    if (link.pathSegments.length >= 2) {
      String i = link.pathSegments[link.pathSegments.length - 2];
      if (i == "i") {
        try {
          int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return IllustPage(id: id);
          }));
          return;
        } catch (e) {}
      }

      if (i == "u") {
        try {
          int id = int.parse(link.pathSegments[link.pathSegments.length - 1]);
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return UsersPage(
              id: id,
            );
          }));
          return;
        } catch (e) {}
      }
    }
  }

  initPlatformState() async {
    try {
      Uri initialLink = await getInitialUri();
      print(initialLink);
      if (initialLink != null) judgePushPage(initialLink);
      _sub = getUriLinksStream().listen((Uri link) {
        print("link:${link}");
        judgePushPage(link);
      });
    } catch (e) {
      print(e);
    }
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => InitPage()));
    }
  }

  var lists = <Widget>[
    Observer(builder: (context) {
      if (accountStore.now != null)
        return RecomSpolightPage();
      else
        return PreviewPage();
    }),
      Observer(builder: (context) {
      if (accountStore.now != null)
        return RankPage();
      else
        return Column(children:[
          AppBar(title: Text('rank(day)'),),
          Expanded(child: PreviewPage())
        ]);
    }),
    NewPage(),
    SearchPage(),
    SettingPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          itemCount: 5,
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              this.index = index;
            });
          },
          itemBuilder: (context, index) {
            return lists[index];
          }),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          currentIndex: index,
          onTap: (index) {
            setState(() {
              this.index = index;
            });
            _pageController.jumpToPage(index);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: I18n.of(context).home),
            BottomNavigationBarItem(
                icon: Icon(CustomIcons.leaderboard),
                label: I18n.of(context).rank),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark), label: I18n.of(context).quick_view),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: I18n.of(context).search),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: I18n.of(context).setting),
          ]),
    );
  }
}
