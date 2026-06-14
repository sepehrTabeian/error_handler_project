import '../entities/example_entity.dart';
import '../entities/example_request_entity.dart';
import '../../../../infrastructure/errors/result.dart';

/// Repository abstraction for example feature operations.
///
/// This is a domain layer interface and must remain framework-agnostic.
/// The actual implementation will be in the data layer.
///
/// This follows the Dependency Inversion Principle: high-level modules
/// (use cases) depend on abstractions, not concrete implementations.
abstract class ExampleRepository {
  /// Fetches all example entities.
  ///
  /// Returns [Success] with list of entities if successful.
  /// Returns [FailureResult] with error message if failed.
  Future<Result<List<ExampleEntity>>> getExamples();

  /// Creates a new example entity.
  ///
  /// Returns [Success] with created entity if successful.
  /// Returns [FailureResult] with error message if failed.
  Future<Result<ExampleEntity>> createExample(ExampleRequestEntity request);

  /// Updates an existing example entity.
  ///
  /// Returns [Success] with updated entity if successful.
  /// Returns [FailureResult] with error message if failed.
  Future<Result<ExampleEntity>> updateExample(ExampleEntity entity);

  /// Deletes an example entity.
  ///
  /// Returns [Success] if deletion was successful.
  /// Returns [FailureResult] with error message if failed.
  Future<Result<void>> deleteExample(String id);
}
