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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/user/bookmark/tag/bookmark_tag_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserBookmarkTagPage extends StatefulWidget {
  @override
  _UserBookmarkTagPageState createState() => _UserBookmarkTagPageState();
}

class _UserBookmarkTagPageState extends State<UserBookmarkTagPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).tag),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: I18n.of(context).public,
            ),
            Tab(
              text: I18n.of(context).private,
            ),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        NewWidget(
          restrict: "public",
        ),
        NewWidget(
          restrict: "private",
        ),
      ]),
    );
  }
}

class NewWidget extends StatelessWidget {
  final String restrict;

  const NewWidget({Key? key, required this.restrict}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController _easyRefreshController =
        RefreshController(initialRefresh: true);
    BookMarkTagStore _bookMarkTagStore = BookMarkTagStore(
        int.parse(accountStore.now!.userId), _easyRefreshController);
    return Observer(builder: (_) {
      return SmartRefresher(
        enablePullUp: true,
        controller: _easyRefreshController,
        child: _bookMarkTagStore.bookmarkTags.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  if (index == 0)
                    return ListTile(
                      title: Text("All"),
                      onTap: () {
                        Navigator.pop(
                            context, {"tag": null, "restrict": restrict});
                      },
                    );
                  var bookmarkTag = _bookMarkTagStore.bookmarkTags[index - 1];
                  return ListTile(
                    title: Text(bookmarkTag.name),
                    trailing: Text(bookmarkTag.count.toString()),
                    onTap: () {
                      Navigator.pop(context,
                          {"tag": bookmarkTag.name, "restrict": restrict});
                    },
                  );
                },
                itemCount: _bookMarkTagStore.bookmarkTags.length + 1,
              )
            : Container(),
        onRefresh: () async {
          await _bookMarkTagStore.fetch(restrict);
        },
        onLoading: () async {
          await _bookMarkTagStore.next();
        },
      );
    });
  }
}
