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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/user/bookmark/tag/bookmark_tag_store.dart';

class UserBookmarkTagPage extends StatefulWidget {
  final String? currentTag;

  const UserBookmarkTagPage({Key? key, this.currentTag}) : super(key: key);

  @override
  _UserBookmarkTagPageState createState() => _UserBookmarkTagPageState();
}

class _UserBookmarkTagPageState extends State<UserBookmarkTagPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String? currentTag;
  late TextEditingController _tagController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    currentTag = widget.currentTag;
    _tagController = TextEditingController(text: currentTag);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).tag),
        elevation: 0.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: I18n.of(context).public),
            Tab(text: I18n.of(context).private),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(child: Row(children: [TextField()])),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NewWidget(restrict: "public"),
                NewWidget(restrict: "private"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewWidget extends StatefulWidget {
  final String restrict;

  const NewWidget({Key? key, required this.restrict}) : super(key: key);

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  late BookMarkTagStore _bookMarkTagStore = BookMarkTagStore(
    int.parse(accountStore.now!.userId),
    _easyRefreshController,
  );
  late String restrict;

  @override
  void initState() {
    restrict = widget.restrict;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _bookMarkTagStore.fetch(widget.restrict);
    });
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return EasyRefresh(
          controller: _easyRefreshController,
          refreshOnStart: true,
          header: PixezDefault.header(context),
          footer: PixezDefault.footer(context),
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (index == 0)
                return ListTile(
                  title: Text(I18n.of(context).all),
                  onTap: () {
                    Navigator.pop(context, {"tag": null, "restrict": restrict});
                  },
                );
              else if (index == 1)
                return ListTile(
                  title: Text(I18n.of(context).unclassified),
                  onTap: () {
                    Navigator.pop(context, {
                      "tag": "未分類",
                      "restrict": restrict,
                    }); //日语
                  },
                );
              var bookmarkTag = _bookMarkTagStore.bookmarkTags[index - 2];
              return ListTile(
                title: Text(bookmarkTag.name),
                trailing: Text(bookmarkTag.count.toString()),
                onTap: () {
                  Navigator.pop(context, {
                    "tag": bookmarkTag.name,
                    "restrict": restrict,
                  });
                },
              );
            },
            itemCount: _bookMarkTagStore.bookmarkTags.length + 2,
          ),
          onRefresh: () async {
            await _bookMarkTagStore.fetch(restrict);
          },
          onLoad: () async {
            await _bookMarkTagStore.next();
          },
        );
      },
    );
  }
}
