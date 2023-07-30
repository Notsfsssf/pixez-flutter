import 'package:json_annotation/json_annotation.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/novel_recom_response.dart';

part 'novel_series_detail.g.dart';

@JsonSerializable()
class NovelSeriesSeries {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "title")
  String title;

  NovelSeriesSeries({
    required this.id,
    required this.title,
  });

  factory NovelSeriesSeries.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$NovelSeriesSeriesToJson(this);
}

@JsonSerializable()
class NovelSeriesNovelTag {
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "translated_name")
  String? translatedName;
  @JsonKey(name: "added_by_uploaded_user")
  bool addedByUploadedUser;

  NovelSeriesNovelTag({
    required this.name,
    this.translatedName,
    required this.addedByUploadedUser,
  });

  factory NovelSeriesNovelTag.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesNovelTagFromJson(json);

  Map<String, dynamic> toJson() => _$NovelSeriesNovelTagToJson(this);
}

@JsonSerializable()
class NovelSeriesNovel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "caption")
  String? caption;
  @JsonKey(name: "restrict")
  int restrict;
  @JsonKey(name: "x_restrict")
  int xRestrict;
  @JsonKey(name: "is_original")
  bool? isOriginal;
  @JsonKey(name: "image_urls")
  NovelSeriesImageUrls imageUrls;
  @JsonKey(name: "create_date")
  DateTime createDate;
  @JsonKey(name: "tags")
  List<NovelSeriesNovelTag> tags;
  @JsonKey(name: "page_count")
  int pageCount;
  @JsonKey(name: "text_length")
  int textLength;
  @JsonKey(name: "user")
  NovelSeriesUser user;
  @JsonKey(name: "series")
  NovelSeriesSeries series;
  @JsonKey(name: "is_bookmarked")
  bool isBookmarked;
  @JsonKey(name: "total_bookmarks")
  int totalBookmarks;
  @JsonKey(name: "total_view")
  int totalView;
  @JsonKey(name: "visible")
  bool visible;
  @JsonKey(name: "total_comments")
  int totalComments;
  @JsonKey(name: "is_muted")
  bool isMuted;
  @JsonKey(name: "is_mypixiv_only")
  bool isMypixivOnly;
  @JsonKey(name: "is_x_restricted")
  bool isXRestricted;
  @JsonKey(name: "novel_ai_type")
  int novelAiType;
  NovelSeriesNovel({
    required this.id,
    required this.title,
    required this.caption,
    required this.restrict,
    required this.xRestrict,
    required this.isOriginal,
    required this.imageUrls,
    required this.createDate,
    required this.tags,
    required this.pageCount,
    required this.textLength,
    required this.user,
    required this.series,
    required this.isBookmarked,
    required this.totalBookmarks,
    required this.totalView,
    required this.visible,
    required this.totalComments,
    required this.isMuted,
    required this.isMypixivOnly,
    required this.isXRestricted,
    required this.novelAiType,
  });

  factory NovelSeriesNovel.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesNovelFromJson(json);

  Map<String, dynamic> toJson() => _$NovelSeriesNovelToJson(this);
}

@JsonSerializable()
class NovelSeriesDetail {
  int id;
  String title;
  String? caption;
  @JsonKey(name: "is_original")
  bool isOriginal;
  @JsonKey(name: "is_concluded")
  bool isConcluded;
  @JsonKey(name: "content_count")
  int contentCount;
  @JsonKey(name: "total_character_count")
  int totalCharacterCount;
  NovelSeriesUser user;
  @JsonKey(name: "display_text")
  String displayText;
  @JsonKey(name: "novel_ai_type")
  int novelAiType;
  @JsonKey(name: "watchlist_added")
  bool? watchlistAdded;

  NovelSeriesDetail(
      this.id,
      this.title,
      this.caption,
      this.isOriginal,
      this.isConcluded,
      this.contentCount,
      this.totalCharacterCount,
      this.user,
      this.displayText,
      this.novelAiType,
      this.watchlistAdded);

