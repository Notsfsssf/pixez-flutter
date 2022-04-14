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
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/bookmark/tag/user_bookmark_tag_page.dart';

class MaterialBookmarkPageState extends BookmarkPageStateBase {
  Widget buildTopChip(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SortGroup(
            children: [I18n.of(context).public, I18n.of(context).private],
            onChange: (index) {
              if (index == 0)
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict = 'public', null));
                });
              if (index == 1)
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict = 'private', null));
                });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UserBookmarkTagPage()));
                if (result != null) {
                  String? tag = result['tag'];
                  String restrict = result['restrict'];
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (bool e) => apiClient.getBookmarksIllust(
                            widget.id, restrict, tag));
                  });
                }
              },
              child: Chip(
                label: Icon(Icons.sort),
                backgroundColor: Theme.of(context).cardColor,
                elevation: 4.0,
                padding: EdgeInsets.all(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
