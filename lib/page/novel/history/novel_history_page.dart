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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';

class NovelHistory extends StatefulWidget {
  @override
  _NovelHistoryState createState() => _NovelHistoryState();
}

class _NovelHistoryState extends State<NovelHistory> {
  @override
  void initState() {
    novelHistoryStore.fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(I18n.of(context).history)),
        body: novelHistoryStore.data.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  final novel = novelHistoryStore.data[index];
                  return ListTile(
                    title: Text(novel.title),
                    subtitle: Text(novel.userName),
                    onTap: () => Leader.push(
                        context, NovelViewerPage(id: novel.novelId)),
                  );
                },
                itemCount: novelHistoryStore.data.length,
              )
            : Container(),
      );
    });
  }
}
