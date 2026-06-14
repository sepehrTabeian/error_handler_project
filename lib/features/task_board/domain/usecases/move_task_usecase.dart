import '../entities/result.dart';
import '../entities/task_status.dart';
import '../repositories/task_board_repository.dart';

/// Use case for moving a task to a new status and position.
/// 
/// This is a domain layer use case and must remain framework-agnostic.
/// It encapsulates a single business rule: moving a task.
/// 
/// Use cases are the entry point for business logic from the presentation layer.
/// They orchestrate the flow of data between the presentation and data layers.
class MoveTaskUseCase {
  final TaskBoardRepository _repository;

  MoveTaskUseCase(this._repository);

  /// Executes the move task operation.
  /// 
  /// Delegates to the repository to persist the change.
  /// Returns the result from the repository.
  Future<Result<void>> call({
    required String taskId,
    required TaskStatus newStatus,
    required int newIndex,
  }) {
    return _repository.moveTask(
      taskId: taskId,
      newStatus: newStatus,
      newIndex: newIndex,
    );
  }
}
