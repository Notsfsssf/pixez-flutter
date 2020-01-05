// To parse this JSON data, do
//
//     final commentResponse = commentResponseFromJson(jsonString);

import 'dart:convert';

CommentResponse commentResponseFromJson(String str) =>
    CommentResponse.fromJson(json.decode(str));

String commentResponseToJson(CommentResponse data) =>
    json.encode(data.toJson());

class CommentResponse {
  int totalComments;
  List<Comment> comments;
  String nextUrl;

  CommentResponse({
    this.totalComments,
    this.comments,
    this.nextUrl,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      CommentResponse(
        totalComments: json["total_comments"],
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        nextUrl: json["next_url"],
      );

  Map<String, dynamic> toJson() => {
        "total_comments": totalComments,
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "next_url": nextUrl,
      };
}

class Comment {
  int id;
  String comment;
  DateTime date;
  User user;
  Comment parentComment;

  Comment({
    this.id,
    this.comment,
    this.date,
    this.user,
    this.parentComment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"] == null ? null : json["id"],
        comment: json["comment"] == null ? null : json["comment"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        parentComment: json["parent_comment"] == null
            ? null
            : Comment.fromJson(json["parent_comment"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "comment": comment == null ? null : comment,
        "date": date == null ? null : date.toIso8601String(),
        "user": user == null ? null : user.toJson(),
        "parent_comment": parentComment == null ? null : parentComment.toJson(),
      };
}

class User {
  int id;
  String name;
  String account;
  ProfileImageUrls profileImageUrls;

  User({
    this.id,
    this.name,
    this.account,
    this.profileImageUrls,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        account: json["account"],
        profileImageUrls: ProfileImageUrls.fromJson(json["profile_image_urls"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "account": account,
        "profile_image_urls": profileImageUrls.toJson(),
      };
}

class ProfileImageUrls {
  String medium;

  ProfileImageUrls({
    this.medium,
  });

  factory ProfileImageUrls.fromJson(Map<String, dynamic> json) =>
      ProfileImageUrls(
        medium: json["medium"],
      );

  Map<String, dynamic> toJson() => {
        "medium": medium,
      };
}
