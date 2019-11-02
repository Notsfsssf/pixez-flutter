
class ErrorMessage {
  bool hasError;
  Errors errors;

  ErrorMessage({this.hasError, this.errors});

  ErrorMessage.fromJson(Map<String, dynamic> json) {
    hasError = json['has_error'];
    errors =
    json['errors'] != null ? new Errors.fromJson(json['errors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['has_error'] = this.hasError;
    if (this.errors != null) {
      data['errors'] = this.errors.toJson();
    }
    return data;
  }
}

class Errors {
  System system;

  Errors({this.system});

  Errors.fromJson(Map<String, dynamic> json) {
    system =
    json['system'] != null ? new System.fromJson(json['system']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.system != null) {
      data['system'] = this.system.toJson();
    }
    return data;
  }
}

class System {
  String message;
  int code;

  System({this.message, this.code});

  System.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}