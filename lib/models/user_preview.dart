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

class UserPreviewsResponse {
  List<UserPreviews> user_previews;
  String next_url;

  UserPreviewsResponse({
    required this.user_previews,
    required this.next_url,
  });

  factory UserPreviewsResponse.fromJson(jsonRes) {
    List<UserPreviews> user_previews = [];
    for (var item in jsonRes['user_previews']) {
      if (item != null) {
        user_previews.add(UserPreviews.fromJson(item));
      }
    }

    return UserPreviewsResponse(
      user_previews: user_previews,
      next_url: jsonRes['next_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user_previews': user_previews,
        'next_url': next_url,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class UserPreviews {
  User user;
  List<Illusts> illusts;
  List<Object> novels;
  bool is_muted;

  UserPreviews({
    required this.user,
    required this.illusts,
    required this.novels,
    required this.is_muted,
  });

  factory UserPreviews.fromJson(jsonRes) {
    List<Illusts> illusts = [];
    for (var item in jsonRes['illusts']) {
      if (item != null) {
        illusts.add(Illusts.fromJson(item));
      }
    }

    List<Object> novels = [];
    for (var item in jsonRes['novels']) {
      if (item != null) {
        novels.add(item);
      }
    }

    return UserPreviews(
      user: User.fromJson(jsonRes['user']),
      illusts: illusts,
      novels: novels,
      is_muted: jsonRes['is_muted'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'illusts': illusts,
        'novels': novels,
        'is_muted': is_muted,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
