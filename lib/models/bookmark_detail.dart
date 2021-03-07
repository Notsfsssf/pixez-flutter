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
import 'dart:convert' show json;

import 'package:json_annotation/json_annotation.dart';
part 'bookmark_detail.g.dart';

@JsonSerializable()
class BookMarkDetailResponse {
  @JsonKey(name: 'bookmark_detail')
  BookmarkDetail bookmarkDetail;

  BookMarkDetailResponse({
    required this.bookmarkDetail,
  });

  factory BookMarkDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$BookMarkDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookMarkDetailResponseToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }
}

@JsonSerializable()
class BookmarkDetail {
  @JsonKey(name: 'is_bookmarked')
  bool isBookmarked;
  @JsonKey(name: "tags")
  List<TagsR> tags;
  @JsonKey(name: 'restrict')
  String restrict;

  BookmarkDetail({
    required this.isBookmarked,
    required this.tags,
    required this.restrict,
  });

  factory BookmarkDetail.fromJson(Map<String, dynamic> json) =>
      _$BookmarkDetailFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkDetailToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }
}

@JsonSerializable()
class TagsR {
  String name;
  @JsonKey(name: 'is_registered')
  bool isRegistered;

  TagsR({
    required this.name,
    required this.isRegistered,
  });

  factory TagsR.fromJson(Map<String, dynamic> json) =>
      _$TagsRFromJson(json);

  Map<String, dynamic> toJson() => _$TagsRToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }
}
