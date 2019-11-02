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
    required this.error,
    required this.message,
    required this.body,
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
    required this.userAccount,
    required this.password,
    required this.deviceToken,
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
