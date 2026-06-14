import 'package:error_handler_project/features/auth/domain/entity/login_request_entity.dart';


class LoginRequestDto {
  final String email;
  final String password;

  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  factory LoginRequestDto.fromEntity(LoginRequestEntity entity) {
    return LoginRequestDto(
      email: entity.email,
      password: entity.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}