import '../entities/result.dart';
import '../entities/task_status.dart';

/// Repository abstraction for task board operations.
/// 
/// This is a domain layer interface and must remain framework-agnostic.
/// The actual implementation will be in the data layer.
/// 
/// This follows the Dependency Inversion Principle: high-level modules
/// (use cases) depend on abstractions, not concrete implementations.
abstract class TaskBoardRepository {
  /// Moves a task to a new status and position.
  /// 
  /// Returns [Success] if the move was persisted successfully.
  /// Returns [FailureResult] with an error message if the operation failed.
  /// 
  /// Parameters:
  /// - taskId: The unique identifier of the task to move
  /// - newStatus: The target column status
  /// - newIndex: The target position within the new status list
  Future<Result<void>> moveTask({
    required String taskId,
    required TaskStatus newStatus,
    required int newIndex,
  });
}
