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
//     final accountEditResponse = accountEditResponseFromJson(jsonString);

import 'dart:convert';

AccountEditResponse accountEditResponseFromJson(String str) => AccountEditResponse.fromJson(json.decode(str));

String accountEditResponseToJson(AccountEditResponse data) => json.encode(data.toJson());

class AccountEditResponse {
    bool error;
    String message;
    Body body;

    AccountEditResponse({
        required this.error,
        required this.message,
        required this.body,
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
        required this.isSucceed,
        required this.validationErrors,
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
