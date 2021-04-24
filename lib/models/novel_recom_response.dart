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

// To parse this JSON data, do
//
//     final novelRecomResponse = novelRecomResponseFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
part 'novel_recom_response.g.dart';

@JsonSerializable()
class NovelRecomResponse {
  List<Novel> novels;

  @JsonKey(name: 'next_url')
  String? nextUrl;

  NovelRecomResponse({required this.novels});

  factory NovelRecomResponse.fromJson(Map<String, dynamic> json) =>
      _$NovelRecomResponseFromJson(json);
}

@JsonSerializable()
class Novel {
  int id;
  String title;
  String caption;
  int restrict;
  @JsonKey(name: 'x_restrict')
  int xRestrict;
  @JsonKey(name: 'is_original')
  bool isOriginal;
  @JsonKey(name: 'image_urls')
  ImageUrls imageUrls;
  @JsonKey(name: 'create_date')
  DateTime createDate;
  List<Tag> tags;
  @JsonKey(name: 'page_count')
  int pageCount;
  @JsonKey(name: 'text_length')
  int textLength;
  User user;
  Series series;
  @JsonKey(name: 'is_bookmarked')
  bool isBookmarked;
  @JsonKey(name: 'total_bookmarks')
  int totalBookmarks;
  @JsonKey(name: 'total_view')
  int totalView;
  bool visible;
  @JsonKey(name: 'total_comments')
  int totalComments;
  @JsonKey(name: 'is_muted')
  bool isMuted;
  @JsonKey(name: 'is_mypixiv_only')
  bool isMypixivOnly;
  @JsonKey(name: 'is_x_restricted')
  bool isXRestricted;

  Novel({
    required this.id,
    required this.title,
    required this.caption,
    required this.restrict,
    required this.xRestrict,
    required this.isOriginal,
    required this.imageUrls,
    required this.createDate,
    required this.tags,
    required this.pageCount,
    required this.textLength,
    required this.user,
    required this.series,
    required this.isBookmarked,
    required this.totalBookmarks,
    required this.totalView,
    required this.visible,
    required this.totalComments,
    required this.isMuted,
    required this.isMypixivOnly,
    required this.isXRestricted,
  });

  factory Novel.fromJson(Map<String, dynamic> json) => _$NovelFromJson(json);
}

@JsonSerializable()
class ImageUrls {
  @JsonKey(name: 'square_medium')
  String squareMedium;
  String medium;
  String large;

  ImageUrls({
    required this.squareMedium,
    required this.medium,
    required this.large,
  });

  factory ImageUrls.fromJson(Map<String, dynamic> json) =>
      _$ImageUrlsFromJson(json);
}

@JsonSerializable()
class Series {
  int? id;
  String? title;

  Series({
    this.id,
    this.title,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
}

@JsonSerializable()
class Tag {
  String name;
  @JsonKey(name: 'translated_name')
  String? translatedName;
  @JsonKey(name: 'added_by_uploaded_user')
  bool addedByUploadedUser;

  Tag({
    required this.name,
    required this.translatedName,
    required this.addedByUploadedUser,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@JsonSerializable()
class User {
  int id;
  String name;
  String account;
  @JsonKey(name: 'profile_image_urls')
  ProfileImageUrls profileImageUrls;
  @JsonKey(name: 'is_followed')
  bool isFollowed;

  User({
    required this.id,
    required this.name,
    required this.account,
    required this.profileImageUrls,
    required this.isFollowed,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonSerializable()
class ProfileImageUrls {
  String medium;

  ProfileImageUrls({
    required this.medium,
  });

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUrlsFromJson(json);
}

// class PrivacyPolicy {
//   String version;
//   String message;
//   String url;

//   PrivacyPolicy({
//     required this.version,
//     required this.message,
//     required this.url,
//   });

//   factory PrivacyPolicy.fromJson(Map<String, dynamic> json) => PrivacyPolicy(
//     version: json["version"],
//     message: json["message"],
//     url: json["url"],
//   );

//   Map<String, dynamic> toJson() => {
//     "version": version,
//     "message": message,
//     "url": url,
//   };
// }
