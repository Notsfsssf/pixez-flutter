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
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/user/bookmark/tag/bookmark_tag_store.dart';

class UserBookmarkTagPage extends StatefulWidget {
  @override
  _UserBookmarkTagPageState createState() => _UserBookmarkTagPageState();
}

class _UserBookmarkTagPageState extends State<UserBookmarkTagPage>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).tag),
      ),
      content: NavigationView(
          pane: NavigationPane(items: [
        PaneItem(
          icon: Icon(FluentIcons.public_folder),
          title: Text(I18n.of(context).public),
          body: NewWidget(
            restrict: "public",
          ),
        ),
        PaneItem(
          icon: Icon(FluentIcons.lock),
          title: Text(I18n.of(context).private),
          body: NewWidget(
            restrict: "private",
          ),
        ),
      ], displayMode: PaneDisplayMode.top)),
    );
  }
}

class NewWidget extends StatelessWidget {
  final String restrict;

  const NewWidget({Key? key, required this.restrict}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EasyRefreshController _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    BookMarkTagStore _bookMarkTagStore = BookMarkTagStore(
        int.parse(accountStore.now!.userId), _easyRefreshController);
    return Observer(builder: (_) {
      return EasyRefresh(
        controller: _easyRefreshController,
        refreshOnStart: true,
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index == 0)
              return ListTile(
                title: Text(I18n.of(context).all),
                onPressed: () {
                  Navigator.pop(context, {"tag": null, "restrict": restrict});
                },
              );
            else if (index == 1)
              return ListTile(
                title: Text(I18n.of(context).unclassified),
                onPressed: () {
                  Navigator.pop(
                      context, {"tag": "未分類", "restrict": restrict}); //日语
                },
              );
            var bookmarkTag = _bookMarkTagStore.bookmarkTags[index - 2];
            return ListTile(
              title: Text(bookmarkTag.name),
              trailing: Text(bookmarkTag.count.toString()),
              onPressed: () {
                Navigator.pop(
                    context, {"tag": bookmarkTag.name, "restrict": restrict});
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
    });
  }
}
