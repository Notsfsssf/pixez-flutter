// To parse this JSON data, do
//
//     final createUserResponse = createUserResponseFromJson(jsonString);

import 'dart:convert';

CreateUserResponse createUserResponseFromJson(String str) =>
    CreateUserResponse.fromJson(json.decode(str));

String createUserResponseToJson(CreateUserResponse data) =>
    json.encode(data.toJson());

class CreateUserResponse {
  bool error;
  String message;
  Body body;

  CreateUserResponse({
    this.error,
    this.message,
    this.body,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) =>
      CreateUserResponse(
        error: json["error"],
        message: json["message"],
        body: Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "body": body.toJson(),
      };
}

class Body {
  String userAccount;
  String password;
  String deviceToken;

  Body({
    this.userAccount,
    this.password,
    this.deviceToken,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        userAccount: json["user_account"],
        password: json["password"],
        deviceToken: json["device_token"],
      );

  Map<String, dynamic> toJson() => {
        "user_account": userAccount,
        "password": password,
        "device_token": deviceToken,
      };
}
