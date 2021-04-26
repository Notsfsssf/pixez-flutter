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
part 'bookmark.g.dart';
@JsonSerializable()
class BookmarkRsp {
  Bookmark_detail bookmark_detail;

  BookmarkRsp({
    required this.bookmark_detail,
  });

  factory BookmarkRsp.fromJson(Map<String, dynamic> json) => _$BookmarkRspFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkRspToJson(this);
}

@JsonSerializable()
class Bookmark_detail {
  bool is_bookmarked;
  List<Tags> tags;
  String restrict;

  Bookmark_detail({
    required this.is_bookmarked,
    required this.tags,
    required this.restrict,
  });

  factory Bookmark_detail.fromJson(Map<String, dynamic> json) => _$Bookmark_detailFromJson(json);
  Map<String, dynamic> toJson() => _$Bookmark_detailToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }
}

@JsonSerializable()
class Tags {
  String name;
  bool is_registered;

  Tags({
    required this.name,
    required this.is_registered,
  });

  factory Tags.fromJson(Map<String, dynamic> json) => _$TagsFromJson(json);
  Map<String, dynamic> toJson() => _$TagsToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }
}
