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
part 'user_detail.g.dart';

@JsonSerializable()
class UserDetail {
  User user;
  Profile profile;
  Profile_publicity profile_publicity;
  Workspace workspace;

  UserDetail({
    required this.user,
    required this.profile,
    required this.profile_publicity,
    required this.workspace,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) =>
      _$UserDetailFromJson(json);
}

@JsonSerializable()
class Profile {
  String? webpage;
  String? gender;
  String? birth;
  String? birth_day;
  int? birth_year;
  String? region;
  int? address_id;
  String? country_code;
  String? job;
  int? job_id;
  int total_follow_users;
  int total_mypixiv_users;
  int total_illusts;
  int total_manga;
  int total_novels;
  int total_illust_bookmarks_public;
  int total_illust_series;
  int total_novel_series;
  String? background_image_url;
  String? twitter_account;
  String? twitter_url;
  String? pawoo_url;
  bool is_premium;
  bool is_using_custom_profile_image;

  Profile({
    required this.webpage,
    required this.gender,
    required this.birth,
    required this.birth_day,
    required this.birth_year,
    required this.region,
    required this.address_id,
    required this.country_code,
    required this.job,
    required this.job_id,
    required this.total_follow_users,
    required this.total_mypixiv_users,
    required this.total_illusts,
    required this.total_manga,
    required this.total_novels,
    required this.total_illust_bookmarks_public,
    required this.total_illust_series,
    required this.total_novel_series,
    this.background_image_url,
    this.twitter_account,
    this.twitter_url,
    this.pawoo_url,
    required this.is_premium,
    required this.is_using_custom_profile_image,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

@JsonSerializable()
class Profile_publicity {
  String gender;
  String region;
  String birth_day;
  String birth_year;
  String job;
  bool pawoo;

  Profile_publicity({
    required this.gender,
    required this.region,
    required this.birth_day,
    required this.birth_year,
    required this.job,
    required this.pawoo,
  });

  factory Profile_publicity.fromJson(Map<String, dynamic> json) =>
      _$Profile_publicityFromJson(json);
}

@JsonSerializable()
class Workspace {
  String pc;
  String monitor;
  String tool;
  String scanner;
  String tablet;
  String mouse;
  String printer;
  String desktop;
  String music;
  String desk;
  String chair;
  String comment;
  Object? workspace_image_url;

  Workspace({
    required this.pc,
    required this.monitor,
    required this.tool,
    required this.scanner,
    required this.tablet,
    required this.mouse,
    required this.printer,
    required this.desktop,
    required this.music,
    required this.desk,
    required this.chair,
    required this.comment,
    this.workspace_image_url,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);
}