  factory NovelSeriesDetail.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesDetailFromJson(json);
  Map<String, dynamic> toJson() => _$NovelSeriesDetailToJson(this);
}

@JsonSerializable()
class NovelSeriesUser {
  int id;
  String name;
  String account;
  @JsonKey(name: "profile_image_urls")
  NovelSeriesProfileImageUrls profileImageUrls;
  @JsonKey(name: "is_followed")
  bool isFollowed;
  @JsonKey(name: "is_access_blocking_user")
  bool isAccessBlockingUser;

  NovelSeriesUser(this.id, this.name, this.account, this.profileImageUrls,
      this.isFollowed, this.isAccessBlockingUser);

  factory NovelSeriesUser.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesUserFromJson(json);
  Map<String, dynamic> toJson() => _$NovelSeriesUserToJson(this);
}

@JsonSerializable()
class NovelSeriesProfileImageUrls {
  String medium;

  NovelSeriesProfileImageUrls(this.medium);

  factory NovelSeriesProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesProfileImageUrlsFromJson(json);
  Map<String, dynamic> toJson() => _$NovelSeriesProfileImageUrlsToJson(this);
}

@JsonSerializable()
class NovelSeriesFirstNovel {
  int id;
  String title;
  String caption;
  int restrict;
  @JsonKey(name: 'x_restrict')
  int xRestrict;
  @JsonKey(name: 'is_original')
  bool isOriginal;
  @JsonKey(name: 'image_urls')
  NovelSeriesImageUrls imageUrls;
  @JsonKey(name: 'create_date')
  String createDate;
  List<NovelSeriesNovelTag> tags;
  @JsonKey(name: 'page_count')
  int pageCount;
  @JsonKey(name: 'text_length')
  int textLength;
  NovelSeriesUser user;
  NovelSeriesSeries series;
  @JsonKey(name: 'is_bookmarked')
  bool isBookmarked;
  @JsonKey(name: 'total_bookmarks')
  int totalBookmarks;
  @JsonKey(name: 'total_view')
  int totalView;
  bool visible;
  @JsonKey(name: 'total_comments')
  int totalComments;
  @JsonKey(name: 'is_muted')
  bool? isMuted;
  @JsonKey(name: 'is_my_pixiv_only')
  bool? isMypixivOnly;
  @JsonKey(name: 'is_X_restricted')
  bool? isXRestricted;
  @JsonKey(name: 'novel_ai_type')
  int novelAiType;

  NovelSeriesFirstNovel(
      this.id,
      this.title,
      this.caption,
      this.restrict,
      this.xRestrict,
      this.isOriginal,
      this.imageUrls,
      this.createDate,
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
      this.novelAiType);

  factory NovelSeriesFirstNovel.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesFirstNovelFromJson(json);
  Map<String, dynamic> toJson() => _$NovelSeriesFirstNovelToJson(this);
}

@JsonSerializable()
class NovelSeriesImageUrls {
  @JsonKey(name: 'square_medium')
  String squareMedium;
  String medium;
  String large;

  NovelSeriesImageUrls(this.squareMedium, this.medium, this.large);

  factory NovelSeriesImageUrls.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesImageUrlsFromJson(json);
  Map<String, dynamic> toJson() => _$NovelSeriesImageUrlsToJson(this);
}

@JsonSerializable()
class NovelSeriesResponse {
  @JsonKey(name: 'novel_series_detail')
  NovelSeriesDetail novelSeriesDetail;
  @JsonKey(name: 'novel_series_first_novel')
  NovelSeriesFirstNovel novelSeriesFirstNovel;
  @JsonKey(name: 'novel_series_latest_novel')
  NovelSeriesFirstNovel? novelSeriesLatestNovel;
  List<Novel> novels;
  @JsonKey(name: 'next_url')
  String? nextUrl;

  NovelSeriesResponse(this.novelSeriesDetail, this.novelSeriesFirstNovel,
      this.novelSeriesLatestNovel, this.novels, this.nextUrl);

  factory NovelSeriesResponse.fromJson(Map<String, dynamic> json) =>
      _$NovelSeriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NovelSeriesResponseToJson(this);
}
