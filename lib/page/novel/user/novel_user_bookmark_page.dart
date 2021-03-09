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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelUserBookmarkPage extends HookWidget {
  final int id;
  NovelUserBookmarkPage({required this.id});
  @override
  Widget build(BuildContext context) {
    final restrict = useState<String>('public');
    final futureGet = useState<FutureGet>(
        () => apiClient.getUserBookmarkNovel(id, restrict.value));
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: int.parse(accountStore.now!.userId) == id
              ? IconButton(
                  icon: Icon(Icons.list),
                  onPressed: () {
                    _buildShowModalBottomSheet(context, futureGet);
                  })
              : Visibility(
                  child: Container(height: 0),
                  visible: false,
                ),
        ),
        Expanded(
          child: NovelLightingList(
            futureGet: futureGet.value,
          ),
        ),
      ],
    );
  }

  Future _buildShowModalBottomSheet(
      BuildContext context, ValueNotifier<FutureGet> futureGet) {
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
                    futureGet.value =
                        () => apiClient.getUserBookmarkNovel(id, 'public');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(I18n.of(context).private),
                  onTap: () {
                    futureGet.value =
                        () => apiClient.getUserBookmarkNovel(id, 'private');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
