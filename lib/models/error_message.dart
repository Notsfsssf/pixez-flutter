import 'dart:convert' show json;

class ErrorMessage {
  Error error;

  ErrorMessage({
    this.error,
  });


  factory ErrorMessage.fromJson(jsonRes)=>
      jsonRes == null ? null : ErrorMessage(
        error: Error.fromJson(jsonRes['error']),
      );

  Map<String, dynamic> toJson() =>
      {
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
    this.user_message,
    this.message,
    this.reason,
    this.user_message_details,
  });


  factory Error.fromJson(jsonRes)=>
      jsonRes == null ? null : Error(user_message: jsonRes['user_message'],
        message: jsonRes['message'],
        reason: jsonRes['reason'],
        user_message_details: jsonRes['user_message_details'],
      );

  Map<String, dynamic> toJson() =>
      {
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