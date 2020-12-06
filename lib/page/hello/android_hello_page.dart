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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/init_page.dart';
import 'package:pixez/page/directory/save_mode_choice_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/saucenao/saucenao_page.dart';
import 'package:pixez/page/search/search_page.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class KeepContent extends StatelessWidget {
  final Widget item;

  const KeepContent({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: item,
    );
  }
}

class AndroidHelloPage extends StatefulWidget {
  final LightingStore lightingStore;

  const AndroidHelloPage({Key key, this.lightingStore}) : super(key: key);

  @override
  _AndroidHelloPageState createState() => _AndroidHelloPageState();
}

class _AndroidHelloPageState extends State<AndroidHelloPage> {
  List<Widget> _pageList;
  DateTime _preTime;
  QuickActions quickActions;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!userSetting.isReturnAgainToExit) {
          return true;
        }
        if (_preTime == null ||
            DateTime.now().difference(_preTime) > Duration(seconds: 2)) {
          _preTime = DateTime.now();
          BotToast.showText(text: I18n.of(context).return_again_to_exit);
          return false;
        }
        return true;
      },
      child: Observer(builder: (context) {
        if (accountStore.now != null) {
          quickActions.setShortcutItems(<ShortcutItem>[
            ShortcutItem(
                type: 'action_search',
                localizedTitle: I18n.of(context).search,
                icon: 'ic_search'),
          ]);
          return _buildScaffold(context);
        }
        return LoginPage();
      }),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemBuilder: (context, index) {
          return _pageList[index];
        },
        onPageChanged: (index) {
          setState(() {
            this.index = index;
          });
        },
        controller: _pageController,
        itemCount: _pageList.length,
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          currentIndex: index,
          onTap: (index) {
            if (this.index == index) {
              topStore.setTop("${index + 1}00");
            }
            setState(() {
              this.index = index;
            });
            _pageController.jumpToPage(index);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: I18n.of(context).home),
            BottomNavigationBarItem(
                icon: Icon(
                  CustomIcons.leaderboard,
                ),
                label: I18n.of(context).rank),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: I18n.of(context).quick_view),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: I18n.of(context).search),
            BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz), label: I18n.of(context).more),
          ]),
    );
  }

  int index;
  PageController _pageController;
  StreamSubscription _intentDataStreamSubscription;
  StreamSubscription _sub;

  initPlatform() async {
    try {
      Uri initialLink = await getInitialUri();
      if (initialLink != null) Leader.pushWithUri(context, initialLink);
      _sub = getUriLinksStream().listen((Uri link) {
        Leader.pushWithUri(context, link);
      });
    } catch (e) {
      print(e);
    }
  }

  bool hasNewVersion = false;

  @override
  void initState() {
    _pageList = [
      RecomSpolightPage(lightingStore: widget.lightingStore),
      RankPage(),
      NewPage(),
      SearchPage(),
      SettingPage()
    ];
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: index);
    quickActions = QuickActions();
    super.initState();
    saveStore.context = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initPlatformState();
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
    _pageController?.dispose();
    super.dispose();
  }

  initPlatformState() async {
    initPlatform();
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('language_num') == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => InitPage()),
        (route) => route == null,
      );
    } else {
      if (await DocumentPlugin.needChoice()) {
        await showPathDialog(context, isFirst: true);
      }
    }
  }
}
