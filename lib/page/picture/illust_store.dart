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
      } on DioError catch (e) {
        if (e.response != null) {
          if (e.response.statusCode == HttpStatus.notFound) {
            errorMessage = '404 Not Found';
            return;
          }
          errorMessage = ErrorMessage.fromJson(e.response.data).error.message;
        } else {
          errorMessage = e.toString();
        }
      }
    }
    if (illusts != null) historyStore.insert(illusts);
  }

  @action
  Future<bool> star({String restrict = 'public', List<String> tags}) async {
    if (!illusts.isBookmarked) {
      try {
        Response response = await ApiClient(isBookmark: true)
            .postLikeIllust(illusts.id, restrict, tags);
        illusts.isBookmarked = true;
        isBookmark = true;
        return true;
      } catch (e) {}
    } else {
      try {
        Response response =
            await ApiClient(isBookmark: true).postUnLikeIllust(illusts.id);
        illusts.isBookmarked = false;
        isBookmark = false;
        return false;
      } catch (e) {}
    }
    return null;
  }
}
