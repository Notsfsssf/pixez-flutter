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

import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
part 'novel_lighting_store.g.dart';

class NovelLightingStore = _NovelLightingStoreBase with _$NovelLightingStore;

abstract class _NovelLightingStoreBase with Store {
  FutureGet source;
  final ApiClient _client = apiClient;
  final RefreshController _controller;
  _NovelLightingStoreBase(this.source, this._controller);
  String nextUrl;
  ObservableList<Novel> novels = ObservableList();
  @action
  Future<Void> fetch() async {
    nextUrl = null;
    _controller?.headerMode?.value = RefreshStatus.idle;
    try {
      Response response = await source();
      NovelRecomResponse novelRecomResponse =
          NovelRecomResponse.fromJson(response.data);
      nextUrl = novelRecomResponse.nextUrl;
      final novels = novelRecomResponse.novels;
      this.novels.clear();
      this.novels.addAll(novels);
      _controller.refreshCompleted();
    } catch (e) {
      _controller.refreshFailed();
    }
  }

  @action
  Future<Void> next() async {
    if (nextUrl != null && nextUrl.isNotEmpty) {
      try {
        Response response = await _client.getNext(nextUrl);
        NovelRecomResponse novelRecomResponse =
            NovelRecomResponse.fromJson(response.data);
        nextUrl = novelRecomResponse.nextUrl;
        final novel = novelRecomResponse.novels;
        novels.addAll(novel);
        _controller.loadComplete();
      } catch (e) {
        _controller.loadFailed();
      }
    } else {
      _controller.loadNoData();
    }
  }
}
