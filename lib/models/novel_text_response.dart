// To parse this JSON data, do
//
//     final novelTextResponse = novelTextResponseFromJson(jsonString);

import 'dart:convert';

import 'package:pixez/models/novel_recom_response.dart';

NovelTextResponse novelTextResponseFromJson(String str) => NovelTextResponse.fromJson(json.decode(str));

String novelTextResponseToJson(NovelTextResponse data) => json.encode(data.toJson());

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

  factory NovelTextResponse.fromJson(Map<String, dynamic> json) => NovelTextResponse(
    novelMarker: NovelMarker.fromJson(json["novel_marker"]),
    novelText: json["novel_text"],
    seriesPrev: Novel.fromJson(json["series_prev"]),
    seriesNext: Novel.fromJson(json["series_next"]),
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


