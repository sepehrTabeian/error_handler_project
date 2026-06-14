import '../entities/example_entity.dart';
import '../entities/example_request_entity.dart';
import '../repositories/example_repository.dart';
import '../../../../infrastructure/errors/app_failure.dart';
import '../../../../infrastructure/errors/result.dart';

/// Use case for creating a new example entity.
///
/// This is a domain layer use case and must remain framework-agnostic.
/// It encapsulates a single business rule: creating an example.
class CreateExampleUseCase {
  final ExampleRepository _repository;

  CreateExampleUseCase(this._repository);

  /// Executes the create example operation.
  ///
  /// Validates the request and delegates to the repository.
  /// Returns the result from the repository.
  Future<Result<ExampleEntity>> call(ExampleRequestEntity request) async {
    // Validation
    if (request.name.trim().isEmpty) {
      return const FailureResult(
        ValidationFailure(message: 'Name is required'),
      );
    }

    if (request.description.trim().isEmpty) {
      return const FailureResult(
        ValidationFailure(message: 'Description is required'),
      );
    }

    return _repository.createExample(request);
  }
}
