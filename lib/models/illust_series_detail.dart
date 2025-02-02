import 'package:json_annotation/json_annotation.dart';
import 'package:pixez/models/illust.dart';

part 'illust_series_detail.g.dart';

@JsonSerializable()
class IllustSeriesDetailResponse {
  @JsonKey(name: 'illust_series_context')
  IllustSeriesContext? illustSeriesContext;
  @JsonKey(name: 'illust_series_detail')
  IllustSeriesDetail? illustSeriesDetail;

  IllustSeriesDetailResponse(
      {required this.illustSeriesContext, required this.illustSeriesDetail});

  factory IllustSeriesDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$IllustSeriesDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IllustSeriesDetailResponseToJson(this);
}

@JsonSerializable()
class IllustSeriesContext {
  @JsonKey(name: 'content_order')
  int? contentOrder;
  @JsonKey(name: 'next')
  Illusts? next;
  @JsonKey(name: 'prev')
  Illusts? prev;

  IllustSeriesContext({this.contentOrder, this.next, this.prev});

  factory IllustSeriesContext.fromJson(Map<String, dynamic> json) =>
      _$IllustSeriesContextFromJson(json);

  Map<String, dynamic> toJson() => _$IllustSeriesContextToJson(this);
}

// "illust_series_detail" : {
//     "height" : 0,
//     "series_work_count" : 2,
//     "id" : 266067,
//     "create_date" : "2024-12-25T01:27:20+09:00",
//     "title" : "X'max Present",
//     "width" : 0,
//     "cover_image_urls" : {
//       "medium" : null
//     },
//     "watchlist_added" : true,
//     "caption" : "",
//     "user" : {
//       "id" : 4004637,
//       "account" : "9365710x",
//       "name" : "幻羽",
//       "profile_image_urls" : {
//         "medium" : "https:\/\/i.pximg.net\/user-profile\/img\/2023\/09\/15\/12\/22\/50\/24938498_0b12205fb7799c6445233c446333cd43_170.jpg"
//       },
//       "is_followed" : false
//     }
//   }
@JsonSerializable()
class IllustSeriesDetail {
  int height;
  @JsonKey(name: 'series_work_count')
  int seriesWorkCount;
  int id;
  @JsonKey(name: 'create_date')
  String createDate;
  String title;
  int width;
  @JsonKey(name: 'cover_image_urls')
  CoverImageUrls coverImageUrls;
  @JsonKey(name: 'watchlist_added')
  bool watchlistAdded;
  String caption;
  IllustSeriesUser? user;

  IllustSeriesDetail(
      {required this.height,
      required this.seriesWorkCount,
      required this.id,
      required this.createDate,
      required this.title,
      required this.width,
      required this.coverImageUrls,
      required this.watchlistAdded,
      required this.caption,
      required this.user});

  factory IllustSeriesDetail.fromJson(Map<String, dynamic> json) =>
      _$IllustSeriesDetailFromJson(json);

  Map<String, dynamic> toJson() => _$IllustSeriesDetailToJson(this);
}

@JsonSerializable()
class IllustSeriesUser {
  int id;
  String account;
  String name;
  @JsonKey(name: 'profile_image_urls')
  IllustSeriesProfileImageUrls? profileImageUrls;
  @JsonKey(name: 'is_followed')
  bool isFollowed;

  IllustSeriesUser(
      {required this.id,
      required this.account,
      required this.name,
      required this.profileImageUrls,
      required this.isFollowed});

  factory IllustSeriesUser.fromJson(Map<String, dynamic> json) =>
      _$IllustSeriesUserFromJson(json);

  Map<String, dynamic> toJson() => _$IllustSeriesUserToJson(this);
}

@JsonSerializable()
class IllustSeriesProfileImageUrls {
  String? medium;

  IllustSeriesProfileImageUrls({this.medium});

  factory IllustSeriesProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$IllustSeriesProfileImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$IllustSeriesProfileImageUrlsToJson(this);
}

@JsonSerializable()
class CoverImageUrls {
  String? medium;

  CoverImageUrls({this.medium});

  factory CoverImageUrls.fromJson(Map<String, dynamic> json) =>
      _$CoverImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$CoverImageUrlsToJson(this);
}
