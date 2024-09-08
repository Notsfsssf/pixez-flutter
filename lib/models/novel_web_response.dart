import 'package:json_annotation/json_annotation.dart';
part 'novel_web_response.g.dart';

@JsonSerializable()
class NovelWebResponse {
  String id;
  String title;
  dynamic seriesId;
  dynamic seriesTitle;
  dynamic seriesIsWatched;
  String userId;
  String coverUrl;
  List<String> tags;
  String caption;
  String cdate;
  NovelRating rating;
  String text;
  dynamic marker;
  SeriesNavigation? seriesNavigation;
  List<dynamic>? glossaryItems;
  List<dynamic>? replaceableItemIds;
  Map<String, NovelImage>? images;
  Map<String, NovelIllusts?>? illusts;
  int? aiType;
  bool? isOriginal;
  NovelWebResponse({
    required this.id,
    required this.title,
    required this.seriesId,
    required this.seriesTitle,
    required this.seriesIsWatched,
    required this.userId,
    required this.coverUrl,
    required this.tags,
    required this.caption,
    required this.cdate,
    required this.rating,
    required this.text,
    required this.marker,
    required this.illusts,
    required this.images,
    required this.seriesNavigation,
    required this.glossaryItems,
    required this.replaceableItemIds,
    required this.aiType,
    required this.isOriginal,
  });

  factory NovelWebResponse.fromJson(Map<String, dynamic> json) =>
      NovelWebResponse(
        id: json['id'] as String,
        title: json['title'] as String,
        seriesId: json['seriesId'],
        seriesTitle: json['seriesTitle'],
        seriesIsWatched: json['seriesIsWatched'],
        userId: json['userId'] as String,
        coverUrl: json['coverUrl'] as String,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        caption: json['caption'] as String,
        cdate: json['cdate'] as String,
        rating: NovelRating.fromJson(json['rating'] as Map<String, dynamic>),
        text: json['text'] as String,
        marker: json['marker'],
        illusts: (json['illusts'] is Map<String, dynamic>)
            ? (json['illusts'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e == null || (e as Map?)?['illust'] == null)
                        ? null
                        : NovelIllusts.fromJson(e as Map<String, dynamic>)),
              )
            : null,
        images: (json['images'] is Map<String, dynamic>)
            ? (json['images'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, NovelImage.fromJson(e as Map<String, dynamic>)),
              )
            : null,
        seriesNavigation: json['seriesNavigation'] == null
            ? null
            : SeriesNavigation.fromJson(
                json['seriesNavigation'] as Map<String, dynamic>),
        glossaryItems: json['glossaryItems'] as List<dynamic>?,
        replaceableItemIds: json['replaceableItemIds'] as List<dynamic>?,
        aiType: json['aiType'] as int?,
        isOriginal: json['isOriginal'] as bool?,
      );

  Map<String, dynamic> toJson() => _$NovelWebResponseToJson(this);
}

@JsonSerializable()
class NovelIllusts {
  NovelIllust illust;

  NovelIllusts({
    required this.illust,
  });

  Map<String, dynamic> toJson() => _$NovelIllustsToJson(this);

  factory NovelIllusts.fromJson(Map<String, dynamic> json) =>
      _$NovelIllustsFromJson(json);
}

@JsonSerializable()
class NovelIllust {
  NovelIllustImages images;
  NovelIllust({
    required this.images,
  });
  Map<String, dynamic> toJson() => _$NovelIllustToJson(this);

  factory NovelIllust.fromJson(Map<String, dynamic> json) =>
      _$NovelIllustFromJson(json);
}

@JsonSerializable()
class NovelIllustImages {
  String? small;
  String? medium;
  String? original;

  NovelIllustImages({
    required this.small,
    required this.medium,
    required this.original,
  });

  Map<String, dynamic> toJson() => _$NovelIllustImagesToJson(this);

  factory NovelIllustImages.fromJson(Map<String, dynamic> json) =>
      _$NovelIllustImagesFromJson(json);
}

@JsonSerializable()
class NovelRating {
  int like;
  int bookmark;
  int view;

  NovelRating({
    required this.like,
    required this.bookmark,
    required this.view,
  });

  Map<String, dynamic> toJson() => _$NovelRatingToJson(this);

  factory NovelRating.fromJson(Map<String, dynamic> json) =>
      _$NovelRatingFromJson(json);
}

@JsonSerializable()
class SeriesNavigation {
  PrevNovel? nextNovel;
  PrevNovel? prevNovel;

  SeriesNavigation({
    required this.nextNovel,
    required this.prevNovel,
  });

  factory SeriesNavigation.fromJson(Map<String, dynamic> json) =>
      _$SeriesNavigationFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesNavigationToJson(this);
}

@JsonSerializable()
class PrevNovel {
  int id;
  bool viewable;
  String contentOrder;
  String title;
  String coverUrl;

  PrevNovel({
    required this.id,
    required this.viewable,
    required this.contentOrder,
    required this.title,
    required this.coverUrl,
  });

  factory PrevNovel.fromJson(Map<String, dynamic> json) =>
      _$PrevNovelFromJson(json);

  Map<String, dynamic> toJson() => _$PrevNovelToJson(this);
}

@JsonSerializable()
class NovelImage {
  String? novelImageId;
  String sl;
  NovelUrls urls;

  NovelImage({
    required this.novelImageId,
    required this.sl,
    required this.urls,
  });

  factory NovelImage.fromJson(Map<String, dynamic> json) =>
      _$NovelImageFromJson(json);

  Map<String, dynamic> toJson() => _$NovelImageToJson(this);
}

@JsonSerializable()
class NovelUrls {
  String? the240Mw;
  String? the480Mw;
  String? the1200X1200;
  String? the128X128;
  String? original;

  NovelUrls({
    required this.the240Mw,
    required this.the480Mw,
    required this.the1200X1200,
    required this.the128X128,
    required this.original,
  });

  factory NovelUrls.fromJson(Map<String, dynamic> json) =>
      _$NovelUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$NovelUrlsToJson(this);
}
