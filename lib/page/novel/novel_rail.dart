/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/hello/setting/setting_page.dart';
import 'package:pixez/page/novel/new/novel_new_page.dart';
import 'package:pixez/page/novel/rank/novel_rank_page.dart';
import 'package:pixez/page/novel/recom/novel_recom_page.dart';
import 'package:pixez/page/novel/search/novel_search_page.dart';

class NovelRail extends StatefulWidget {
  @override
  _NovelRailState createState() => _NovelRailState();
}

class _NovelRailState extends State<NovelRail> {
  int selectedIndex = 0;
  DateTime? _preTime;
  final _pageList = [
    NovelRecomPage(),
    NovelRankPage(),
    NovelNewPage(),
    NovelSearchPage(),
    SettingPage()
  ];
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    Constants.type = 1;
    fetcher.context = context;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        userSetting.setAnimContainer(!userSetting.animContainer);
        if (!userSetting.isReturnAgainToExit ||
          _preTime != null &&
              DateTime.now().difference(_preTime!) <= Duration(seconds: 2)) return true;
        if (!userSetting.isReturnAgainToExit) {
          return true;
        }
        if (_preTime == null ||
            DateTime.now().difference(_preTime!) > Duration(seconds: 2)) {
          setState(() {
            _preTime = DateTime.now();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text(I18n.of(context).return_again_to_exit),
          ));
        }
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Platform.isIOS || Platform.isMacOS
                    ? HelloPage()
                    : AndroidHelloPage()));
          },
          child: Icon(Icons.picture_in_picture),
        ),
        bottomNavigationBar: _buildNavigationBar(context),
        body: PageView.builder(
            itemCount: _pageList.length,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                this.selectedIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _pageList[index];
            }),
      ),
    );
  }

  NavigationBar _buildNavigationBar(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(
            icon: Icon(Icons.home), label: I18n.of(context).home),
        NavigationDestination(
            icon: Icon(
              Icons.leaderboard,
            ),
            label: I18n.of(context).rank),
        NavigationDestination(
            icon: Icon(Icons.favorite), label: I18n.of(context).news),
        NavigationDestination(
            icon: Icon(Icons.search), label: I18n.of(context).search),
        NavigationDestination(
            icon: Icon(Icons.settings), label: I18n.of(context).setting)
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (this.selectedIndex == index) {
          topStore.setTop("${index + 1}00");
        }
        setState(() {
          this.selectedIndex = index;
        });
        if (_pageController.hasClients) _pageController.jumpToPage(index);
      },
    );
  }
}
