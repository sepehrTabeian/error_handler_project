sealed class Failure {
  final String message;

  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('اتصال اینترنت را بررسی کنید');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('لطفا دوباره وارد شوید');
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'خطا در ارتباط با سرور',
  }) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure({
    required String message,
    this.fieldErrors = const {},
  }) : super(message);
}

class ParsingFailure extends Failure {
  const ParsingFailure() : super('خطا در پردازش اطلاعات');
}

class UserIdRequiredFailure extends Failure {
  const UserIdRequiredFailure() : super('اطلاعات کاربر آماده نیست');
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('خطای ناشناخته رخ داد');
}
