import '../../../../infrastructure/errors/result.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_request_entity.dart';

abstract class PaymentRepository {
  Future<Result<PaymentEntity>> pay(PaymentRequestEntity request);
}