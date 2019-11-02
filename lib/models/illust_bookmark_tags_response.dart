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

import 'package:json_annotation/json_annotation.dart';
part 'illust_bookmark_tags_response.g.dart';

@JsonSerializable()
class IllustBookmarkTagsResponse {
  @JsonKey(name: "bookmark_tags")
  List<BookmarkTag> bookmarkTags;
  @JsonKey(name: "next_url")
  String? nextUrl;

  IllustBookmarkTagsResponse({
    required this.bookmarkTags,
    this.nextUrl,
  });
  factory IllustBookmarkTagsResponse.fromJson(Map<String, dynamic> json) =>
      _$IllustBookmarkTagsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IllustBookmarkTagsResponseToJson(this);
}

@JsonSerializable()
class BookmarkTag {
  String name;
  int count;

  BookmarkTag({
    required this.name,
    required this.count,
  });
  factory BookmarkTag.fromJson(Map<String, dynamic> json) =>
      _$BookmarkTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkTagToJson(this);
}
