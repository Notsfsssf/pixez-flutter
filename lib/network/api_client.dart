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

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust_bookmark_tags_response.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/network/refresh_token_interceptor.dart';
import 'package:rhttp/rhttp.dart' as r;

final ApiClient apiClient = ApiClient();

class ApiClient {
  late Dio httpClient;

  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  static String BASE_API_URL_HOST = 'app-api.pixiv.net';
  static String BASE_IMAGE_HOST = ImageHost;
  static String Accept_Language = "zh-CN";

  String getIsoDate() {
    DateTime dateTime = new DateTime.now();
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'");
    return dateFormat.format(dateTime);
  }

  static String getHash(String string) {
    var content = new Utf8Encoder().convert(string);
    var digest = md5.convert(content);
    return digest.toString();
  }

  final options = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    maxStale: const Duration(days: 1),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  Future<Dio> createDioClient() async {
    final compatibleClient = await r.RhttpCompatibleClient.create(
        settings: userSetting.disableBypassSni
            ? null
            : r.ClientSettings(
                tlsSettings:
                    r.TlsSettings(verifyCertificates: false, sni: false),
                dnsSettings: r.DnsSettings.dynamic(
                  resolver: (host) async {
                    final ip = Hoster.api();
                    return [ip];
                  },
                ),
              ));
    httpClient.httpClientAdapter = ConversionLayerAdapter(compatibleClient);
    if (Platform.isAndroid) {
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        var headers = httpClient.options.headers;
        headers['User-Agent'] =
            "PixivAndroidApp/5.0.166 (Android ${androidInfo.version.release}; ${androidInfo.model})";
        headers['App-OS-Version'] = "Android ${androidInfo.version.release}";
      } catch (e) {}
    }
    return httpClient;
  }

  static Future<ConversionLayerAdapter> createCompatibleClient() async {
    final compatibleClient = await r.RhttpCompatibleClient.create(
        settings: userSetting.disableBypassSni
            ? null
            : r.ClientSettings(
                tlsSettings:
                    r.TlsSettings(verifyCertificates: false, sni: false),
                dnsSettings: r.DnsSettings.dynamic(
                  resolver: (host) async {
                    if (host == 'i.pximg.net') {
                      return [Hoster.iPximgNet()];
                    }
                    if (host == 's.pximg.net') {
                      return [Hoster.sPximgNet()];
                    }
                    return await InternetAddress.lookup(host)
                        .then((value) => value.map((e) => e.address).toList());
                  },
                )));
    return ConversionLayerAdapter(compatibleClient);
  }

  ApiClient({bool isBookmark = false}) {
    String time = getIsoDate();
    httpClient =
        Dio(BaseOptions(baseUrl: 'https://${BASE_API_URL_HOST}', headers: {
      "X-Client-Time": time,
      "X-Client-Hash": getHash(time + hashSalt),
      "User-Agent": "PixivAndroidApp/5.0.155 (Android 10.0; Pixel C)",
      HttpHeaders.acceptLanguageHeader: Accept_Language,
      "App-OS": "Android",
      "App-OS-Version": "Android 10.0",
      "App-Version": "5.0.166",
      HttpHeaders.hostHeader: BASE_API_URL_HOST
    }))
          ..interceptors.add(DioCacheInterceptor(options: options))
          ..interceptors.add(RefreshTokenInterceptor());
    if (kDebugMode) {
      httpClient.interceptors.add(LogInterceptor(
          responseBody: true, responseHeader: true, requestBody: true));
    }
  }

  Future<Response> getUserBookmarkNovel(int user_id, String restrict) async {
    return httpClient.get('/v1/user/bookmarks/novel',
        queryParameters:
            notNullMap({"user_id": user_id, "restrict": restrict}));
  }

  Future<Response> postNovelBookmarkAdd(int novel_id, String restrict) async {
    return httpClient.post('/v2/novel/bookmark/add',
        data: notNullMap({"novel_id": novel_id, "restrict": restrict}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> postNovelBookmarkDelete(int novel_id) async {
    return httpClient.post('/v1/novel/bookmark/delete',
        data: notNullMap({"novel_id": novel_id}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> getNovelRanking(String mode, date) async {
    return httpClient.get("/v1/novel/ranking?filter=for_android",
        queryParameters: notNullMap({"mode": mode, "date": date}));
  }

  Future<Response> getNovelText(int novel_id) async {
    return httpClient.get("/v1/novel/text",
        queryParameters: notNullMap({"novel_id": novel_id}));
  }

  Future<Response> webviewNovel(int novel_id) async {
    return httpClient.get("/webview/v2/novel",
        queryParameters: notNullMap({"id": novel_id}));
  }

  Future<Response> getNovelDetail(int id) async {
    return httpClient.get("/v2/novel/detail",
        queryParameters: notNullMap({"novel_id": id}));
  }

  Future<Response> getNovelFollow(String restrict) {
    return httpClient.get(
      "/v1/novel/follow",
      queryParameters: {"restrict": restrict},
    );
  }

  Future<Response> getNovelRecommended() async {
    return httpClient.get(
        "/v1/novel/recommended?include_privacy_policy=true&filter=for_android&include_ranking_novels=true");
  }

  Future<Response> getRecommend() async {
    return httpClient.get(
        "/v1/illust/recommended?filter=for_ios&include_ranking_label=true");
  }

  Future<Response> getMangaRecommend() async {
    return httpClient
        .get("/v1/manga/recommended?filter=for_ios&include_ranking_label=true");
  }

  Future<Response> getUserRecommended({bool force = false}) async {
    return httpClient.get("/v1/user/recommended?filter=for_android",
        options: options
            .copyWith(
                policy: force ? CachePolicy.refresh : null,
                maxStale: Nullable(Duration(minutes: 2)))
            .toOptions());
  }

  Future<Response> getUser(int id) async {
    return httpClient.get("/v1/user/detail?filter=for_android",
        queryParameters: {"user_id": id});
  }

  Future<Response> postUser(int? a, String? b) async {
    return httpClient.post("/v1/user",
        data: {"a": a, "b": b}..removeWhere((k, v) => v == null));
  }

  Map<String, dynamic> notNullMap(Map<String, dynamic> map) {
    return map..removeWhere((k, v) => v == null);
  }

  Future<Response> postLikeIllust(
      int illust_id, String restrict, List<String>? tags) async {
    if (tags != null && tags.isNotEmpty) {
      String tagString = tags.first;
      for (var i = 1; i < tags.length; i++) {
        tagString = tagString + ' ' + tags[i].trim();
      }
      return httpClient.post("/v2/illust/bookmark/add",
          data: notNullMap({
            "illust_id": illust_id,
            "restrict": restrict,
            "tags[]": tagString
            //null toString =="null"
          }),
          options: Options(contentType: Headers.formUrlEncodedContentType));
    } else
      return httpClient.post("/v2/illust/bookmark/add",
          data: notNullMap({
            "illust_id": illust_id,
            "restrict": restrict,
          }),
          options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> postUnLikeIllust(int illust_id) async {
    return httpClient.post("/v1/illust/bookmark/delete",
        data: {"illust_id": illust_id},
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> getUnlikeIllust(int illust_id) async {
    return httpClient.get("/v1/illust/bookmark/delete?illust_id=$illust_id");
  }

  Future<Response> getNext(String url) async {
    var a = httpClient.options.baseUrl;
    String finalUrl = url.replaceAll(
        "app-api.pixiv.net", a.replaceAll(a, a.replaceFirst("https://", "")));
    return httpClient.get(finalUrl,
        options: options.copyWith(policy: CachePolicy.refresh).toOptions());
  }

  Future<Response> getIllustRanking(String mode, date,
      {bool force = false}) async {
    return httpClient.get(
      "/v1/illust/ranking?filter=for_android",
      queryParameters: notNullMap({
        "mode": mode,
        "date": date,
      }),
      options: options.copyWith(policy: CachePolicy.refresh).toOptions(),
    );
  }

  Future<Response> getUserIllusts(int user_id, String type) async {
    return httpClient.get("/v1/user/illusts?filter=for_android",
        queryParameters: {"user_id": user_id, "type": type});
  }

  Future<Response> getUserIllustsOffset(
      int user_id, String type, int? offset) async {
    return httpClient.get("/v1/user/illusts?filter=for_android",
        queryParameters:
            notNullMap({"user_id": user_id, "type": type, "offset": offset}));
  }

  Future<Response> getBookmarksIllustsOffset(
      int user_id, String restrict, String? tag, int? offset) async {
    return httpClient.get("/v1/user/bookmarks/illust",
        queryParameters: notNullMap({
          "user_id": user_id,
          "restrict": restrict,
          "tag": tag,
          "offset": offset
        }));
  }

  Future<Response> getUserNovels(int user_id) async {
    return httpClient.get("/v1/user/novels?filter=for_android",
        queryParameters: {"user_id": user_id});
  }

  Future<Response> getBookmarksIllust(
      int user_id, String restrict, String? tag) async {
    return httpClient.get("/v1/user/bookmarks/illust",
        queryParameters:
            notNullMap({"user_id": user_id, "restrict": restrict, "tag": tag}));
  }

  Future<Response> postUnFollowUser(int user_id) {
    return httpClient.post("/v1/user/follow/delete",
        data: {"user_id": user_id},
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> getFollowUser(int userId, String restrict) {
    return httpClient.get(
      "/v1/user/follower?filter=for_android",
      queryParameters: {"restrict": restrict, "user_id": userId},
    );
  }

  Future<Response> getFollowIllusts(String restrict, {bool force = false}) {
    return httpClient.get("/v2/illust/follow",
        queryParameters: {"restrict": restrict},
        options: options
            .copyWith(
                policy: force ? CachePolicy.refresh : null,
                maxStale: Nullable(Duration(minutes: 2)))
            .toOptions());
  }

  Future<Response> getUserFollowing(int user_id, String restrict) {
    return httpClient.get(
      "/v1/user/following?filter=for_android",
      queryParameters: {"restrict": restrict, "user_id": user_id},
    );
  }

  Future<AutoWords> getSearchAutoCompleteKeywords(String word) async {
    final response = await httpClient.get(
      "/v2/search/autocomplete?merge_plain_keyword_results=true",
      queryParameters: {"word": word},
    );
    return AutoWords.fromJson(response.data);
  }

  Future<Response> getIllustTrendTags({bool force = false}) async {
    return httpClient.get(
      "/v1/trending-tags/illust?filter=for_android",
      options: options
          .copyWith(
              policy: force ? CachePolicy.refresh : null,
              maxStale: Nullable(Duration(hours: 1)))
          .toOptions(),
    );
  }

  Future<Response> getNovelTrendTags({bool force = false}) async {
    return httpClient.get(
      "/v1/trending-tags/novel?filter=for_android",
      options: options
          .copyWith(
              policy: force ? CachePolicy.refresh : null,
              maxStale: Nullable(Duration(hours: 1)))
          .toOptions(),
    );
  }

  String? getFormatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    } else
      return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  Future<Response> getSearchIllust(String word,
      {String? sort,
      String? search_target,
      DateTime? start_date,
      DateTime? end_date,
      List<int>? bookmark_num,
      int? search_ai_type}) async {
    final bookmark_num_min = bookmark_num?.elementAtOrNull(0);
    final bookmark_num_max = bookmark_num?.elementAtOrNull(1);
    return httpClient.get("/v1/search/illust",
        queryParameters: notNullMap({
          "filter": Platform.isAndroid ? "for_android" : "for_ios",
          "merge_plain_keyword_results": true,
          "sort": sort,
          "search_ai_type": search_ai_type,
          "search_target": search_target,
          "start_date": getFormatDate(start_date),
          "end_date": getFormatDate(end_date),
          "bookmark_num_min": bookmark_num_min,
          "bookmark_num_max": bookmark_num_max,
          "word": word
        }));
  }

  Future<Response> getSearchNovel(String word,
      {String? sort,
      String? search_target,
      DateTime? start_date,
      DateTime? end_date,
      int? bookmark_num}) async {
    return httpClient.get(
        "/v1/search/novel?filter=for_android&merge_plain_keyword_results=true",
        queryParameters: notNullMap({
          "sort": sort,
          "search_target": search_target,
          "start_date": getFormatDate(start_date),
          "end_date": getFormatDate(end_date),
          "bookmark_num": bookmark_num,
          "word": word
        }));
  }

  Future<Response> getSearchUser(String word) async {
    return httpClient.get("/v1/search/user?filter=for_android",
        queryParameters: {"word": word});
  }

  Future<Response> getSearchAutocomplete(String word) async =>
      httpClient.get("/v2/search/autocomplete?merge_plain_keyword_results=true",
          queryParameters: notNullMap({"word": word}));

  Future<Response> getIllustRelated(int illust_id,
          {bool force = false}) async =>
      httpClient.get("/v2/illust/related?filter=for_android",
          options: options
              .copyWith(
                  policy: force ? CachePolicy.refresh : null,
                  maxStale: Nullable(Duration(days: 1)))
              .toOptions(),
          queryParameters: notNullMap({"illust_id": illust_id}));

  Future<Response> getIllustBookmarkDetail(int illust_id) async =>
      httpClient.get("/v2/illust/bookmark/detail",
          queryParameters: notNullMap({"illust_id": illust_id}));

  Future<Response> postUnfollowUser(int user_id) async =>
      httpClient.post("/v1/user/follow/delete",
          data: notNullMap({"user_id": user_id}),
          options: Options(contentType: Headers.formUrlEncodedContentType));

  Future<Response> postFollowUser(int user_id, String restrict) {
    return httpClient.post("/v1/user/follow/add",
        data: {"user_id": user_id, "restrict": restrict},
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> getIllustDetail(int illust_id) {
    return httpClient.get("/v1/illust/detail?filter=for_android",
        queryParameters: {"illust_id": illust_id});
  }

  Future<Response> getSpotlightArticles(String category, {bool force = false}) {
    return httpClient.get(
      "/v1/spotlight/articles?filter=for_android",
      queryParameters: {"category": category},
      options: options
          .copyWith(
              policy: force ? CachePolicy.refresh : null,
              maxStale: Nullable(Duration(hours: 23)))
          .toOptions(),
    );
  }

  Future<Response> getIllustComments(int illust_id, {bool force = false}) {
    return httpClient.get("/v3/illust/comments",
        queryParameters: {"illust_id": illust_id},
        options: options
            .copyWith(
                policy: force ? CachePolicy.refresh : null,
                maxStale: Nullable(Duration(minutes: 2)))
            .toOptions());
  }

  Future<Response> getNovelComments(int illust_id, {bool force = false}) {
    return httpClient.get("/v3/novel/comments",
        queryParameters: {"novel_id": illust_id},
        options: options
            .copyWith(
                policy: force ? CachePolicy.refresh : null,
                maxStale: Nullable(Duration(minutes: 2)))
            .toOptions());
  }

  Future<Response> getIllustCommentsReplies(int comment_id) {
    return httpClient.get("/v2/illust/comment/replies",
        queryParameters: {"comment_id": comment_id});
  }

  Future<Response> getNovelCommentsReplies(int comment_id) {
    return httpClient.get("/v2/novel/comment/replies",
        queryParameters: {"comment_id": comment_id});
  }

  Future<Response> postIllustComment(int illust_id, String comment,
      {int? parent_comment_id}) {
    return httpClient.post("/v1/illust/comment/add",
        data: notNullMap({
          "illust_id": illust_id,
          "comment": comment,
          "parent_comment_id": parent_comment_id
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> postNovelComment(int illust_id, String comment,
      {int? parent_comment_id}) {
    return httpClient.post("/v1/novel/comment/add",
        data: notNullMap({
          "novel_id": illust_id,
          "comment": comment,
          "parent_comment_id": parent_comment_id
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<UgoiraMetadataResponse> getUgoiraMetadata(int illust_id) async {
    final result = await httpClient.get(
      "/v1/ugoira/metadata",
      queryParameters: notNullMap({"illust_id": illust_id}),
    );
    return UgoiraMetadataResponse.fromJson(result.data);
  }

  Future<IllustBookmarkTagsResponse> getUserBookmarkTagsIllust(int user_id,
      {String restrict = 'public'}) async {
    final result = await httpClient.get(
      "/v1/user/bookmark-tags/illust",
      queryParameters: notNullMap({"user_id": user_id, "restrict": restrict}),
    );
    return IllustBookmarkTagsResponse.fromJson(result.data);
  }

  Future<Response> walkthroughIllusts() async {
    final result = await httpClient.get('/v1/walkthrough/illusts');
    return result;
  }

  Future<Response> getPopularPreview(String keyword) async {
    String a = httpClient.options.baseUrl;
    String previewUrl =
        '${a}/v1/search/popular-preview/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=${keyword}&search_target=partial_match_for_tags';
    final result = await httpClient.get(previewUrl);
    return result;
  }

  Future<Response> getUserAISettings() async {
    final result = await httpClient.get('/v1/user/ai-show-settings');
    return result;
  }

  Future<Response> postUserAIShowSettings(bool show) async {
    return httpClient.post('/v1/user/ai-show-settings/edit',
        data: notNullMap({"show_ai": show}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> novelSeries(int id) async {
    return httpClient.get('/v2/novel/series', queryParameters: {
      'series_id': id,
    });
  }

  Future<Response> nextNovelSeries(String id) async {
    return httpClient.get('/v2/novel/series', queryParameters: {
      'series_id': id,
    });
  }

  Future<Response> watchListNovelAdd(String seriesId) async {
    return httpClient.post('/v1/watchlist/novel/add',
        data: notNullMap({"series_id": seriesId}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> watchListNovelDelete(String seriesId) async {
    return httpClient.post('/v1/watchlist/novel/delete',
        data: notNullMap({"series_id": seriesId}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  // /v1/watchlist/manga
  Future<Response> watchListManga() async {
    return httpClient.get('/v1/watchlist/manga');
  }

  // /v1/illust/series?filter=for_ios&illust_series_id=
  Future<Response> illustSeries(int illustSeriesId) async {
    return httpClient.get('/v1/illust/series', queryParameters: {
      'illust_series_id': illustSeriesId,
    });
  }

  // watchlist/manga/add
  Future<Response> watchListMangaAdd(int seriesId) async {
    return httpClient.post('/v1/watchlist/manga/add',
        data: notNullMap({"series_id": seriesId}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  // watchlist/manga/delete
  Future<Response> watchListMangaDelete(int seriesId) async {
    return httpClient.post('/v1/watchlist/manga/delete',
        data: notNullMap({"series_id": seriesId}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  // v1/illust-series/illust
  Future<Response> illustSeriesIllust(int illustId) async {
    return httpClient.get('/v1/illust-series/illust', queryParameters: {
      'illust_id': illustId,
    });
  }

  // /v1/user/restricted-mode-settings
  Future<Response> userRestrictedModeSettings(
      bool isRestrictedModeEnabled) async {
    return httpClient.post('/v1/user/restricted-mode-settings',
        data:
            notNullMap({"is_restricted_mode_enabled": isRestrictedModeEnabled}),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  // /v1/user/restricted-mode-settings
  Future<bool> userRestrictedModeSettingsGet() async {
    final res = await httpClient.get('/v1/user/restricted-mode-settings');
    return res.data['is_restricted_mode_enabled'] as bool;
  }
}
