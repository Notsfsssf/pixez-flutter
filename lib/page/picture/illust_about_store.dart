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
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

part 'illust_about_store.g.dart';

class IllustAboutStore = _IllustAboutStoreBase with _$IllustAboutStore;

abstract class _IllustAboutStoreBase with Store {
  final int id;
  bool fetching = false;
  EasyRefreshController? refreshController;

  _IllustAboutStoreBase(this.id, this.refreshController);

  @observable
  String? errorMessage;

  String? _nextUrl;

  ObservableList<Illusts> illusts = ObservableList();

  @action
  Future<bool> next() async {
    if (fetching) {
      return false;
    }
    try {
      fetching = true;
      Response response = _nextUrl == null || _nextUrl!.isEmpty
          ? await apiClient.getIllustRelated(id)
          : await apiClient.getNext(_nextUrl!);
      Recommend recommend = Recommend.fromJson(response.data);
      _nextUrl = recommend.nextUrl;
      final resultIllusts = recommend.illusts;
      if (resultIllusts.isEmpty) {
        refreshController?.finishLoad(IndicatorResult.noMore);
        return true;
      }
      illusts.addAll(resultIllusts.takeWhile((value) => !value.hateByUser()));
      if (_nextUrl == null || _nextUrl!.isEmpty || recommend.illusts.isEmpty) {
        refreshController?.finishLoad(IndicatorResult.noMore);
      } else {
        refreshController?.finishLoad(IndicatorResult.success);
      }
      debugPrint('nextUrl: $_nextUrl');
      return true;
    } catch (e) {
      refreshController?.finishLoad(IndicatorResult.fail);
      debugPrint('failed to load next: $e');
      return false;
    } finally {
      fetching = false;
    }
  }
}
