import 'package:error_handler_project/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:error_handler_project/features/auth/data/dto/login_request_dto.dart';
import 'package:error_handler_project/features/auth/domain/entity/login_request_entity.dart';
import 'package:error_handler_project/infrastructure/auth/token_storage.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure_mapper.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';

abstract class AuthRepository {

  Future<Result<void>> login(LoginRequestEntity request);

  Future<void> logout();

}

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDataSource remoteDataSource;

  final TokenStorage tokenStorage;

  final FailureMapper failureMapper;

  AuthRepositoryImpl({

    required this.remoteDataSource,

    required this.tokenStorage,

    required this.failureMapper,

  });

  @override

  Future<Result<void>> login(LoginRequestEntity request) async {

    try {

      final response = await remoteDataSource.login(

        LoginRequestDto.fromEntity(request),

      );

      await tokenStorage.saveAccessToken(response.accessToken);

      if (response.refreshToken != null) {

        await tokenStorage.saveRefreshToken(response.refreshToken!);

      }

      return const Success(null);

    } catch (error) {

      return FailureResult(failureMapper.map(error));

    }

  }

  @override

  Future<void> logout() async {

    await tokenStorage.clearTokens();

  }

}