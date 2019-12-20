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
