import 'package:error_handler_project/features/payment/data/datasource/payment_remote_datasource.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure_mapper.dart';

import '../../../../infrastructure/errors/result.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../dto/payment_request_dto.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final FailureMapper failureMapper;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.failureMapper,
  });

  @override
  Future<Result<PaymentEntity>> pay(PaymentRequestEntity request) async {
    try {
      final dto = await remoteDataSource.pay(
        PaymentRequestDto.fromEntity(request),
      );

      return Success(dto.toEntity());
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }
}