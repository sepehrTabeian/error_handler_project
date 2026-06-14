import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';
import '../../../../infrastructure/errors/result.dart';

/// Use case for fetching all example entities.
///
/// This is a domain layer use case and must remain framework-agnostic.
/// It encapsulates a single business rule: fetching examples.
///
/// Use cases are the entry point for business logic from the presentation layer.
/// They orchestrate the flow of data between the presentation and data layers.
class GetExampleUseCase {
  final ExampleRepository _repository;

  GetExampleUseCase(this._repository);

  /// Executes the get examples operation.
  ///
  /// Delegates to the repository to fetch examples.
  /// Returns the result from the repository.
  Future<Result<List<ExampleEntity>>> call() {
    return _repository.getExamples();
  }
}
