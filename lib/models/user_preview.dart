import 'dart:convert' show json;

import 'package:pixez/models/illust.dart';

class UserPreviewsResponse {
  List<UserPreviews> user_previews;
  String next_url;

  UserPreviewsResponse({
    this.user_previews,
    this.next_url,
  });

  factory UserPreviewsResponse.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<UserPreviews> user_previews =
        jsonRes['user_previews'] is List ? [] : null;
    if (user_previews != null) {
      for (var item in jsonRes['user_previews']) {
        if (item != null) {
          user_previews.add(UserPreviews.fromJson(item));
        }
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
    this.user,
    this.illusts,
    this.novels,
    this.is_muted,
  });

  factory UserPreviews.fromJson(jsonRes) {
    if (jsonRes == null) return null;
    List<Illusts> illusts = jsonRes['illusts'] is List ? [] : null;
    if (illusts != null) {
      for (var item in jsonRes['illusts']) {
        if (item != null) {
          illusts.add(Illusts.fromJson(item));
        }
      }
    }

    List<Object> novels = jsonRes['novels'] is List ? [] : null;
    if (novels != null) {
      for (var item in jsonRes['novels']) {
        if (item != null) {
          novels.add(item);
        }
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
