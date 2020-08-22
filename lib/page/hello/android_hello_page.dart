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
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constraint.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/init_page.dart';
import 'package:pixez/page/about/last_release.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/saucenao/saucenao_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class AndroidHelloPage extends StatefulWidget {
  @override
  _AndroidHelloPageState createState() => _AndroidHelloPageState();
}

class _AndroidHelloPageState extends State<AndroidHelloPage> {
  List<Widget> _widgetOptions;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (accountStore.now != null) {
        return _buildScaffold(context);
      }
      return LoginPage();
    });
  }

  int _stackIndex = 0;

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                this.index = index;
              });
            },
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return _widgetOptions[index];
            },
          ),
          SearchPage(),
          SettingPage(hasNewVersion: hasNewVersion),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: (index) {
            if (index < 3) {
              setState(() {
                this.index = index;
                _stackIndex = 0;
              });
              _pageController.jumpToPage(index);
            } else {
              setState(() {
                this.index = index;
                _stackIndex = index - 2;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text(I18n.of(context).home)),
            BottomNavigationBarItem(
                icon: Icon(Icons.ac_unit), title: Text(I18n.of(context).rank)),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                title: Text(I18n.of(context).quick_view)),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text(I18n.of(context).search)),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text(I18n.of(context).setting)),
          ]),
    );
  }

  int index;
  PageController _pageController;
  StreamSubscription _intentDataStreamSubscription, _sub;

  initPlatform() async {
    if (Platform.isAndroid) {
      try {
        Uri initialLink = await getInitialUri();
        if (initialLink != null) judgePushPage(initialLink);
        _sub = getUriLinksStream().listen((Uri link) {
          judgePushPage(link);
        });
      } catch (e) {
        print(e);
      }
      if (await DocumentPlugin.needChoice()) {
        await DocumentPlugin.choiceFolder();
      }
    }
  }

  judgePushPage(Uri link) {
    if (link.host.contains('illusts')) {
      var idSource = link.pathSegments.last;
      try {
        int id = int.parse(idSource);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return IllustPage(
            id: id,
          );
        }));
      } catch (e) {}
      return;
    }
    if (link.host.contains('user')) {
      var idSource = link.pathSegments.last;
      try {
        int id = int.parse(idSource);
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return UsersPage(
            id: id,
          );
        }));
      } catch (e) {}
      return;
    }
    if (link.host.contains('pixiv')) {
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
              return UsersPage(
                id: id,
              );
            }));
          } catch (e) {
            print(e);
          }
        }
      }
      if (link.queryParameters['illust_id'] != null) {
        try {
          var id = link.queryParameters['illust_id'];
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return IllustPage(id: int.parse(id));
          }));

          return;
        } catch (e) {}
      }
      if (link.queryParameters['id'] != null) {
        try {
          var id = link.queryParameters['id'];
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) {
            return UsersPage(
              id: int.parse(id),
            );
          }));

          return;
        } catch (e) {}
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
  }

  bool hasNewVersion = false;

  checkUpdate() async {
    try {
      Response response =
          await Dio(BaseOptions(baseUrl: 'https://api.github.com'))
              .get('/repos/Notsfsssf/pixez-flutter/releases/latest');
      final result = LastRelease.fromJson(response.data);
      List<int> versionNums =
          result.tagName.split('.').map((e) => int.parse(e));
      List<int> newNums =
          Constrains.tagName.split('.').map((e) => int.parse(e));
      for (int i = 0; i < versionNums.length; i++) {
        if (versionNums[i] < newNums[i]) {
          if (mounted) {
            setState(() {
              hasNewVersion = true;
            });
          }
        }
      }
    } catch (e) {}
  }

  @override
  void initState() {
    index = userSetting.welcomePageNum;
    if (index < 3) {
      _stackIndex = 0;
    } else {
      _stackIndex = index - 2;
    }
    _pageController = userSetting.welcomePageNum < 3
        ? PageController(initialPage: userSetting.welcomePageNum)
        : PageController();
    _widgetOptions = <Widget>[
      RecomSpolightPage(),
      RankPage(),
      NewPage(),
    ];
    super.initState();
    saveStore.context = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value != null)
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SauceNaoPage(
            path: value.first.path,
          );
        }));
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });
    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value != null)
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SauceNaoPage(
            path: value.first.path,
          );
        }));
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  initPlatformState() async {
    initPlatform();
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => InitPage()));
    }
  }
}
