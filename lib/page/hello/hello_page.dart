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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/deep_link_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/Init/guide_page.dart';
import 'package:pixez/page/hello/new/new_page.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/recom_spotlight_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/search/search_page.dart';

class HelloPage extends StatefulWidget {
  @override
  _HelloPageState createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  late StreamSubscription _sub;
  late int index;
  late PageController _pageController;
  double? bottomNavigatorHeight = null;
  late List<Widget> _lists;

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _lists = <Widget>[
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
          return Column(children: [
            AppBar(
              title: Text('rank(day)'),
            ),
            Expanded(child: PreviewPage())
          ]);
      }),
      NewPage(),
      SearchPage(),
      SettingPage()
    ];
    Constants.type = 0;
    fetcher.context = context;
    index = userSetting.welcomePageNum;
    _pageController = PageController(initialPage: userSetting.welcomePageNum);
    super.initState();
    saveStore.ctx = this.context;
    saveStore.saveStream.listen((stream) {
      saveStore.listenBehavior(stream);
    });
    initLinksStream();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (Prefer.getInt('language_num') == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GuidePage()));
    }
  }

  Future<void> initLinksStream() async {
    try {
      Uri? initialLink = await DeepLinkPlugin.getInitialUri();
      if (initialLink != null) Leader.pushWithUri(context, initialLink);
      _sub = DeepLinkPlugin.uriLinkStream
          .listen((Uri? link) => Leader.pushWithUri(context, link!));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bottomNavigatorHeight == null) {
      bottomNavigatorHeight = MediaQuery.of(context).padding.bottom + 80;
    }
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > constraints.maxHeight;
      return Scaffold(
        body: Row(
          children: <Widget>[
            if (wide) ..._buildRail(context),
            Expanded(
              child: _buildPageView(context),
            ),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: wide
            ? null
            : Observer(builder: (context) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  transform: Matrix4.translationValues(
                      0,
                      fullScreenStore.fullscreen ? bottomNavigatorHeight! : 0,
                      0),
                  child: _buildNavigationBar(context),
                );
              }),
      );
    });
  }

  List<Widget> _buildRail(BuildContext context) {
    return [
      Stack(
        children: [
          NavigationRail(
            selectedIndex: index,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              _pageController.jumpToPage(index);
              setState(() {
                index = index;
              });
            },
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text(I18n.of(context).home)),
              NavigationRailDestination(
                  icon: Icon(Icons.leaderboard),
                  label: Text(I18n.of(context).rank)),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text(I18n.of(context).quick_view)),
              NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text(I18n.of(context).search)),
              NavigationRailDestination(
                  icon: Icon(Icons.more_horiz),
                  label: Text(I18n.of(context).more)),
            ],
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).padding.left,
                  bottom: MediaQuery.of(context).padding.bottom + 4.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: accountStore.now != null
                      ? PainterAvatar(
                          url: accountStore.now!.userImage,
                          id: int.tryParse(accountStore.now!.userId) ?? 0)
                      : Container(),
                ),
              ),
            ),
          ),
        ],
      ),
      const VerticalDivider(thickness: 1, width: 1),
    ];
  }

  Widget _buildNavigationBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: NavigationBar(
          height: 68,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.home), label: I18n.of(context).home),
            NavigationDestination(
                icon: Icon(
                  Icons.leaderboard,
                ),
                label: I18n.of(context).rank),
            NavigationDestination(
                icon: Icon(Icons.favorite), label: I18n.of(context).quick_view),
            NavigationDestination(
                icon: Icon(Icons.search), label: I18n.of(context).search),
            NavigationDestination(
                icon: Icon(Icons.more_horiz), label: I18n.of(context).more)
          ],
          selectedIndex: index,
          onDestinationSelected: (value) {
            if (this.index == index) {
              topStore.setTop("${index + 1}00");
            }
            setState(() {
              this.index = value;
            });
            if (_pageController.hasClients) _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }

  PageView _buildPageView(BuildContext context) {
    return PageView.builder(
        itemCount: 5,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            this.index = index;
          });
        },
        itemBuilder: (context, index) {
          return _lists[index];
        });
  }
}
