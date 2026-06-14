import 'package:equatable/equatable.dart';
import '../../domain/entities/task_status.dart';

/// Base class for all task board events.
/// 
/// Events represent user actions or system events that trigger state changes.
/// Following the Bloc pattern, events are immutable and extend Equatable.
abstract class TaskBoardEvent extends Equatable {
  const TaskBoardEvent();

  @override
  List<Object?> get props => [];
}

/// Event fired when the task board is first loaded.
/// 
/// This would typically trigger loading initial tasks from a repository.
class TaskBoardStarted extends TaskBoardEvent {
  const TaskBoardStarted();
}

/// Event fired when a task is moved from one column to another.
/// 
/// Contains all necessary information to:
/// - Identify which task was moved (taskId)
/// - Identify the source column (fromStatus)
/// - Identify the target column (toStatus)
/// - Identify the source position (oldIndex)
/// - Identify the target position (newIndex)
/// 
/// This event is processed sequentially to prevent race conditions
/// when the user drags tasks quickly.
class TaskMoved extends TaskBoardEvent {
  final String taskId;
  final TaskStatus fromStatus;
  final TaskStatus toStatus;
  final int oldIndex;
  final int newIndex;

  const TaskMoved({
    required this.taskId,
    required this.fromStatus,
    required this.toStatus,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [taskId, fromStatus, toStatus, oldIndex, newIndex];
}
