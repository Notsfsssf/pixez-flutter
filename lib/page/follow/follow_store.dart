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

import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';

part 'follow_store.g.dart';

class FollowStore = _FollowStoreBase with _$FollowStore;

abstract class _FollowStoreBase with Store {
  final ApiClient client;

  final int id;
  final EasyRefreshController _controller;
  ObservableList<UserPreviews> userList = ObservableList();

  _FollowStoreBase(this.client, this.id, this._controller);

  String nextUrl;

  @action
  Future<void> fetch(String restrict) async {
    try {
      final response = await client.getUserFollowing(id, restrict);
      UserPreviewsResponse userPreviews =
          UserPreviewsResponse.fromJson(response.data);
      nextUrl = userPreviews.next_url;
      userList.clear();
      userList.addAll(userPreviews.user_previews);
      _controller.finishRefresh(success: true);
    } catch (e) {
      _controller.finishRefresh(success: false);
    }
  }

  @action
  Future<void> fetchNext() async {
    if (nextUrl != null && nextUrl.isNotEmpty) {
      try {
        final response = await client.getNext(nextUrl);
        UserPreviewsResponse userPreviews =
            UserPreviewsResponse.fromJson(response.data);
        nextUrl = userPreviews.next_url;
        userList.addAll(userPreviews.user_previews);
        _controller.finishLoad();
      } catch (e) {
        _controller.finishLoad(success: false);
      }
    } else {
      _controller.finishLoad(success: true, noMore: true);
    }
  }
}
