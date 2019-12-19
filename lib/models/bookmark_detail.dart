import 'dart:convert' show json;

class BookMarkDetailResponse {
  Bookmark_detail bookmarkDetail;

  BookMarkDetailResponse({
    this.bookmarkDetail,
  });

  factory BookMarkDetailResponse.fromJson(jsonRes) => jsonRes == null
      ? null
      : BookMarkDetailResponse(
          bookmarkDetail: Bookmark_detail.fromJson(jsonRes['bookmark_detail']),
        );
  Map<String, dynamic> toJson() => {
        'bookmark_detail': bookmarkDetail,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Bookmark_detail {
  bool isBookmarked;
  List<Tags> tags;
  String restrict;

  Bookmark_detail({
    this.isBookmarked,
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

class Tags {
  String name;
  bool isRegistered;

  Tags({
    this.name,
    this.isRegistered,
  });

  factory Tags.fromJson(jsonRes) => jsonRes == null
      ? null
      : Tags(
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
