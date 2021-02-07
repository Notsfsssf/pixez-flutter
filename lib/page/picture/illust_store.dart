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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/error_message.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

part 'illust_store.g.dart';

class IllustStore = _IllustStoreBase with _$IllustStore;

abstract class _IllustStoreBase with Store {
  final int id;
  final ApiClient client = apiClient;
  @observable
  Illusts illusts;
  @observable
  bool isBookmark;
  @observable
  String errorMessage;

  @observable
  int state = 0;

  void dispose() {
    if (illusts != null) {
      if (illusts.pageCount != 1) {
        for (var i in illusts.metaPages) {
          if (illusts.metaPages.indexOf(i) == 0) continue;
          final provider = ExtendedNetworkImageProvider(
              userSetting.pictureQuality == 0
                  ? i.imageUrls.medium
                  : i.imageUrls.large);
          provider?.evict();
        }
      }
    }
  }

  _IllustStoreBase(this.id, this.illusts) {
    isBookmark = illusts?.isBookmarked ?? false;
    state = illusts?.isBookmarked ?? isBookmark ? 2 : 0;
  }

  @action
  fetch() async {
    errorMessage = null;
    if (illusts == null) {
      try {
        Response response = await client.getIllustDetail(id);
        final result = Illusts.fromJson(response.data['illust']);
        illusts = result;
        isBookmark = illusts.isBookmarked;
        state = illusts?.isBookmarked ?? isBookmark ? 2 : 0;
      } on DioError catch (e) {
        if (e.response != null) {
          if (e.response.statusCode == HttpStatus.notFound) {
            errorMessage = '404 Not Found';
            return;
          }
          try {
            errorMessage = ErrorMessage.fromJson(e.response.data).error.message;
          } catch (e) {
            errorMessage = e.toString();
          }
        } else {
          errorMessage = e.toString();
        }
      }
    }
    if (illusts != null) historyStore.insert(illusts);
  }

  @action
  Future<bool> star({String restrict = 'public', List<String> tags}) async {
    state = 1;
    if (!illusts.isBookmarked) {
      try {
        await ApiClient(isBookmark: true)
            .postLikeIllust(illusts.id, restrict, tags);
        illusts.isBookmarked = true;
        isBookmark = true;
        state = 2;
        return true;
      } catch (e) {}
    } else {
      try {
        await ApiClient(isBookmark: true).postUnLikeIllust(illusts.id);
        illusts.isBookmarked = false;
        isBookmark = false;
        state = 0;
        return false;
      } catch (e) {}
    }
    state = illusts.isBookmarked ? 2 : 0;
    return illusts.isBookmarked;
  }
}
