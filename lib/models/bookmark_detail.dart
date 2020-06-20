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

class BookMarkDetailResponse {
  BookmarkDetail bookmarkDetail;

  BookMarkDetailResponse({
    this.bookmarkDetail,
  });

  factory BookMarkDetailResponse.fromJson(jsonRes) => jsonRes == null
      ? null
      : BookMarkDetailResponse(
          bookmarkDetail: BookmarkDetail.fromJson(jsonRes['bookmark_detail']),
        );
  Map<String, dynamic> toJson() => {
        'bookmark_detail': bookmarkDetail,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class BookmarkDetail {
  bool isBookmarked;
  List<TagsR> tags;
  String restrict;

  BookmarkDetail({
    this.isBookmarked,
    this.tags,
    this.restrict,
  });

  factory BookmarkDetail.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<TagsR> tags = jsonRes['tags'] is List ? [] : null;
    if (tags != null) {
      for (var item in jsonRes['tags']) {
        if (item != null) {
          tags.add(TagsR.fromJson(item));
        }
      }
    }

    return BookmarkDetail(
      isBookmarked: jsonRes['is_bookmarked'],
      tags: tags,
      restrict: jsonRes['restrict'],
    );
  }
  Map<String, dynamic> toJson() => {
        'is_bookmarked': isBookmarked,
        'tags': tags,
        'restrict': restrict,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class TagsR {
  String name;
  bool isRegistered;

  TagsR({
    this.name,
    this.isRegistered,
  });

  factory TagsR.fromJson(jsonRes) => jsonRes == null
      ? null
      : TagsR(
          name: jsonRes['name'],
          isRegistered: jsonRes['is_registered'],
        );
  Map<String, dynamic> toJson() => {
        'name': name,
        'is_registered': isRegistered,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
