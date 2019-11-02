class RequestFailureInfo {
  String errorCode;
  String errorMessage;
  String dateTime;

  RequestFailureInfo({this.errorCode, this.errorMessage, this.dateTime});

  RequestFailureInfo.initialState() {
    errorCode = '';
    errorMessage = '';
    dateTime = '';
  }


  @override
  String toString() {
    return 'RequestFailureInfo{errorCode: $errorCode, errorMessage: $errorMessage, dateTime: $dateTime}';
  }

  @override
  int get hashCode =>
      errorCode.hashCode ^ errorMessage.hashCode ^ dateTime.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
          other is RequestFailureInfo &&
              errorCode == other.errorCode &&
              errorMessage == other.errorMessage &&
              dateTime == other.dateTime;
}
