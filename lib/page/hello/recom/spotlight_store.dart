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

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'spotlight_store.g.dart';

class SpotlightStore = _SpotlightStoreBase with _$SpotlightStore;

abstract class _SpotlightStoreBase with Store {
  final ApiClient client = apiClient;
  ObservableList<SpotlightArticle> articles = ObservableList();
  String? nextUrl;
  final RefreshController? _controller;

  _SpotlightStoreBase(this._controller);

  @action
  Future<void> fetch() async {
    nextUrl = null;
    if (_controller != null) {
      _controller!.headerMode?.value = RefreshStatus.idle;
      _controller!.footerMode?.value = LoadStatus.idle;
    }
    try {
      Response response = await client.getSpotlightArticles("all");
      final result = SpotlightResponse.fromJson(response.data);
      articles.clear();
      articles.addAll(result.spotlightArticles);
      nextUrl = result.nextUrl;
      _controller?.refreshCompleted();
    } catch (e) {
      _controller?.refreshFailed();
    }
  }

  @action
  next() async {
    if (nextUrl != null && nextUrl!.isNotEmpty) {
      try {
        Response response = await client.getNext(nextUrl!);
        final results = SpotlightResponse.fromJson(response.data);
        nextUrl = results.nextUrl;
        articles.addAll(results.spotlightArticles);
        _controller?.loadComplete();
      } catch (e) {
        _controller?.loadFailed();
      }
    } else {
      _controller?.loadNoData();
    }
  }
}
