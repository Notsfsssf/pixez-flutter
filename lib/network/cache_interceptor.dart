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

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:quiver/collection.dart';

class CacheInterceptor extends Interceptor {
  CacheInterceptor();

  LruMap _cache = LruMap<Uri, Response>(maximumSize: 10);

  final String RELATED_LINK = "/v2/illust/related";

  final String TAG_RECOMMEND_LINK = "/v1/trending-tags/illust";

  @override
  Future onRequest(RequestOptions options) async {
    final extra = options.extra["refresh"];
    if (extra == null) return options;
    Response response;
    if (extra == true) {
      return options;
    } else if ((response = _cache[options.uri]) != null) {
      return response;
    }
  }

  @override
  Future onResponse(Response response) async {
    if (response.request.uri.path.contains(RELATED_LINK) ||
        response.request.uri.path.contains(TAG_RECOMMEND_LINK)) {
      _cache[response.request.uri] = response;
    }
  }

  @override
  Future onError(DioError e) async {}
}
