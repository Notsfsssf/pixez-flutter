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
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelUserBookmarkPage extends StatefulWidget {
  final int id;
  NovelUserBookmarkPage({required this.id});

  @override
  _NovelUserBookmarkPageState createState() => _NovelUserBookmarkPageState();
}

class _NovelUserBookmarkPageState extends State<NovelUserBookmarkPage> {
  late FutureGet futureGet;
  String restrict = 'public';

  @override
  void initState() {
    futureGet = () => apiClient.getUserBookmarkNovel(widget.id, restrict);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: int.parse(accountStore.now!.userId) == widget.id
              ? IconButton(
                  icon: Icon(Icons.list),
                  onPressed: () {
                    _buildShowModalBottomSheet(context);
                  })
              : Visibility(
                  child: Container(height: 0),
                  visible: false,
                ),
        ),
        Expanded(
          child: NovelLightingList(
            futureGet: futureGet,
          ),
        ),
      ],
    );
  }

  Future _buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(I18n.of(context).public),
                  onTap: () {
                    setState(() {
                      futureGet = () =>
                          apiClient.getUserBookmarkNovel(widget.id, 'public');
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(I18n.of(context).private),
                  onTap: () {
                    setState(() {
                      futureGet = () =>
                          apiClient.getUserBookmarkNovel(widget.id, 'private');
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
