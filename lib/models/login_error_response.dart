// To parse this JSON data, do
//
//     final loginErrorResponse = loginErrorResponseFromJson(jsonString);

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
