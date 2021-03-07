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
import 'package:pixez/er/leader.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';
import 'package:pixez/page/novel/user/novel_user_page.dart';

class NovelNewPage extends StatefulWidget {
  @override
  _NovelNewPageState createState() => _NovelNewPageState();
}

class _NovelNewPageState extends State<NovelNewPage> {
  late FutureGet futureGet;

  @override
  void initState() {
    futureGet = () => apiClient.getNovelFollow('public');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AppBar(
            actions: [
              IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    if (accountStore.now != null)
                      Leader.push(
                          context,
                          NovelUserPage(
                            id: int.parse(accountStore.now!.userId),
                          ));
                  })
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.0))),
                      builder: (context) {
                        return SafeArea(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(I18n.of(context).public),
                              onTap: () {
                                setState(() {
                                  futureGet =
                                      () => apiClient.getNovelFollow('public');
                                });
                              },
                            ),
                            ListTile(
                                title: Text(I18n.of(context).private),
                                onTap: () {
                                  setState(() {
                                    futureGet = () =>
                                        apiClient.getNovelFollow('private');
                                  });
                                }),
                          ],
                        ));
                      });
                }),
          ),
          Expanded(child: NovelLightingList(futureGet: futureGet)),
        ],
      ),
    );
  }
}
