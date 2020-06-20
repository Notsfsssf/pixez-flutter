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

class BookmarkRsp {
  Bookmark_detail bookmark_detail;

  BookmarkRsp({
    this.bookmark_detail,
  });

  factory BookmarkRsp.fromJson(jsonRes) => jsonRes == null
      ? null
      : BookmarkRsp(
          bookmark_detail: Bookmark_detail.fromJson(jsonRes['bookmark_detail']),
        );
  Map<String, dynamic> toJson() => {
        'bookmark_detail': bookmark_detail,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Bookmark_detail {
  bool is_bookmarked;
  List<Tags> tags;
  String restrict;

  Bookmark_detail({
    this.is_bookmarked,
    this.tags,
    this.restrict,
  });

  factory Bookmark_detail.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<Tags> tags = jsonRes['tags'] is List ? [] : null;
    if (tags != null) {
      for (var item in jsonRes['tags']) {
        if (item != null) {
          tags.add(Tags.fromJson(item));
        }
      }
    }

    return Bookmark_detail(
      is_bookmarked: jsonRes['is_bookmarked'],
      tags: tags,
      restrict: jsonRes['restrict'],
    );
  }
  Map<String, dynamic> toJson() => {
        'is_bookmarked': is_bookmarked,
        'tags': tags,
        'restrict': restrict,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Tags {
  String name;
  bool is_registered;

  Tags({
    this.name,
    this.is_registered,
  });

  factory Tags.fromJson(jsonRes) => jsonRes == null
      ? null
      : Tags(
          name: jsonRes['name'],
          is_registered: jsonRes['is_registered'],
        );
  Map<String, dynamic> toJson() => {
        'name': name,
        'is_registered': is_registered,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
