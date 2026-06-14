/// Abstract data source for example local operations.
abstract class ExampleLocalDataSource {
  Future<List<ExampleEntityDto>> getExamples();
  Future<void> saveExample(ExampleEntityDto example);
  Future<void> deleteExample(String id);
}

/// Implementation of example local data source.
///
/// In a real implementation, this would use a local database like Drift/SQLite
/// or Hive for offline storage.
class ExampleLocalDataSourceImpl implements ExampleLocalDataSource {
  // TODO: Implement with actual local database
  // For now, this is a placeholder
  
  final List<ExampleEntityDto> _cache = [];

  @override
  Future<List<ExampleEntityDto>> getExamples() async {
    return _cache;
  }

  @override
  Future<void> saveExample(ExampleEntityDto example) async {
    _cache.add(example);
  }

  @override
  Future<void> deleteExample(String id) async {
    _cache.removeWhere((e) => e.id == id);
  }
}
