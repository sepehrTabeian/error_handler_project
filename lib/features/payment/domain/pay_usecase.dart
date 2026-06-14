import 'package:error_handler_project/features/payment/domain/entities/payment_entity.dart';
import 'package:error_handler_project/features/payment/domain/entities/payment_request_entity.dart';
import 'package:error_handler_project/features/payment/domain/repositories/payment_repository.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';
import 'package:error_handler_project/infrastructure/session/user_context_service.dart';

class PayUseCase {
  final PaymentRepository repository;
  final UserContextService userContextService;

  PayUseCase({
    required this.repository,
    required this.userContextService,
  });

  Future<Result<PaymentEntity>> call(
      PaymentRequestEntity request,
      ) async {
    final userId = userContextService.userId;

    if (userId == null || userId.isEmpty) {
      return const FailureResult(
        UserIdRequiredFailure(),
      );
    }

    final requestWithUserId = request.copyWith(
      userId: userId,
    );

    return repository.pay(requestWithUserId);
  }
}