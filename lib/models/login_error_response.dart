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
//     final loginErrorResponse = loginErrorResponseFromJson(jsonString);
// @dart=2.9
import 'dart:convert';

LoginErrorResponse loginErrorResponseFromJson(String str) => LoginErrorResponse.fromJson(json.decode(str));

String loginErrorResponseToJson(LoginErrorResponse data) => json.encode(data.toJson());

class LoginErrorResponse {
  bool hasError;
  Errors errors;

  LoginErrorResponse({
    this.hasError,
    this.errors,
  });

  factory LoginErrorResponse.fromJson(Map<String, dynamic> json) => LoginErrorResponse(
    hasError: json["has_error"],
    errors: Errors.fromJson(json["errors"]),
  );

  Map<String, dynamic> toJson() => {
    "has_error": hasError,
    "errors": errors.toJson(),
  };
}

class Errors {
  System system;

  Errors({
    this.system,
  });

  factory Errors.fromJson(Map<String, dynamic> json) => Errors(
    system: System.fromJson(json["system"]),
  );

  Map<String, dynamic> toJson() => {
    "system": system.toJson(),
  };
}

class System {
  String message;
  int code;

  System({
    this.message,
    this.code,
  });

  factory System.fromJson(Map<String, dynamic> json) => System(
    message: json["message"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
  };
}
