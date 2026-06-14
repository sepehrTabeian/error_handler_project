import 'package:error_handler_project/infrastructure/errors/app_exception.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure.dart';

class FailureMapper {
  Failure map(Object error) {
    if (error is NetworkException) {
      return const NetworkFailure();
    }

    if (error is UnauthorizedException) {
      return const UnauthorizedFailure();
    }

    if (error is ServerException) {
      return ServerFailure(
        message: error.serverMessage ?? 'خطا در ارتباط با سرور',
      );
    }

    if (error is ValidationException) {
      return ValidationFailure(
        message: error.message,
        fieldErrors: error.fieldErrors,
      );
    }

    if (error is ParsingException) {
      return const ParsingFailure();
    }

    return const UnknownFailure();
  }
}