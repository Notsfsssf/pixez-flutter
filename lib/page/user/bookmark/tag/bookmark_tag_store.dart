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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust_bookmark_tags_response.dart';
import 'package:pixez/network/api_client.dart';
part 'bookmark_tag_store.g.dart';

class BookMarkTagStore = _BookMarkTagStoreBase with _$BookMarkTagStore;

abstract class _BookMarkTagStoreBase with Store {
  ObservableList<BookmarkTag> bookmarkTags = ObservableList();
  final EasyRefreshController _controller;
  final int id;
  String? nextUrl;
  _BookMarkTagStoreBase(this.id, this._controller);
  @action
  fetch(String restrict) async {
    nextUrl = null;
    try {
      var result =
          await apiClient.getUserBookmarkTagsIllust(id, restrict: restrict);
      nextUrl = result.nextUrl;
      bookmarkTags.clear();
      bookmarkTags.addAll(result.bookmarkTags);
      _controller.finishRefresh(IndicatorResult.success);
    } catch (e) {
      _controller.finishRefresh(IndicatorResult.fail);
    }
  }

  @action
  next() async {
    if (nextUrl != null && nextUrl!.isNotEmpty) {
      try {
        final result = await apiClient.getNext(nextUrl!);
        var r = IllustBookmarkTagsResponse.fromJson(result.data);
        nextUrl = r.nextUrl;
        bookmarkTags.addAll(r.bookmarkTags);
        _controller.finishLoad(
            nextUrl == null ? IndicatorResult.noMore : IndicatorResult.success);
      } catch (e) {
        _controller.finishLoad(IndicatorResult.fail);
      }
    } else {
      _controller.finishLoad(IndicatorResult.noMore);
    }
  }
}
