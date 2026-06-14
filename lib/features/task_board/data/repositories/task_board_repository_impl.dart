import '../../domain/entities/result.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_board_repository.dart';

/// Implementation of TaskBoardRepository.
/// 
/// This is in the data layer and can use framework-specific dependencies
/// like Dio, HTTP clients, storage, etc.
/// 
/// For demonstration purposes, this implementation simulates API calls
/// with occasional failures to demonstrate rollback behavior.
class TaskBoardRepositoryImpl implements TaskBoardRepository {
  int _callCount = 0;

  @override
  Future<Result<void>> moveTask({
    required String taskId,
    required TaskStatus newStatus,
    required int newIndex,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _callCount++;

    // Simulate failure every 5th call to demonstrate rollback
    if (_callCount % 5 == 0) {
      return const FailureResult('Failed to move task. Please try again.');
    }

    // In a real implementation, this would make an API call
    // Example:
    // try {
    //   await dio.patch('/tasks/$taskId', data: {
    //     'status': newStatus.toString(),
    //     'order': newIndex,
    //   });
    //   return const Success(null);
    // } catch (e) {
    //   return FailureResult(e.toString());
    // }

    return const Success(null);
  }
}
