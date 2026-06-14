import 'package:error_handler_project/features/auth/domain/entity/login_request_entity.dart';
import 'package:error_handler_project/features/auth/domain/repositories/repository.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure.dart';

import '../../../../infrastructure/errors/result.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<void>> call(LoginRequestEntity request) {
    if (request.email.trim().isEmpty) {
      return Future.value(
        const FailureResult(
          ValidationFailure(
            message: 'ایمیل الزامی است',
          ),
        ),
      );
    }

    if (request.password.isEmpty) {
      return Future.value(
        const FailureResult(
          ValidationFailure(
            message: 'رمز عبور الزامی است',
          ),
        ),
      );
    }

    return repository.login(request);
  }
}