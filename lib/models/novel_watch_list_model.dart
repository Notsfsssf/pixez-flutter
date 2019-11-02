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

import 'package:json_annotation/json_annotation.dart';

part 'novel_watch_list_model.g.dart';

class NovelWatchListModel {
  final List<NovelSeriesModel> series;
  final String? nextUrl;

  NovelWatchListModel({required this.series, required this.nextUrl});

  factory NovelWatchListModel.fromJson(Map<String, dynamic> json) =>
      NovelWatchListModel(
        series: (json['series'] as List<dynamic>)
            .map((e) => tryParse(e))
            .whereType<NovelSeriesModel>()
            .toList(),
        nextUrl: json['next_url'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'series': series,
    'next_url': nextUrl,
  };

  static NovelSeriesModel? tryParse(e) {
    if (e is Map<String, dynamic>) {
      try {
        return NovelSeriesModel.fromJson(e);
      } catch (e) {}
    }
    return null;
  }
}

@JsonSerializable()
class NovelSeriesModel {
  final int id;
  final String title;
  final String? url;
  @JsonKey(name: 'mask_text')
  final String? maskText;
  @JsonKey(name: 'published_content_count')
  final int publishedContentCount;
  @JsonKey(name: 'last_published_content_datetime')
  final String lastPublishedContentDatetime;
  @JsonKey(name: 'latest_content_id')
  final int latestContentId;
  final NovelSeriesUser? user;

  NovelSeriesModel({
    required this.id,
    required this.title,
    required this.url,
    required this.maskText,
    required this.publishedContentCount,
    required this.lastPublishedContentDatetime,
    required this.latestContentId,
    required this.user,
  });

  factory NovelSeriesModel.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$NovelSeriesModelToJson(this);
}

@JsonSerializable()
class NovelSeriesUser {
  final int id;
  final String name;
  final String account;
  @JsonKey(name: 'profile_image_urls')
  final NovelSeriesUserProfileImageUrls? profileImageUrls;
  @JsonKey(name: 'is_accept_request')
  final bool isAcceptRequest;

  NovelSeriesUser({
    required this.id,
    required this.name,
    required this.account,
    required this.profileImageUrls,
    required this.isAcceptRequest,
  });

  factory NovelSeriesUser.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesUserFromJson(json);

  Map<String, dynamic> toJson() => _$NovelSeriesUserToJson(this);
}

@JsonSerializable()
class NovelSeriesUserProfileImageUrls {
  final String? medium;

  NovelSeriesUserProfileImageUrls({required this.medium});

  factory NovelSeriesUserProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesUserProfileImageUrlsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NovelSeriesUserProfileImageUrlsToJson(this);
}
