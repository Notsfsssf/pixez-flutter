// {
//   "series": [
//     {
//       "mask_text": null,
//       "user": {
//         "id": 4004637,
//         "account": "9365710x",
//         "name": "幻羽",
//         "profile_image_urls": {
//           "medium": "https://i.pximg.net/user-profile/img/2023/09/15/12/22/50/24938498_0b12205fb7799c6445233c446333cd43_170.jpg"
//         }
//       },
//       "latest_content_id": 125547965,
//       "id": 266067,
//       "title": "X'max Present",
//       "last_published_content_datetime": "2024-12-26T01:27:48+09:00",
//       "published_content_count": 2,
//       "url": "https://i.pximg.net/c/240x480/img-master/img/2024/12/25/01/30/49/125508098_p0_master1200.jpg"
//     }
//   ],
//   "next_url": null
// }

import 'package:json_annotation/json_annotation.dart';

part 'watchlist_manga_model.g.dart';

@JsonSerializable()
class WatchlistMangaModel {
  final List<MangaSeriesModel> series;
  @JsonKey(name: 'next_url')
  final String? nextUrl;

  WatchlistMangaModel({
    required this.series,
    required this.nextUrl,
  });

  factory WatchlistMangaModel.fromJson(Map<String, dynamic> json) =>
      _$WatchlistMangaModelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchlistMangaModelToJson(this);
}

@JsonSerializable()
class MangaSeriesModel {
  @JsonKey(name: 'mask_text')
  final String? maskText;
  @JsonKey(name: 'latest_content_id')
  final int latestContentId;
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'user')
  final MangaSeriesUser? user;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'last_published_content_datetime')
  final String lastPublishedContentDatetime;
  @JsonKey(name: 'published_content_count')
  final int publishedContentCount;
  @JsonKey(name: 'url')
  final String? url;

  MangaSeriesModel({
    required this.maskText,
    required this.latestContentId,
    required this.id,
    required this.user,
    required this.title,
    required this.lastPublishedContentDatetime,
    required this.publishedContentCount,
    required this.url,
  });

  factory MangaSeriesModel.fromJson(Map<String, dynamic> json) =>
      _$MangaSeriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MangaSeriesModelToJson(this);
}

@JsonSerializable()
class MangaSeriesUser {
  final int id;
  final String? account;
  final String? name;
  final MangaSeriesUserProfileImageUrls? profileImageUrls;

  MangaSeriesUser({
    required this.id,
    required this.account,
    required this.name,
    required this.profileImageUrls,
  });

  factory MangaSeriesUser.fromJson(Map<String, dynamic> json) =>
      _$MangaSeriesUserFromJson(json);

  Map<String, dynamic> toJson() => _$MangaSeriesUserToJson(this);
}

@JsonSerializable()
class MangaSeriesUserProfileImageUrls {
  final String? medium;

  MangaSeriesUserProfileImageUrls({required this.medium});

  factory MangaSeriesUserProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      _$MangaSeriesUserProfileImageUrlsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MangaSeriesUserProfileImageUrlsToJson(this);
}
