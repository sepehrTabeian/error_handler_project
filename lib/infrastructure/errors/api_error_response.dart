/*{
  "message": "Validation failed",
  "code": "VALIDATION_ERROR",
  "errors": {
    "email": ["Email is invalid"],
    "password": ["Password is too short"]
  }
}*/
class ApiErrorResponse {
  final String? message;
  final String? code;

  final Map<String, List<String>> fieldErrors;

  const ApiErrorResponse({
    this.message,
    this.code,
    this.fieldErrors = const {},
  });

  factory ApiErrorResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawErrors =
    json['errors'] as Map<String, dynamic>?;

    return ApiErrorResponse(
      message: json['message'] as String?,
      code: json['code'] as String?,
      fieldErrors: _parseErrors(rawErrors),
    );
  }

  static Map<String, List<String>> _parseErrors(
      Map<String, dynamic>? raw,
      ) {
    if (raw == null) {
      return {};
    }

    return raw.map(
          (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      ),
    );
  }
}