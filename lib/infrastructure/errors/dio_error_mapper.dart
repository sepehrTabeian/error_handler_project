import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:error_handler_project/infrastructure/errors/api_error_response.dart';
import 'package:error_handler_project/infrastructure/errors/app_exception.dart';


class DioErrorMapper {
  AppException map(Object error) {
    if (error is FormatException) {
      return const ParsingException();
    }

    if (error is! DioException) {
      return const UnknownException();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.badCertificate:
        return const ServerException(
          serverMessage: 'Bad certificate',
        );

      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const UnknownException();
    }
  }

  AppException _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final apiError = _tryParseApiError(error.response?.data);

    if (statusCode == 401) {
      return const UnauthorizedException();
    }

    if (statusCode == 422 || statusCode == 400) {
      return ValidationException(
        message: apiError?.message ?? 'Validation failed',
        fieldErrors: apiError?.fieldErrors ?? const {},
      );
    }

    return ServerException(
      statusCode: statusCode,
      serverMessage: apiError?.message,
      code: apiError?.code,
    );
  }

  ApiErrorResponse? _tryParseApiError(Object? data) {
    try {
      if (data is Map<String, dynamic>) {
        return ApiErrorResponse.fromJson(data);
      }

      if (data is String && data.isNotEmpty) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return ApiErrorResponse.fromJson(decoded);
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}