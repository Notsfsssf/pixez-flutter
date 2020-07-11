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
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/follow/follow_store.dart';
import 'package:pixez/page/preview/preview_page.dart';

class FollowList extends StatefulWidget {
  final int id;

  const FollowList({Key key, this.id}) : super(key: key);

  @override
  _FollowListState createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  FollowStore followStore;
  EasyRefreshController _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    followStore = FollowStore(apiClient, widget.id, _controller);
    super.initState();
  }

  String restrict = 'public';

  Widget _buildBody() {
    if (accountStore.now != null) {
      if (int.parse(accountStore.now.userId) == widget.id) {
        return followStore.userList.isNotEmpty
            ? ListView.builder(
                itemCount: followStore.userList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(Icons.list),
                          onPressed: () {
                            showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                context: context,
                                builder: (context1) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title:
                                                Text(I18n.of(context).public),
                                            onTap: () {
                                              Navigator.of(context1).pop();
                                              followStore.fetch('public');
                                              restrict = 'public';
                                            },
                                          ),
                                          ListTile(
                                            title:
                                                Text(I18n.of(context).private),
                                            onTap: () {
                                              Navigator.of(context1).pop();
                                              followStore.fetch('private');
                                              restrict = 'private';
                                            },
                                          ),
                                        ],
                                      ),
                                    ));
                          }),
                    );
                  }
                  UserPreviews user = followStore.userList[index - 1];
                  return PainterCard(
                    user: user,
                  );
                },
              )
            : Container();
      } else {
        return followStore.userList.isNotEmpty
            ? ListView.builder(
                itemCount: followStore.userList.length,
                itemBuilder: (BuildContext context, int index) {
                  UserPreviews user = followStore.userList[index];
                  return PainterCard(
                    user: user,
                  );
                },
              )
            : Container();
      }
    }
    return LoginInFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return EasyRefresh(
          header: MaterialHeader(),
          enableControlFinishLoad: true,
          enableControlFinishRefresh: true,
          controller: _controller,
          firstRefresh: true,
          onRefresh: () {
            return followStore.fetch(restrict);
          },
          onLoad: () {
            return followStore.fetchNext();
          },
          child: _buildBody(),
        );
      },
    );
  }
}
