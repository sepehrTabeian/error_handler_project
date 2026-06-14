import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/usecases/move_task_usecase.dart';
import 'task_board_event.dart';
import 'task_board_state.dart';

/// Bloc for managing task board state and handling task movements.
/// 
/// This bloc implements optimistic updates with rollback on failure:
/// 1. When a task is moved, the UI updates immediately (optimistic update)
/// 2. The use case is called to persist the change
/// 3. If successful, the optimistic state is kept
/// 4. If failed, the state rolls back to the previous state
/// 5. An error message is shown in the state
/// 
/// Why optimistic update?
/// - Provides instant feedback to the user
/// - Improves perceived performance
/// - Makes the UI feel responsive even with slow network
/// 
/// Why rollback?
/// - Ensures data consistency between UI and server
/// - Handles network failures gracefully
/// - Prevents showing incorrect state to the user
class TaskBoardBloc extends Bloc<TaskBoardEvent, TaskBoardState> {
  final MoveTaskUseCase _moveTaskUseCase;

  TaskBoardBloc(this._moveTaskUseCase) : super(const TaskBoardInitial()) {
    on<TaskBoardStarted>(_onTaskBoardStarted);
    on<TaskMoved>(
      _onTaskMoved,
      transformer: sequential(),
    );
  }

  /// Handles TaskBoardStarted event.
  /// 
  /// In a real implementation, this would load tasks from a repository.
  /// For this example, we'll emit a loaded state with sample data.
  Future<void> _onTaskBoardStarted(
    TaskBoardStarted event,
    Emitter<TaskBoardState> emit,
  ) async {
    emit(const TaskBoardLoading());
    
    // In a real app, load from repository here
    // For now, emit sample data
    final sampleBoard = {
      TaskStatus.todo: [
        const TaskEntity(
          id: '1',
          title: 'Design system',
          description: 'Create design tokens and components',
          status: TaskStatus.todo,
          order: 0,
        ),
        const TaskEntity(
          id: '2',
          title: 'Setup project',
          description: 'Initialize Flutter project with Clean Architecture',
          status: TaskStatus.todo,
          order: 1,
        ),
      ],
      TaskStatus.inProgress: [
        const TaskEntity(
          id: '3',
          title: 'Implement Bloc',
          description: 'Create bloc for task management',
          status: TaskStatus.inProgress,
          order: 0,
        ),
      ],
      TaskStatus.done: [
        const TaskEntity(
          id: '4',
          title: 'Repository pattern',
          description: 'Implement repository abstraction',
          status: TaskStatus.done,
          order: 0,
        ),
      ],
    };

    emit(TaskBoardLoaded(board: sampleBoard));
  }

  /// Handles TaskMoved event with optimistic update and rollback.
  /// 
  /// Why sequential transformer?
  /// - Task movement order matters
  /// - If the user drags quickly multiple times, concurrent requests may create race conditions
  /// - Sequential processing ensures each move completes before the next starts
  /// - Prevents state corruption from overlapping operations
  /// 
  /// Process:
  /// 1. Save previous board for potential rollback
  /// 2. Create optimistic board by moving task locally
  /// 3. Emit optimistic state (UI updates immediately)
  /// 4. Call use case to persist the change
  /// 5. If success: keep optimistic state
  /// 6. If failure: emit previous board with error message
  Future<void> _onTaskMoved(
    TaskMoved event,
    Emitter<TaskBoardState> emit,
  ) async {
    // Only process if we're in a loaded state
    if (state is! TaskBoardLoaded) return;

    final currentState = state as TaskBoardLoaded;
    
    // Step 1: Save previous board for potential rollback
    final previousBoard = currentState.board;
    
    // Step 2: Create optimistic board by moving task locally
    final optimisticBoard = _moveTaskLocally(
      board: previousBoard,
      taskId: event.taskId,
      fromStatus: event.fromStatus,
      toStatus: event.toStatus,
      oldIndex: event.oldIndex,
      newIndex: event.newIndex,
    );

    // Step 3: Emit optimistic state (UI updates immediately)
    // Clear any previous error message
    emit(currentState.copyWith(
      board: optimisticBoard,
      errorMessage: null,
    ));

    // Step 4: Call use case to persist the change
    final result = await _moveTaskUseCase(
      taskId: event.taskId,
      newStatus: event.toStatus,
      newIndex: event.newIndex,
    );

    // Step 5 & 6: Handle success or failure
    result.when(
      success: (_) {
        // Success: do nothing, optimistic state is now the real state
        // Optionally emit a sync success state if needed
      },
      failure: (message) {
        // Failure: rollback to previous board and show error
        emit(currentState.copyWith(
          board: previousBoard,
          errorMessage: message,
        ));
      },
    );
  }

  /// Helper method to move a task locally within the board.
  /// 
  /// This performs a deep copy of the board and lists to ensure immutability.
  /// 
  /// Why deep copy?
  /// - Dart maps and lists are mutable by reference
  /// - Modifying a list directly would mutate the original state
  /// - Immutable state is required for predictable Bloc behavior
  /// - Prevents bugs where old and new states share references
  /// 
  /// Rules:
  /// - Copy board deeply (map and all lists)
  /// - Remove task from fromStatus list
  /// - Update task.status to toStatus
  /// - Insert it into toStatus list at newIndex
  /// - Clamp index safely to prevent out of bounds
  /// - If task is not found, return original board
  /// - Support moving inside the same column and reordering
  /// - When moving inside same column, adjust index correctly if oldIndex < newIndex
  Map<TaskStatus, List<TaskEntity>> _moveTaskLocally({
    required Map<TaskStatus, List<TaskEntity>> board,
    required String taskId,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    required int oldIndex,
    required int newIndex,
  }) {
    // Deep copy the board and all lists
    // This ensures we don't mutate the original state
    final updatedBoard = {
      for (final entry in board.entries)
        entry.key: List<TaskEntity>.from(entry.value),
    };

    // Get the source list
    final fromList = updatedBoard[fromStatus];
    if (fromList == null || oldIndex >= fromList.length) {
      // Task not found or invalid index, return original board
      return board;
    }

    // Find and remove the task from the source list
    final task = fromList[oldIndex];
    if (task.id != taskId) {
      // Task ID doesn't match, return original board
      return board;
    }

    // Remove task from source list
    fromList.removeAt(oldIndex);

    // Update task status
    final updatedTask = task.copyWith(status: toStatus);

    // Get the target list
    final toList = updatedBoard[toStatus] ?? [];

    // Calculate the insert index
    // When moving within the same column, the index shifts after removal
    int insertIndex = newIndex;
    if (fromStatus == toStatus && oldIndex < newIndex) {
      // After removing at oldIndex, the list shifts left by 1
      // So newIndex should be decremented by 1
      insertIndex = newIndex - 1;
    }

    // Clamp the index to valid range
    if (insertIndex < 0) {
      insertIndex = 0;
    } else if (insertIndex > toList.length) {
      insertIndex = toList.length;
    }

    // Insert task at the calculated position
    toList.insert(insertIndex, updatedTask);

    // Update the board with the modified list
    updatedBoard[toStatus] = toList;

    return updatedBoard;
  }
}

/// Extension on Result for pattern matching.
extension ResultX<T> on Result<T> {
  void when({
    required void Function(T value) success,
    required void Function(String message) failure,
  }) {
    if (this is Success<T>) {
      success((this as Success<T>).value);
    } else if (this is FailureResult<T>) {
      failure((this as FailureResult<T>).message);
    }
  }
}
