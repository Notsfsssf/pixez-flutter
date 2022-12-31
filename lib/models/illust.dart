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
 *F
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
import 'package:json_annotation/json_annotation.dart';

part 'illust.g.dart';

@JsonSerializable()
class MetaPages {
  @JsonKey(name: 'image_urls')
  MetaPagesImageUrls? imageUrls;

  MetaPages({required this.imageUrls});

  factory MetaPages.fromJson(Map<String, dynamic> json) =>
      _$MetaPagesFromJson(json);

  Map<String, dynamic> toJson() => _$MetaPagesToJson(this);
}

@JsonSerializable()
class MetaPagesImageUrls {
  @JsonKey(name: 'square_medium')
  String squareMedium;
  String medium;
  String large;
  String original;

  MetaPagesImageUrls(
      {required this.squareMedium,
      required this.medium,
      required this.large,
      required this.original});

  factory MetaPagesImageUrls.fromJson(Map<String, dynamic> json) =>
      _$MetaPagesImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$MetaPagesImageUrlsToJson(this);
}

@JsonSerializable()
class Illusts {
  int id;
  String title;
  String type;
  @JsonKey(name: 'image_urls')
  ImageUrls imageUrls;
  String caption;
  int restrict;
  User user;
  List<Tags> tags;
  List<String> tools;
  @JsonKey(name: 'create_date')
  String createDate;
  @JsonKey(name: 'page_count')
  int pageCount;
  int width;
  int height;
  @JsonKey(name: 'sanity_level')
  int sanityLevel;
  @JsonKey(name: 'x_restrict')
  int xRestrict;
  Object? series;
  @JsonKey(name: 'meta_single_page')
  MetaSinglePage? metaSinglePage;
  @JsonKey(name: 'meta_pages')
  List<MetaPages> metaPages;
  @JsonKey(name: 'total_view')
  int totalView;
  @JsonKey(name: 'total_bookmarks')
  int totalBookmarks;
  @JsonKey(name: 'is_bookmarked')
  bool isBookmarked;
  bool visible;
  @JsonKey(name: 'is_muted')
  bool isMuted;
  @JsonKey(name: 'illust_ai_type')
  int illustAIType;

  Illusts(
      {required this.id,
      required this.title,
      required this.type,
      required this.imageUrls,
      required this.caption,
      required this.restrict,
      required this.user,
      required this.tags,
      required this.tools,
      required this.createDate,
      required this.pageCount,
      required this.width,
      required this.height,
      required this.sanityLevel,
      required this.xRestrict,
      this.series,
      this.metaSinglePage,
      required this.metaPages,
      required this.totalView,
      required this.totalBookmarks,
      required this.isBookmarked,
      required this.visible,
      required this.isMuted,
      required this.illustAIType});

  factory Illusts.fromJson(Map<String, dynamic> json) =>
      _$IllustsFromJson(json);

  Map<String, dynamic> toJson() => _$IllustsToJson(this);
}

@JsonSerializable()
class ImageUrls {
  @JsonKey(name: 'square_medium')
  String squareMedium;
  String medium;
  String large;

  ImageUrls(
      {required this.squareMedium, required this.medium, required this.large});

  factory ImageUrls.fromJson(Map<String, dynamic> json) =>
      _$ImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUrlsToJson(this);
}

@JsonSerializable()
class User {
  int id;
  String name;
  String account;
  @JsonKey(name: 'profile_image_urls')
  ProfileImageUrls profileImageUrls;
  String? comment;
  @JsonKey(name: 'is_followed')
  bool? isFollowed;

  User(
      {required this.id,
      required this.name,
      required this.account,
      required this.profileImageUrls,
      this.comment,
      this.isFollowed});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class ProfileImageUrls {
  String medium;

  ProfileImageUrls({required this.medium});

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileImageUrlsToJson(this);
}

@JsonSerializable()
class Tags {
  String name;
  @JsonKey(name: 'translated_name')
  String? translatedName;

  Tags({required this.name, this.translatedName});

  factory Tags.fromJson(Map<String, dynamic> json) => _$TagsFromJson(json);

  Map<String, dynamic> toJson() => _$TagsToJson(this);
}

@JsonSerializable()
class MetaSinglePage {
  @JsonKey(name: 'original_image_url')
  String? originalImageUrl;

  MetaSinglePage({this.originalImageUrl});

  factory MetaSinglePage.fromJson(Map<String, dynamic> json) =>
      _$MetaSinglePageFromJson(json);

  Map<String, dynamic> toJson() => _$MetaSinglePageToJson(this);
}
