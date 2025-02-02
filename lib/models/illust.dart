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
import 'package:pixez/main.dart';

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

extension IllustsExtension on Illusts {
  String get illustDetailUrl => switch (userSetting.pictureQuality) {
        0 => imageUrls.medium,
        1 => imageUrls.large,
        2 => metaPages.firstOrNull?.imageUrls?.original ??
            metaSinglePage!.originalImageUrl!,
        _ => imageUrls.medium,
      };

  String get managaDetailUrl => switch (userSetting.mangaQuality) {
        0 => imageUrls.medium,
        1 => imageUrls.large,
        2 => metaPages.firstOrNull?.imageUrls?.original ??
            metaSinglePage!.originalImageUrl!,
        _ => imageUrls.medium,
      };

  String illustDetailImageUrl(int index) =>
      switch (userSetting.pictureQuality) {
        0 => metaPages[index].imageUrls!.medium,
        1 => metaPages[index].imageUrls!.large,
        2 => metaPages[index].imageUrls!.original,
        _ => metaPages[index].imageUrls!.medium,
      };

  String managaDetailImageUrl(int index) =>
      switch (userSetting.mangaQuality) {
        0 => metaPages[index].imageUrls!.medium,
        1 => metaPages[index].imageUrls!.large,
        2 => metaPages[index].imageUrls!.original,
        _ => metaPages[index].imageUrls!.medium,
      };
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
  IllustSeries? series;
  @JsonKey(name: 'illust_book_style')
  int? illustBookStyle;
  @JsonKey(name: 'total_comments')
  int? totalComments;

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
      this.illustBookStyle,
      required this.metaPages,
      required this.totalView,
      required this.totalBookmarks,
      required this.isBookmarked,
      required this.visible,
      required this.isMuted,
      required this.illustAIType,
      required this.totalComments});

  factory Illusts.fromJson(Map<String, dynamic> json) =>
      _$IllustsFromJson(json);

  Map<String, dynamic> toJson() => _$IllustsToJson(this);
}

@JsonSerializable()
class IllustSeries {
  int id;
  String? title;

  IllustSeries({required this.id, required this.title});

  factory IllustSeries.fromJson(Map<String, dynamic> json) =>
      _$IllustSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$IllustSeriesToJson(this);
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

extension IllustExtension on Illusts {
  String get feedPreviewUrl => (userSetting.feedPreviewQuality == 0)
      ? imageUrls.medium
      : (userSetting.feedPreviewQuality == 1)
          ? this.imageUrls.large
          : this.metaSinglePage?.originalImageUrl ??
              this.metaPages[0].imageUrls!.original;
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
// {"illust":{"id":125547965,"title":"X'max Present 下篇","type":"manga","image_urls":{"square_medium":"https://i.pximg.net/c/360x360_70/img-master/img/2024/12/26/01/27/47/125547965_p0_square1200.jpg","medium":"https://i.pximg.net/c/540x540_70/img-master/img/2024/12/26/01/27/47/125547965_p0_master1200.jpg","large":"https://i.pximg.net/c/600x1200_90/img-master/img/2024/12/26/01/27/47/125547965_p0_master1200.jpg"},"caption":"テメェ...アロナ！！💢","restrict":0,"user":{"id":4004637,"name":"幻羽","account":"9365710x","profile_image_urls":{"medium":"https://i.pximg.net/user-profile/img/2023/09/15/12/22/50/24938498_0b12205fb7799c6445233c446333cd43_170.jpg"},"is_followed":false},"tags":[{"name":"R-18","translated_name":null},{"name":"漫画","translated_name":"manga"},{"name":"ブルーアーカイブ","translated_name":"碧蓝档案"},{"name":"ブルアカ","translated_name":null},{"name":"BlueArchive","translated_name":null},{"name":"アロナ(ブルーアーカイブ)","translated_name":"Alona (Blue Archive)"},{"name":"プラナ(ブルーアーカイブ)","translated_name":"Plana (Blue Archive)"}],"tools":[],"create_date":"2024-12-26T01:27:47+09:00","page_count":2,"width":3031,"height":4238,"sanity_level":6,"x_restrict":1,"series":{"id":266067,"title":"X'max Present"},"meta_single_page":{},"meta_pages":[{"image_urls":{"square_medium":"https://i.pximg.net/c/360x360_70/img-master/img/2024/12/26/01/27/47/125547965_p0_square1200.jpg","medium":"https://i.pximg.net/c/540x540_70/img-master/img/2024/12/26/01/27/47/125547965_p0_master1200.jpg","large":"https://i.pximg.net/c/600x1200_90/img-master/img/2024/12/26/01/27/47/125547965_p0_master1200.jpg","original":"https://i.pximg.net/img-original/img/2024/12/26/01/27/47/125547965_p0.jpg"}},{"image_urls":{"square_medium":"https://i.pximg.net/c/360x360_70/img-master/img/2024/12/26/01/27/47/125547965_p1_square1200.jpg","medium":"https://i.pximg.net/c/540x540_70/img-master/img/2024/12/26/01/27/47/125547965_p1_master1200.jpg","large":"https://i.pximg.net/c/600x1200_90/img-master/img/2024/12/26/01/27/47/125547965_p1_master1200.jpg","original":"https://i.pximg.net/img-original/img/2024/12/26/01/27/47/125547965_p1.jpg"}}],"total_view":12394,"total_bookmarks":1298,"is_bookmarked":true,"visible":true,"is_muted":false,"total_comments":11,"illust_ai_type":1,"illust_book_style":0,"restriction_attributes":["restricted_mode"],"comment_access_control":0}}