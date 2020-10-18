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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/search/result_illust_list.dart';

class BookTagPage extends StatefulWidget {
  @override
  _BookTagPageState createState() => _BookTagPageState();
}

class _BookTagPageState extends State<BookTagPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: bookTagStore.bookTagList.length,
        child: Column(
          children: [
            AppBar(
              title: Text(I18n.of(context).favorited_tag),
              bottom: TabBar(tabs: [
                for (var i in bookTagStore.bookTagList)
                  Tab(
                    text: i,
                  )
              ]),
            ),
            Expanded(
                child: TabBarView(children: [
              for (var j in bookTagStore.bookTagList)
                ResultIllustList(
                  word: j,
                )
            ]))
          ],
        ));
  }

  Widget _buildTagChip() {
    return Container(
      child: Wrap(
        children: [
          for (var i in bookTagStore.bookTagList)
            FilterChip(
                label: Text(i),
                selected: true,
                onSelected: (v) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(I18n.of(context).delete + "$i?"),
                          actions: [
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(I18n.of(context).cancel)),
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  bookTagStore.unBookTag(i);
                                },
                                child: Text(I18n.of(context).ok)),
                          ],
                        );
                      });
                })
        ],
      ),
    );
  }
}
