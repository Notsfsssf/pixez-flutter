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
import 'dart:convert' show json;

import 'package:pixez/models/illust.dart';

class TrendingTag {
  List<Trend_tags> trend_tags;

  TrendingTag({
    required this.trend_tags,
  });

  factory TrendingTag.fromJson(jsonRes) {
    List<Trend_tags> trend_tags = [];
    for (var item in jsonRes['trend_tags']) {
      if (item != null) {
        trend_tags.add(Trend_tags.fromJson(item));
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
    required this.tag,
    required this.illust,
  });

  factory Trend_tags.fromJson(jsonRes) => Trend_tags(
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
