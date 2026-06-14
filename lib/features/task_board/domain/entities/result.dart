/// Result type for handling success and failure cases.
/// 
/// This is a domain entity and must remain framework-agnostic.
/// Used by use cases to return either a successful result or a failure with an error message.
sealed class Result<T> {
  const Result();
}

/// Represents a successful operation with a value of type T.
class Success<T> extends Result<T> {
  final T value;
  
  const Success(this.value);
}

/// Represents a failed operation with an error message.
class FailureResult<T> extends Result<T> {
  final String message;
  
  const FailureResult(this.message);
}
