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

import 'dart:convert';

import 'package:pixez/models/novel_recom_response.dart';

NovelTextResponse novelTextResponseFromJson(String str) =>
    NovelTextResponse.fromJson(json.decode(str));

String novelTextResponseToJson(NovelTextResponse data) =>
    json.encode(data.toJson());

class NovelTextResponse {
  NovelMarker novelMarker;
  String novelText;
  Novel seriesPrev;
  Novel seriesNext;

  NovelTextResponse({
    this.novelMarker,
    this.novelText,
    this.seriesPrev,
    this.seriesNext,
  });

  factory NovelTextResponse.fromJson(Map<String, dynamic> json) =>
      NovelTextResponse(
        novelMarker: NovelMarker.fromJson(json["novel_marker"]),
        novelText: json["novel_text"],
        seriesPrev: json['series_prev'] != null &&
                json.containsKey('series_prev') &&
                json['series_prev'].isNotEmpty
            ? Novel.fromJson(json["series_prev"])
            : null,
        seriesNext: json['series_next'] != null &&
                json.containsKey('series_next') &&
                json['series_next'].isNotEmpty //绝了
            ? Novel.fromJson(json["series_next"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "novel_marker": novelMarker.toJson(),
        "novel_text": novelText,
        "series_prev": seriesPrev.toJson(),
        "series_next": seriesNext.toJson(),
      };
}

class NovelMarker {
  int page;

  NovelMarker({
    this.page,
  });

  factory NovelMarker.fromJson(Map<String, dynamic> json) => NovelMarker(
        page: json["page"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
      };
}
