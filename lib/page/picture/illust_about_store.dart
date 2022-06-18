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
import 'package:pixez/exts.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'illust_about_store.g.dart';

class IllustAboutStore = _IllustAboutStoreBase with _$IllustAboutStore;

abstract class _IllustAboutStoreBase with Store {
  final int id;
  bool fetching = false;
  RefreshController? refreshController;

  _IllustAboutStoreBase(this.id, {this.refreshController});

  @observable
  String? errorMessage;

  String? _nextUrl;

  ObservableList<Illusts> illusts = ObservableList();

  @action
  fetch() async {
    if (fetching) return;
    fetching = true;
    errorMessage = null;
    try {
      Response response = await apiClient.getIllustRelated(id);
      Recommend recommend = Recommend.fromJson(response.data);
      _nextUrl = recommend.nextUrl;
      illusts.clear();
      illusts.addAll(recommend.illusts.takeWhile((value) => !value.hateByUser()));
    } catch (e) {
      errorMessage = e.toString();
    }
    fetching = false;
  }

  @action
  next() async {
    try {
      Response response = _nextUrl == null || _nextUrl!.isEmpty
          ? await apiClient.getIllustRelated(id)
          : await apiClient.getNext(_nextUrl!);
      Recommend recommend = Recommend.fromJson(response.data);
      _nextUrl = recommend.nextUrl;
      illusts.addAll(recommend.illusts.takeWhile((value) => !value.hateByUser()));
      if (_nextUrl == null || _nextUrl!.isEmpty || recommend.illusts.isEmpty) {
        refreshController?.loadNoData();
      } else {
        refreshController?.loadComplete();
      }
    } catch (e) {
      refreshController?.loadFailed();
    }
  }
}
