import 'dart:convert' show json;

import 'package:pixez/models/illust.dart';

class TrendingTag {
  List<Trend_tags> trend_tags;

  TrendingTag({
    this.trend_tags,
  });

  factory TrendingTag.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<Trend_tags> trend_tags = jsonRes['trend_tags'] is List ? [] : null;
    if (trend_tags != null) {
      for (var item in jsonRes['trend_tags']) {
        if (item != null) {
          trend_tags.add(Trend_tags.fromJson(item));
        }
      }
    }

    return TrendingTag(
      trend_tags: trend_tags,
    );
  }
  Map<String, dynamic> toJson() => {
        'trend_tags': trend_tags,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Trend_tags {
  String tag;
  Illusts illust;

  Trend_tags({
    this.tag,
    this.illust,
  });

  factory Trend_tags.fromJson(jsonRes) => jsonRes == null
      ? null
      : Trend_tags(
          tag: jsonRes['tag'],
          illust: Illusts.fromJson(jsonRes['illust']),
        );
  Map<String, dynamic> toJson() => {
        'tag': tag,
        'illust': illust,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
