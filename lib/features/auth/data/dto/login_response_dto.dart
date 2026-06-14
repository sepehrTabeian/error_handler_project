import 'package:error_handler_project/features/auth/domain/entity/auth_session_entity.dart';

class LoginResponseDto {
  final String accessToken;
  final String? refreshToken;

  const LoginResponseDto({
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
    );
  }
}

extension LoginResponseDtoMapper on LoginResponseDto {
  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}