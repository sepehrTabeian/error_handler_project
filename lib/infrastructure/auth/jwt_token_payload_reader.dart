import 'dart:convert';

import 'package:error_handler_project/infrastructure/auth/token_payload_reader.dart';
import 'package:error_handler_project/infrastructure/errors/app_exception.dart';


class JwtTokenPayloadReader implements TokenPayloadReader {
  @override
  Map<String, dynamic> readPayload(String token) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw const InvalidTokenException();
    }

    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      final json = jsonDecode(decoded);

      if (json is! Map<String, dynamic>) {
        throw const InvalidTokenException();
      }

      return json;
    } catch (_) {
      throw const InvalidTokenException();
    }
  }
}