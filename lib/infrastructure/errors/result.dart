import 'package:error_handler_project/infrastructure/errors/app_failure.dart';

sealed class Result<T>{
  const Result();
}
class Success<T> extends Result<T>{
  final T data;
  const Success(this.data);
}
class FailureResult<T> extends Result<T>{
  final Failure failure;
  const FailureResult(this.failure);
}