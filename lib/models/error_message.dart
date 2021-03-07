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
import 'dart:convert' show json;

class ErrorMessage {
  Error error;

  ErrorMessage({
    required this.error,
  });

  factory ErrorMessage.fromJson(jsonRes) => ErrorMessage(
        error: Error.fromJson(jsonRes['error']),
      );

  Map<String, dynamic> toJson() => {
        'error': error,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}

class Error {
  String user_message;
  String message;
  String reason;
  Object user_message_details;

  Error({
    required this.user_message,
    required this.message,
    required this.reason,
    required this.user_message_details,
  });

  factory Error.fromJson(jsonRes) => Error(
        user_message: jsonRes['user_message'],
        message: jsonRes['message'],
        reason: jsonRes['reason'],
        user_message_details: jsonRes['user_message_details'],
      );

  Map<String, dynamic> toJson() => {
        'user_message': user_message,
        'message': message,
        'reason': reason,
        'user_message_details': user_message_details,
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
