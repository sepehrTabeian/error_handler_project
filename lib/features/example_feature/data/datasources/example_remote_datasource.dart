import 'package:dio/dio.dart';

import '../../../../infrastructure/errors/dio_error_mapper.dart';
import '../dto/example_entity_dto.dart';
import '../dto/example_request_dto.dart';

/// Abstract data source for example remote operations.
abstract class ExampleRemoteDataSource {
  Future<List<ExampleEntityDto>> getExamples();
  Future<ExampleEntityDto> createExample(ExampleRequestDto request);
  Future<ExampleEntityDto> updateExample(ExampleEntityDto entity);
  Future<void> deleteExample(String id);
}

/// Dio-based implementation of example remote data source.
class ExampleRemoteDataSourceImpl implements ExampleRemoteDataSource {
  final Dio dio;
  final DioErrorMapper errorMapper;

  ExampleRemoteDataSourceImpl({
    required this.dio,
    required this.errorMapper,
  });

  @override
  Future<List<ExampleEntityDto>> getExamples() async {
    try {
      final response = await dio.get('/examples');
      final list = response.data as List;
      return list
          .map((json) => ExampleEntityDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw errorMapper.map(error);
    }
  }

  @override
  Future<ExampleEntityDto> createExample(ExampleRequestDto request) async {
    try {
      final response = await dio.post(
        '/examples',
        data: request.toJson(),
      );
      return ExampleEntityDto.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw errorMapper.map(error);
    }
  }

  @override
  Future<ExampleEntityDto> updateExample(ExampleEntityDto entity) async {
    try {
      final response = await dio.put(
        '/examples/${entity.id}',
        data: entity.toJson(),
      );
      return ExampleEntityDto.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw errorMapper.map(error);
    }
  }

  @override
  Future<void> deleteExample(String id) async {
    try {
      await dio.delete('/examples/$id');
    } catch (error) {
      throw errorMapper.map(error);
    }
  }
}
