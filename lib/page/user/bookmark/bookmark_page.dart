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
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/tag/user_bookmark_tag_page.dart';

class BookmarkPage extends StatefulWidget {
  final int id;
  final String restrict;
  final String tag;

  const BookmarkPage(
      {Key key, @required this.id, this.restrict = "public", this.tag})
      : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  FutureGet futureGet;

  @override
  void initState() {
    futureGet =
        () => apiClient.getBookmarksIllust(widget.id, widget.restrict, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (accountStore.now != null) {
      if (int.parse(accountStore.now.userId) == widget.id) {
        return LightingList(
          source: futureGet,
          header: Container(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(Icons.toys),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => UserBookmarkTagPage()));
                    if (result != null) {
                      String tag = result['tag'];
                      String restrict = result['restrict'];
                      setState(() {
                        futureGet = () => apiClient.getBookmarksIllust(
                            widget.id, restrict, tag);
                      });
                    }
                  }),
            ),
          ),
        );
      }
      return LightingList(
        source: futureGet,
      );
    } else {
      return Container();
    }
  }
}
