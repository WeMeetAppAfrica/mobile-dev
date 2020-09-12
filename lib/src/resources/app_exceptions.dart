class AppException implements Exception {
  final _message;
  final _prefix;
  
AppException([this._message, this._prefix]);
  
String toString() {
    return "$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class FormatException extends AppException {
  FormatException([message]) : super(message, "Invalid Format: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}