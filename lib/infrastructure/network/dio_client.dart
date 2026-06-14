import 'package:dio/dio.dart';
import 'package:error_handler_project/infrastructure/auth/token_provider.dart';
import 'package:error_handler_project/infrastructure/network/auth_interseptor.dart';

class DioClient {
  final TokenProvider tokenProvider;

  DioClient(this.tokenProvider);

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(tokenProvider),
    );

    return dio;
  }
}