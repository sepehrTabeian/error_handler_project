import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_board_repository_impl.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/usecases/move_task_usecase.dart';
import '../bloc/task_board_bloc.dart';
import '../bloc/task_board_event.dart';
import '../bloc/task_board_state.dart';
import '../widgets/task_column.dart';

/// Page displaying the Kanban task board.
/// 
/// This page contains three columns: Todo, In Progress, and Done.
/// Tasks can be dragged between columns using the drag-and-drop functionality.
/// 
/// UI notes:
/// - Keep UI simple and clean
/// - The goal is correctness and architecture, not fancy design
/// - Show loading only on initial load, not during every move
/// - Show error using BlocListener with SnackBar
/// - Do not block the UI while moving a task
class TaskBoardPage extends StatelessWidget {
  const TaskBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // In a real app, use dependency injection (e.g., GetIt, Provider)
        // For this example, we create the dependencies manually
        final repository = TaskBoardRepositoryImpl();
        final useCase = MoveTaskUseCase(repository);
        return TaskBoardBloc(useCase)..add(const TaskBoardStarted());
      },
      child: const TaskBoardView(),
    );
  }
}

/// The actual view widget for the task board.
/// 
/// Separated from the page to allow for easier testing and separation of concerns.
class TaskBoardView extends StatelessWidget {
  const TaskBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Board'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<TaskBoardBloc, TaskBoardState>(
        listener: (context, state) {
          // Show error message in SnackBar when a task move fails
          if (state is TaskBoardLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<TaskBoardBloc, TaskBoardState>(
          builder: (context, state) {
            if (state is TaskBoardLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is TaskBoardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is TaskBoardLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TaskColumn(
                        status: TaskStatus.todo,
                        title: 'To Do',
                        tasks: state.board[TaskStatus.todo] ?? [],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TaskColumn(
                        status: TaskStatus.inProgress,
                        title: 'In Progress',
                        tasks: state.board[TaskStatus.inProgress] ?? [],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TaskColumn(
                        status: TaskStatus.done,
                        title: 'Done',
                        tasks: state.board[TaskStatus.done] ?? [],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
