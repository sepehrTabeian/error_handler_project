import 'package:error_handler_project/infrastructure/auth/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class SecureTokenStorage implements TokenStorage {

  final FlutterSecureStorage storage;

  SecureTokenStorage(this.storage);

  static const _accessTokenKey = 'access_token';

  static const _refreshTokenKey = 'refresh_token';

  @override

  Future<void> saveAccessToken(String token) {

    return storage.write(

      key: _accessTokenKey,

      value: token,

    );

  }

  @override

  Future<void> saveRefreshToken(String token) {

    return storage.write(

      key: _refreshTokenKey,

      value: token,

    );

  }

  @override

  Future<String?> getAccessToken() {

    return storage.read(key: _accessTokenKey);

  }

  @override

  Future<String?> getRefreshToken() {

    return storage.read(key: _refreshTokenKey);

  }

  @override

  Future<void> clearTokens() async {

    await storage.delete(key: _accessTokenKey);

    await storage.delete(key: _refreshTokenKey);

  }

}