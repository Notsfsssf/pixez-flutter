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
    required this.bookmarkTags,
    required this.nextUrl,
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
    required this.name,
    required this.count,
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
