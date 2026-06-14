import '../../domain/entities/example_entity.dart';
import '../../domain/entities/example_request_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_local_datasource.dart';
import '../datasources/example_remote_datasource.dart';
import '../dto/example_entity_dto.dart';
import '../dto/example_request_dto.dart';
import '../../../../infrastructure/errors/app_failure_mapper.dart';
import '../../../../infrastructure/errors/result.dart';

/// Implementation of ExampleRepository.
///
/// This is in the data layer and can use framework-specific dependencies
/// like Dio, HTTP clients, storage, etc.
class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDataSource remoteDataSource;
  final ExampleLocalDataSource localDataSource;
  final FailureMapper failureMapper;

  ExampleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.failureMapper,
  });

  @override
  Future<Result<List<ExampleEntity>>> getExamples() async {
    try {
      final dtos = await remoteDataSource.getExamples();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Success(entities);
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }

  @override
  Future<Result<ExampleEntity>> createExample(
      ExampleRequestEntity request) async {
    try {
      final dto = await remoteDataSource.createExample(
        ExampleRequestDto.fromEntity(request),
      );
      await localDataSource.saveExample(dto);
      return Success(dto.toEntity());
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }

  @override
  Future<Result<ExampleEntity>> updateExample(ExampleEntity entity) async {
    try {
      final dto = ExampleEntityDto.fromEntity(entity);
      final updatedDto = await remoteDataSource.updateExample(dto);
      return Success(updatedDto.toEntity());
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }

  @override
  Future<Result<void>> deleteExample(String id) async {
    try {
      await remoteDataSource.deleteExample(id);
      await localDataSource.deleteExample(id);
      return const Success(null);
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }
}
