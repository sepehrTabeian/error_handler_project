import 'package:dio/dio.dart';

import '../../../../infrastructure/errors/dio_error_mapper.dart';
import '../dto/payment_request_dto.dart';
import '../dto/payment_response_dto.dart';

abstract class PaymentRemoteDataSource {

  Future<PaymentResponseDto> pay(PaymentRequestDto request);

}
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;
  final DioErrorMapper errorMapper;

  PaymentRemoteDataSourceImpl({
    required this.dio,
    required this.errorMapper,
  });

  @override
  Future<PaymentResponseDto> pay(PaymentRequestDto request) async {
    try {
      final response = await dio.post(
        '/payment',
        data: request.toJson(),
      );

      return PaymentResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (error) {
      throw errorMapper.map(error);
    }
  }
}