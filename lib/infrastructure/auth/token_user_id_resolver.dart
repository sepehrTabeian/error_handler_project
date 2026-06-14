import 'token_provider.dart';
import 'token_payload_reader.dart';
import 'user_id_resolver.dart';

class TokenUserIdResolver implements UserIdResolver {
  final TokenProvider tokenProvider;
  final TokenPayloadReader tokenPayloadReader;

  TokenUserIdResolver({
    required this.tokenProvider,
    required this.tokenPayloadReader,
  });

  @override
  Future<String?> resolveUserId() async {
    final token = await tokenProvider.getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final payload = tokenPayloadReader.readPayload(token);

    final userId =
        payload['user_id'] ??
            payload['userId'] ??
            payload['sub'] ??
            payload['id'];

    return userId?.toString();
  }
}