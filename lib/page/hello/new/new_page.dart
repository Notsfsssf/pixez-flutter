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
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/hello/new/illust/new_illust_page.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/users_page.dart';

class NewPage extends StatefulWidget {
  final String newRestrict, bookRestrict, painterRestrict;

  const NewPage(
      {Key? key,
      this.newRestrict = "public",
      this.bookRestrict = "public",
      this.painterRestrict = "public"})
      : super(key: key);

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  late StreamSubscription<String> subscription;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "300") {
        String name = (300 + _tabController.index + 1).toString();
        topStore.setTop(name);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(builder: (context) {
      if (accountStore.now != null)
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.0,
              title: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  controller: _tabController,
                  isScrollable: true,
                  indicator: MD2Indicator(
                      indicatorHeight: 3,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      indicatorSize: MD2IndicatorSize.normal),
                  onTap: (i) {
                    if (_tabController.index == i)
                      topStore.setTop((301 + i).toString());
                  },
                  tabs: [
                    Tab(
                      text: I18n.of(context).news,
                    ),
                    Tab(
                      text: I18n.of(context).bookmark,
                    ),
                    Tab(
                      text: I18n.of(context).followed,
                    ),
                  ]),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => UsersPage(
                              id: int.parse(accountStore.now!.userId),
                            )));
                  },
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  NewIllustPage(),
                  BookmarkPage(
                    isNested: false,
                    id: int.parse(accountStore.now!.userId),
                  ),
                  FollowList(
                    id: int.parse(accountStore.now!.userId),
                  ),
                ],
              ),
            )
          ],
        );
      return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                        '${I18n.of(context).follow}${I18n.of(context).news}'),
                  ),
                  Tab(
                    child: Text(
                        '${I18n.of(context).personal}${I18n.of(context).bookmark}'),
                  ),
                  Tab(
                    child: Text(
                        '${I18n.of(context).follow}${I18n.of(context).painter}'),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                LoginInFirst(),
                LoginInFirst(),
                LoginInFirst(),
              ],
            ),
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
