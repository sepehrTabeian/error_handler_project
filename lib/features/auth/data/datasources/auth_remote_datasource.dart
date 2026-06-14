import 'package:dio/dio.dart';
import 'package:error_handler_project/infrastructure/errors/dio_error_mapper.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseDto> login(LoginRequestDto request);
}
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final DioErrorMapper errorMapper;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.errorMapper,
  });

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await dio.post(
        '/login',
        data: request.toJson(),
      );

      return LoginResponseDto.fromJson(response.data);
    } catch (error) {
      throw errorMapper.map(error);
    }
  }
}