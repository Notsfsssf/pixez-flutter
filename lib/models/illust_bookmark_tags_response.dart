// To parse this JSON data, do
//
//     final illustBookmarkTagsResponse = illustBookmarkTagsResponseFromJson(jsonString);

import 'dart:convert';

IllustBookmarkTagsResponse illustBookmarkTagsResponseFromJson(String str) =>
    IllustBookmarkTagsResponse.fromJson(json.decode(str));

String illustBookmarkTagsResponseToJson(IllustBookmarkTagsResponse data) =>
    json.encode(data.toJson());

class IllustBookmarkTagsResponse {
  List<BookmarkTag> bookmarkTags;
  String nextUrl;

  IllustBookmarkTagsResponse({
    this.bookmarkTags,
    this.nextUrl,
  });

  factory IllustBookmarkTagsResponse.fromJson(Map<String, dynamic> json) =>
      IllustBookmarkTagsResponse(
        bookmarkTags: List<BookmarkTag>.from(
            json["bookmark_tags"].map((x) => BookmarkTag.fromJson(x))),
        nextUrl: json["next_url"],
      );

  Map<String, dynamic> toJson() => {
        "bookmark_tags":
            List<dynamic>.from(bookmarkTags.map((x) => x.toJson())),
        "next_url": nextUrl,
      };
}

class BookmarkTag {
  String name;
  int count;

  BookmarkTag({
    this.name,
    this.count,
  });

  factory BookmarkTag.fromJson(Map<String, dynamic> json) => BookmarkTag(
        name: json["name"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "count": count,
      };
}
