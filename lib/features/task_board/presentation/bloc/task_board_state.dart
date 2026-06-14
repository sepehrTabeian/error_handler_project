import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_status.dart';

/// Base class for all task board states.
/// 
/// States represent the immutable data that the UI renders.
/// Following the Bloc pattern, states are immutable and extend Equatable.
abstract class TaskBoardState extends Equatable {
  const TaskBoardState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is first created.
class TaskBoardInitial extends TaskBoardState {
  const TaskBoardInitial();
}

/// Loading state while fetching initial tasks.
/// 
/// Only shown on initial load, not during task moves.
class TaskBoardLoading extends TaskBoardState {
  const TaskBoardLoading();
}

/// Loaded state containing the task board data.
/// 
/// Uses Map&lt;TaskStatus, List&lt;TaskEntity&gt;&gt; for efficient column-based access.
/// 
/// Why Map&lt;TaskStatus, List&lt;TaskEntity&gt;&gt;?
/// - UI needs tasks grouped by column (Todo, In Progress, Done)
/// - Avoids filtering a full task list on every rebuild
/// - Each column can directly access board[TaskStatus.todo], etc.
/// - More efficient than a flat list with status filtering
/// 
/// The board is immutable. Any modification requires creating a deep copy.
class TaskBoardLoaded extends TaskBoardState {
  /// The board state: a map from status to list of tasks in that column.
  final Map<TaskStatus, List<TaskEntity>> board;

  /// Optional error message from a failed operation (e.g., task move failed).
  final String? errorMessage;

  const TaskBoardLoaded({
    required this.board,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced.
  /// 
  /// Used for immutable state updates.
  TaskBoardLoaded copyWith({
    Map<TaskStatus, List<TaskEntity>>? board,
    String? errorMessage,
  }) {
    return TaskBoardLoaded(
      board: board ?? this.board,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [board, errorMessage];
}

/// Error state when initial loading fails.
class TaskBoardError extends TaskBoardState {
  final String message;

  const TaskBoardError(this.message);

  @override
  List<Object?> get props => [message];
}
