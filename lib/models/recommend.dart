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

part 'recommend.g.dart';

@JsonSerializable()
class Recommend {
  List<Illusts> illusts;
  @JsonKey(name: 'ranking_illusts')
  List<Illusts>? rankingIllusts;
  @JsonKey(name: 'contest_exists')
  bool? contestExists;
  @JsonKey(name: 'privacy_policy')
  PrivacyPolicy? privacyPolicy;
  @JsonKey(name: 'next_url')
  String? nextUrl;

  Recommend(
      {required this.illusts,
      this.rankingIllusts,
      this.contestExists,
      this.privacyPolicy,
      this.nextUrl});

  factory Recommend.fromJson(Map<String, dynamic> json) =>
      _$RecommendFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendToJson(this);
}

class PrivacyPolicy {
  PrivacyPolicy();

  PrivacyPolicy.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}
