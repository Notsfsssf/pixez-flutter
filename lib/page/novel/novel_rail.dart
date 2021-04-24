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
import 'package:flutter/material.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_icon.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AndroidHelloPage()));
        },
        child: Icon(Icons.picture_in_picture),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: I18n.of(context).home),
          BottomNavigationBarItem(
              icon: Icon(CustomIcons.leaderboard),
              label: I18n.of(context).rank),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: I18n.of(context).news),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: I18n.of(context).search),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: I18n.of(context).setting),
        ],
        onTap: (index) {
          if (_pageController.hasClients) _pageController.jumpToPage(index);
          setState(() {
            selectedIndex = index;
          });
        },
      ),
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
    );
  }
}
