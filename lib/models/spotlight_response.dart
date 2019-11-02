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

// To parse this JSON data, do
//
//     final spotlightResponse = spotlightResponseFromJson(jsonString);
import 'package:json_annotation/json_annotation.dart';

part 'spotlight_response.g.dart';

@JsonSerializable()
class SpotlightResponse {
  @JsonKey(name: 'spotlight_articles')
  List<SpotlightArticle> spotlightArticles;
  @JsonKey(name: 'next_url')
  String? nextUrl;

  SpotlightResponse({
    required this.spotlightArticles,
    this.nextUrl,
  });
  factory SpotlightResponse.fromJson(Map<String, dynamic> json) =>
      _$SpotlightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpotlightResponseToJson(this);
}

@JsonSerializable()
class SpotlightArticle {
  int id;
  String title;
  @JsonKey(name: 'pure_title')
  String pureTitle;
  @JsonKey(name: 'thumbnail')
  String thumbnail;
  @JsonKey(name: 'article_url')
  String articleUrl;
  @JsonKey(name: 'publish_date')
  DateTime publishDate;
  // Category? category;
  // @JsonKey(name: 'subcategory_label')
  // SubcategoryLabel? subcategoryLabel;

  SpotlightArticle({
    required this.id,
    required this.title,
    required this.pureTitle,
    required this.thumbnail,
    required this.articleUrl,
    required this.publishDate,
    // this.category,
    // required this.subcategoryLabel,
  });

  factory SpotlightArticle.fromJson(Map<String, dynamic> json) =>
      _$SpotlightArticleFromJson(json);

  Map<String, dynamic> toJson() => _$SpotlightArticleToJson(this);
}