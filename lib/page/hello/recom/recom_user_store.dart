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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';
part 'recom_user_store.g.dart';

class RecomUserStore = _RecomUserStoreBase with _$RecomUserStore;

abstract class _RecomUserStoreBase with Store {
  String? nextUrl;
  ObservableList<UserPreviews> users = ObservableList();
  EasyRefreshController? controller;

  _RecomUserStoreBase(this.controller);

  @action
  fetch() async {
    nextUrl = null;
    try {
      final result = await apiClient.getUserRecommended();
      final response = UserPreviewsResponse.fromJson(result.data);
      nextUrl = response.next_url;
      users.clear();
      users.addAll(response.user_previews);
      controller?.finishRefresh(IndicatorResult.success);
    } catch (e) {
      controller?.finishRefresh(IndicatorResult.fail);
    }
  }

  @action
  next() async {
    try {
      if (nextUrl != null && nextUrl!.isNotEmpty) {
        final result = await apiClient.getNext(nextUrl!);
        final response = UserPreviewsResponse.fromJson(result.data);
        nextUrl = response.next_url;
        users.addAll(response.user_previews);
        controller?.finishLoad(IndicatorResult.success);
      } else {
        controller?.finishLoad(IndicatorResult.noMore);
      }
    } catch (e) {
      controller?.finishLoad(IndicatorResult.fail);
    }
  }
}
