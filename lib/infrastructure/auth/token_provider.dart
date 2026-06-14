import 'package:error_handler_project/infrastructure/auth/token_storage.dart';

abstract class TokenProvider {
  Future<String?> getAccessToken();
}
class TokenProviderImpl implements TokenProvider {
  final TokenStorage tokenStorage;

  TokenProviderImpl(this.tokenStorage);

  @override
  Future<String?> getAccessToken() {
    return tokenStorage.getAccessToken();
  }
}