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

import 'package:pixez/models/illust.dart';

class Recommend {
  List<Illusts> illusts;
  List<Illusts> rankingIllusts;
  bool contestExists;
  PrivacyPolicy privacyPolicy;
  String nextUrl;

  Recommend(
      {this.illusts,
      this.rankingIllusts,
      this.contestExists,
      this.privacyPolicy,
      this.nextUrl});

  Recommend.fromJson(Map<String, dynamic> json) {
    if (json['illusts'] != null) {
      illusts = new List<Illusts>();
      json['illusts'].forEach((v) {
        illusts.add(new Illusts.fromJson(v));
      });
    }
    if (json['ranking_illusts'] != null) {
      rankingIllusts = new List<Illusts>();
      json['ranking_illusts'].forEach((v) {
        rankingIllusts.add(new Illusts.fromJson(v));
      });
    }
    contestExists = json['contest_exists'];
    privacyPolicy = json['privacy_policy'] != null
        ? new PrivacyPolicy.fromJson(json['privacy_policy'])
        : null;
    nextUrl = json['next_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.illusts != null) {
      data['illusts'] = this.illusts.map((v) => v.toJson()).toList();
    }
    if (this.rankingIllusts != null) {
      data['ranking_illusts'] =
          this.rankingIllusts.map((v) => v.toJson()).toList();
    }
    data['contest_exists'] = this.contestExists;
    if (this.privacyPolicy != null) {
      data['privacy_policy'] = this.privacyPolicy.toJson();
    }
    data['next_url'] = this.nextUrl;
    return data;
  }
}

class PrivacyPolicy {
  PrivacyPolicy();

  PrivacyPolicy.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}
