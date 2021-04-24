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
//     final novelTextResponse = novelTextResponseFromJson(jsonString);
import 'package:json_annotation/json_annotation.dart';
part 'novel_text_response.g.dart';

@JsonSerializable()
class NovelTextResponse {
  @JsonKey(name: 'novel_marker')
  NovelMarker novelMarker;
  @JsonKey(name: 'novel_text')
  String novelText;
  @JsonKey(name: 'series_prev')
  TextNovel? seriesPrev;
  @JsonKey(name: 'series_next')
  TextNovel? seriesNext;

  NovelTextResponse({
    required this.novelMarker,
    required this.novelText,
    required this.seriesPrev,
    required this.seriesNext,
  });

  factory NovelTextResponse.fromJson(Map<String, dynamic> json) =>
      _$NovelTextResponseFromJson(json);
}

@JsonSerializable()
class NovelMarker {
  int? page;

  NovelMarker({
    this.page,
  });

  factory NovelMarker.fromJson(Map<String, dynamic> json) =>
      _$NovelMarkerFromJson(json);
}

@JsonSerializable()
class TextNovel {
  int? id;
  String? title;

  TextNovel({this.id,this.title});

  factory TextNovel.fromJson(Map<String, dynamic> json) =>
      _$TextNovelFromJson(json);
}
