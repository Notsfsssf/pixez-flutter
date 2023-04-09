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
part 'user_preview.g.dart';

@JsonSerializable()
class UserPreviewsResponse {
  List<UserPreviews> user_previews;
  String? next_url;

  UserPreviewsResponse({
    required this.user_previews,
    this.next_url,
  });
  factory UserPreviewsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserPreviewsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreviewsResponseToJson(this);
}

@JsonSerializable()
class UserPreviews {
  User user;
  List<Illusts> illusts;
  List<UserPreviewsNovel> novels;
  bool is_muted;

  UserPreviews({
    required this.user,
    required this.illusts,
    required this.novels,
    required this.is_muted,
  });

  factory UserPreviews.fromJson(Map<String, dynamic> json) =>
      _$UserPreviewsFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreviewsToJson(this);
}

@JsonSerializable()
class UserPreviewsNovel {
  int id;
  String title;
  String? caption;
  @JsonKey(name: 'image_urls')
  ImageUrls imageUrls;
  
  UserPreviewsNovel({
    required this.id,
    required this.title,
    required this.caption,
    required this.imageUrls,
  });

  factory UserPreviewsNovel.fromJson(Map<String, dynamic> json) =>
      _$UserPreviewsNovelFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreviewsNovelToJson(this);
}
