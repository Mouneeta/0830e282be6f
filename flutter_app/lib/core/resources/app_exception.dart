class AppException implements Exception {
  final String? _message;
  final String? _prefix;
  final int _responseCode;
  final dynamic _responseData;

  AppException(
      this._responseCode, [
        this._message,
        this._prefix,
        this._responseData,
      ]);

  @override
  String toString() {
    return "$_prefix$_message";
  }

  int getErrorCode() => _responseCode;

  dynamic getResponseBody() => _responseData;
}

class FetchDataException extends AppException {
  FetchDataException(int responseCode, [String? message, dynamic responseData])
      : super(responseCode, message, "", responseData);
}

class BadRequestException extends AppException {
  BadRequestException(int responseCode, [message, dynamic responseData])
      : super(responseCode, message, "", responseData);
}

class UnauthorisedException extends AppException {
  UnauthorisedException(int responseCode, [message, dynamic responseData])
      : super(responseCode, message, "Unauthorised: ", responseData);
}

class InvalidInputException extends AppException {
  InvalidInputException(int responseCode,
      [String? message, dynamic responseData])
      : super(responseCode, message, "Invalid Input: ", responseData);
}
