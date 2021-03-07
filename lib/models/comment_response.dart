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
//     final commentResponse = commentResponseFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';

part 'comment_response.g.dart';

@JsonSerializable()
class CommentResponse {
  @JsonKey(name: "total_comments")
  int totalComments;
  List<Comment> comments;
  @JsonKey(name: "next_url")
  String? nextUrl;

  CommentResponse({
    required this.totalComments,
    required this.comments,
    this.nextUrl,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CommentResponseToJson(this);
}

@JsonSerializable()
class Comment {
  int? id;
  String? comment;
  DateTime? date;
  User? user;
  @JsonKey(name: 'parent_comment')
  Comment? parentComment;

  Comment({
    this.id,
    this.comment,
    this.date,
    this.user,
    this.parentComment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class User {
  int id;
  String name;
  String account;
  @JsonKey(name: 'profile_image_urls')
  ProfileImageUrls profileImageUrls;

  User({
    required this.id,
    required this.name,
    required this.account,
    required this.profileImageUrls,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

class ProfileImageUrls {
  String medium;

  ProfileImageUrls({
    required this.medium,
  });

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      ProfileImageUrls(
        medium: json["medium"],
      );

  Map<String, dynamic> toJson() => {
        "medium": medium,
      };
}
