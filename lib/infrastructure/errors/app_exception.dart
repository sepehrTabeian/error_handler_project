sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException() : super('Network connection failed');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Unauthorized');
}

class ServerException extends AppException {
  final int? statusCode;
  final String? serverMessage;
  final String? code;

  const ServerException({
    this.statusCode,
    this.serverMessage,
    this.code,
  }) : super('Server error');
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors = const {},
  }) : super(message);
}

class ParsingException extends AppException {
  const ParsingException() : super('Parsing failed');
}

class UnknownException extends AppException {
  const UnknownException() : super('Unknown error');
}
class InvalidTokenException extends AppException {
  const InvalidTokenException() : super('Invalid token');
}

class UserIdNotFoundInTokenException extends AppException {
  const UserIdNotFoundInTokenException()
      : super('User id not found in token');
}