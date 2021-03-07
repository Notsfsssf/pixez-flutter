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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/novel/bookmark/novel_bookmark_page.dart';
import 'package:pixez/page/novel/new/novel_new_page.dart';

class NovelQuickPage extends StatefulWidget {
  @override
  _NovelQuickPageState createState() => _NovelQuickPageState();
}

class _NovelQuickPageState extends State<NovelQuickPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(
                text: I18n.of(context).news,
              ),
              Tab(
                text: I18n.of(context).bookmark,
              ),
              Tab(
                text: I18n.of(context).follow,
              ),
            ],
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: TabBarView(children: [
          NovelNewPage(),
          NovelBookmarkPage(),
          FollowList(
            id: int.parse(accountStore.now!.userId),
            isNovel: true,
          )
        ]),
      ),
    );
  }
}
