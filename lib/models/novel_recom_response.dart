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
import 'dart:convert';

NovelRecomResponse novelRecomResponseFromJson(String str) => NovelRecomResponse.fromJson(json.decode(str));

String novelRecomResponseToJson(NovelRecomResponse data) => json.encode(data.toJson());

class NovelRecomResponse {
  List<Novel> novels;
  // PrivacyPolicy privacyPolicy;
  String nextUrl;

  NovelRecomResponse({
    required this.novels,
    // required this.privacyPolicy,
    required this.nextUrl,
  });

  factory NovelRecomResponse.fromJson(Map<String, dynamic> json) => NovelRecomResponse(
    novels: List<Novel>.from(json["novels"].map((x) => Novel.fromJson(x))),
    // privacyPolicy: PrivacyPolicy.fromJson(json["privacy_policy"]),
    nextUrl: json["next_url"],
  );

  Map<String, dynamic> toJson() => {
    "novels": List<dynamic>.from(novels.map((x) => x.toJson())),
    // "privacy_policy": privacyPolicy.toJson(),
    "next_url": nextUrl,
  };
}

class Novel {
  int id;
  String title;
  String caption;
  int restrict;
  int xRestrict;
  bool isOriginal;
  ImageUrls imageUrls;
  DateTime createDate;
  List<Tag> tags;
  int pageCount;
  int textLength;
  User user;
  Series series;
  bool isBookmarked;
  int totalBookmarks;
  int totalView;
  bool visible;
  int totalComments;
  bool isMuted;
  bool isMypixivOnly;
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

  factory Novel.fromJson(Map<String, dynamic> json) => Novel(
    id: json["id"],
    title: json["title"],
    caption: json["caption"],
    restrict: json["restrict"],
    xRestrict: json["x_restrict"],
    isOriginal: json["is_original"],
    imageUrls: ImageUrls.fromJson(json["image_urls"]),
    createDate: DateTime.parse(json["create_date"]),
    tags: List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
    pageCount: json["page_count"],
    textLength: json["text_length"],
    user: User.fromJson(json["user"]),
    series: Series.fromJson(json["series"]),
    isBookmarked: json["is_bookmarked"],
    totalBookmarks: json["total_bookmarks"],
    totalView: json["total_view"],
    visible: json["visible"],
    totalComments: json["total_comments"],
    isMuted: json["is_muted"],
    isMypixivOnly: json["is_mypixiv_only"],
    isXRestricted: json["is_x_restricted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "caption": caption,
    "restrict": restrict,
    "x_restrict": xRestrict,
    "is_original": isOriginal,
    "image_urls": imageUrls.toJson(),
    "create_date": createDate.toIso8601String(),
    "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
    "page_count": pageCount,
    "text_length": textLength,
    "user": user.toJson(),
    "series": series.toJson(),
    "is_bookmarked": isBookmarked,
    "total_bookmarks": totalBookmarks,
    "total_view": totalView,
    "visible": visible,
    "total_comments": totalComments,
    "is_muted": isMuted,
    "is_mypixiv_only": isMypixivOnly,
    "is_x_restricted": isXRestricted,
  };
}

class ImageUrls {
  String squareMedium;
  String medium;
  String large;

  ImageUrls({
    required this.squareMedium,
    required this.medium,
    required this.large,
  });

  factory ImageUrls.fromJson(Map<String, dynamic> json) => ImageUrls(
    squareMedium: json["square_medium"],
    medium: json["medium"],
    large: json["large"],
  );

  Map<String, dynamic> toJson() => {
    "square_medium": squareMedium,
    "medium": medium,
    "large": large,
  };
}

class Series {
  int id;
  String title;

  Series({
    required this.id,
    required this.title,
  });

  factory Series.fromJson(Map<String, dynamic> json) => Series(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}

class Tag {
  String name;
  String translatedName;
  bool addedByUploadedUser;

  Tag({
    required this.name,
    required this.translatedName,
    required this.addedByUploadedUser,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    name: json["name"],
    translatedName: json["translated_name"],
    addedByUploadedUser: json["added_by_uploaded_user"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "translated_name": translatedName,
    "added_by_uploaded_user": addedByUploadedUser,
  };
}

class User {
  int id;
  String name;
  String account;
  ProfileImageUrls profileImageUrls;
  bool isFollowed;

  User({
    required this.id,
    required this.name,
    required this.account,
    required this.profileImageUrls,
    required this.isFollowed,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    account: json["account"],
    profileImageUrls: ProfileImageUrls.fromJson(json["profile_image_urls"]),
    isFollowed: json["is_followed"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "account": account,
    "profile_image_urls": profileImageUrls.toJson(),
    "is_followed": isFollowed,
  };
}

class ProfileImageUrls {
  String medium;

  ProfileImageUrls({
    required this.medium,
  });

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) => ProfileImageUrls(
    medium: json["medium"],
  );

  Map<String, dynamic> toJson() => {
    "medium": medium,
  };
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
