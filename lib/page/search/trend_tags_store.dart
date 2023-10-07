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
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/network/api_client.dart';

part 'trend_tags_store.g.dart';

class TrendTagsStore = _TrendTagsStoreBase with _$TrendTagsStore;

abstract class _TrendTagsStoreBase with Store {
  @observable
  ObservableList<TrendTags> trendTags = ObservableList();

  _TrendTagsStoreBase();

  @action
  fetch() async {
    try {
      Response response = await apiClient.getIllustTrendTags();
      TrendingTag trendingTag = TrendingTag.fromJson(response.data);
      trendTags.clear();
      trendTags.addAll(trendingTag.trend_tags);
    } catch (e) {
      print(e);
    }
  }
}
