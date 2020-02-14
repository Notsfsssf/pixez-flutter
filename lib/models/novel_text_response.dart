// To parse this JSON data, do
//
//     final novelTextResponse = novelTextResponseFromJson(jsonString);

import 'dart:convert';

NovelTextResponse novelTextResponseFromJson(String str) => NovelTextResponse.fromJson(json.decode(str));

String novelTextResponseToJson(NovelTextResponse data) => json.encode(data.toJson());

class NovelTextResponse {
  NovelMarker novelMarker;
  String novelText;
  Series seriesPrev;

  NovelTextResponse({
    this.novelMarker,
    this.novelText,
    this.seriesPrev,
  });

  factory NovelTextResponse.fromJson(Map<String, dynamic> json) => NovelTextResponse(
    novelMarker: NovelMarker.fromJson(json["novel_marker"]),
    novelText: json["novel_text"],
    seriesPrev: Series.fromJson(json["series_prev"]),
  );

  Map<String, dynamic> toJson() => {
    "novel_marker": novelMarker.toJson(),
    "novel_text": novelText,
    "series_prev": seriesPrev.toJson(),
  };
}

class NovelMarker {
  NovelMarker();

  factory NovelMarker.fromJson(Map<String, dynamic> json) => NovelMarker(
  );

  Map<String, dynamic> toJson() => {
  };
}

class Series {
  int id;
  String title;
  String caption;
  int restrict;
  int xRestrict;
  bool isOriginal;
  ImageUrls imageUrls;
  List<Tag> tags;
  int pageCount;
  int textLength;
  User user;
  SeriesClass series;
  bool isBookmarked;
  int totalBookmarks;
  int totalView;
  bool visible;
  int totalComments;
  bool isMuted;
  bool isMypixivOnly;
  bool isXRestricted;
  Series seriesNext;
  DateTime createDate;

  Series({
    this.id,
    this.title,
    this.caption,
    this.restrict,
    this.xRestrict,
    this.isOriginal,
    this.imageUrls,
    this.tags,
    this.pageCount,
    this.textLength,
    this.user,
    this.series,
    this.isBookmarked,
    this.totalBookmarks,
    this.totalView,
    this.visible,
    this.totalComments,
    this.isMuted,
    this.isMypixivOnly,
    this.isXRestricted,
    this.seriesNext,
    this.createDate,
  });

  factory Series.fromJson(Map<String, dynamic> json) => Series(
    id: json["id"],
    title: json["title"],
    caption: json["caption"],
    restrict: json["restrict"],
    xRestrict: json["x_restrict"],
    isOriginal: json["is_original"],
    imageUrls: ImageUrls.fromJson(json["image_urls"]),
    tags: List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
    pageCount: json["page_count"],
    textLength: json["text_length"],
    user: User.fromJson(json["user"]),
    series: SeriesClass.fromJson(json["series"]),
    isBookmarked: json["is_bookmarked"],
    totalBookmarks: json["total_bookmarks"],
    totalView: json["total_view"],
    visible: json["visible"],
    totalComments: json["total_comments"],
    isMuted: json["is_muted"],
    isMypixivOnly: json["is_mypixiv_only"],
    isXRestricted: json["is_x_restricted"],
    seriesNext: json["series_next"] == null ? null : Series.fromJson(json["series_next"]),
    createDate: json["create_date"] == null ? null : DateTime.parse(json["create_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "caption": caption,
    "restrict": restrict,
    "x_restrict": xRestrict,
    "is_original": isOriginal,
    "image_urls": imageUrls.toJson(),
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
    "series_next": seriesNext == null ? null : seriesNext.toJson(),
    "create_date": createDate == null ? null : createDate.toIso8601String(),
  };
}

class ImageUrls {
  String squareMedium;
  String medium;
  String large;

  ImageUrls({
    this.squareMedium,
    this.medium,
    this.large,
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

class SeriesClass {
  int id;
  String title;

  SeriesClass({
    this.id,
    this.title,
  });

  factory SeriesClass.fromJson(Map<String, dynamic> json) => SeriesClass(
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
    this.name,
    this.translatedName,
    this.addedByUploadedUser,
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
    this.id,
    this.name,
    this.account,
    this.profileImageUrls,
    this.isFollowed,
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
    this.medium,
  });

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) => ProfileImageUrls(
    medium: json["medium"],
  );

  Map<String, dynamic> toJson() => {
    "medium": medium,
  };
}
