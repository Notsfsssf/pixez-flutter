// To parse this JSON data, do
//
//     final accountEditResponse = accountEditResponseFromJson(jsonString);

import 'dart:convert';

AccountEditResponse accountEditResponseFromJson(String str) => AccountEditResponse.fromJson(json.decode(str));

String accountEditResponseToJson(AccountEditResponse data) => json.encode(data.toJson());

class AccountEditResponse {
    bool error;
    String message;
    Body body;

    AccountEditResponse({
        this.error,
        this.message,
        this.body,
    });

    factory AccountEditResponse.fromJson(Map<String, dynamic> json) => AccountEditResponse(
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
    bool isSucceed;
    ValidationErrors validationErrors;

    Body({
        this.isSucceed,
        this.validationErrors,
    });

    factory Body.fromJson(Map<String, dynamic> json) => Body(
        isSucceed: json["is_succeed"],
        validationErrors: ValidationErrors.fromJson(json["validation_errors"]),
    );

    Map<String, dynamic> toJson() => {
        "is_succeed": isSucceed,
        "validation_errors": validationErrors.toJson(),
    };
}

class ValidationErrors {
    ValidationErrors();

    factory ValidationErrors.fromJson(Map<String, dynamic> json) => ValidationErrors(
    );

    Map<String, dynamic> toJson() => {
    };
}
