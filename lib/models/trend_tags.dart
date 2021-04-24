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
import 'package:json_annotation/json_annotation.dart';
import 'package:pixez/models/illust.dart';
part 'trend_tags.g.dart';

@JsonSerializable()
class TrendingTag {
  List<TrendTags> trend_tags;

  TrendingTag({
    required this.trend_tags,
  });

  factory TrendingTag.fromJson(Map<String, dynamic> json) =>
      _$TrendingTagFromJson(json);
}

@JsonSerializable()
class TrendTags {
  String tag;
  TrendTagsIllust illust;

  TrendTags({
    required this.tag,
    required this.illust,
  });

  factory TrendTags.fromJson(Map<String, dynamic> json) =>
      _$TrendTagsFromJson(json);
}

@JsonSerializable()
class TrendTagsIllust {
  int id;
  @JsonKey(name: 'image_urls')
  ImageUrls imageUrls;

  TrendTagsIllust({required this.id, required this.imageUrls});

  factory TrendTagsIllust.fromJson(Map<String, dynamic> json) =>
      _$TrendTagsIllustFromJson(json);
}
