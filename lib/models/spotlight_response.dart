// To parse this JSON data, do
//
//     final spotlightResponse = spotlightResponseFromJson(jsonString);

import 'dart:convert';

SpotlightResponse spotlightResponseFromJson(String str) =>
    SpotlightResponse.fromJson(json.decode(str));

String spotlightResponseToJson(SpotlightResponse data) =>
    json.encode(data.toJson());

class SpotlightResponse {
  List<SpotlightArticle> spotlightArticles;
  String nextUrl;

  SpotlightResponse({
    this.spotlightArticles,
    this.nextUrl,
  });

  SpotlightResponse copyWith({
    List<SpotlightArticle> spotlightArticles,
    String nextUrl,
  }) =>
      SpotlightResponse(
        spotlightArticles: spotlightArticles ?? this.spotlightArticles,
        nextUrl: nextUrl ?? this.nextUrl,
      );

  factory SpotlightResponse.fromJson(Map<String, dynamic> json) =>
      SpotlightResponse(
        spotlightArticles: List<SpotlightArticle>.from(
            json["spotlight_articles"]
                .map((x) => SpotlightArticle.fromJson(x))),
        nextUrl: json["next_url"],
      );

  Map<String, dynamic> toJson() => {
        "spotlight_articles":
            List<dynamic>.from(spotlightArticles.map((x) => x.toJson())),
        "next_url": nextUrl,
      };
}

class SpotlightArticle {
  int id;
  String title;
  String pureTitle;
  String thumbnail;
  String articleUrl;
  DateTime publishDate;
  Category category;
  SubcategoryLabel subcategoryLabel;

  SpotlightArticle({
    this.id,
    this.title,
    this.pureTitle,
    this.thumbnail,
    this.articleUrl,
    this.publishDate,
    this.category,
    this.subcategoryLabel,
  });

  SpotlightArticle copyWith({
    int id,
    String title,
    String pureTitle,
    String thumbnail,
    String articleUrl,
    DateTime publishDate,
    Category category,
    SubcategoryLabel subcategoryLabel,
  }) =>
      SpotlightArticle(
        id: id ?? this.id,
        title: title ?? this.title,
        pureTitle: pureTitle ?? this.pureTitle,
        thumbnail: thumbnail ?? this.thumbnail,
        articleUrl: articleUrl ?? this.articleUrl,
        publishDate: publishDate ?? this.publishDate,
        category: category ?? this.category,
        subcategoryLabel: subcategoryLabel ?? this.subcategoryLabel,
      );

  factory SpotlightArticle.fromJson(Map<String, dynamic> json) =>
      SpotlightArticle(
        id: json["id"],
        title: json["title"],
        pureTitle: json["pure_title"],
        thumbnail: json["thumbnail"],
        articleUrl: json["article_url"],
        publishDate: DateTime.parse(json["publish_date"]),
        category: categoryValues.map[json["category"]],
        subcategoryLabel: subcategoryLabelValues.map[json["subcategory_label"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "pure_title": pureTitle,
        "thumbnail": thumbnail,
        "article_url": articleUrl,
        "publish_date": publishDate.toIso8601String(),
        "category": categoryValues.reverse[category],
        "subcategory_label": subcategoryLabelValues.reverse[subcategoryLabel],
      };
}

enum Category { SPOTLIGHT, INSPIRATION }

final categoryValues = EnumValues(
    {"inspiration": Category.INSPIRATION, "spotlight": Category.SPOTLIGHT});

enum SubcategoryLabel { EMPTY, SUBCATEGORY_LABEL, PURPLE }

final subcategoryLabelValues = EnumValues({
  "イラスト": SubcategoryLabel.EMPTY,
  "おすすめ": SubcategoryLabel.PURPLE,
  "マンガ": SubcategoryLabel.SUBCATEGORY_LABEL
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
