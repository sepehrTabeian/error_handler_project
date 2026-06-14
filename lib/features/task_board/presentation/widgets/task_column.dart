import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_status.dart';
import '../bloc/task_board_bloc.dart';
import '../bloc/task_board_event.dart';
import 'task_card.dart';

/// Widget representing a single column in the Kanban board.
/// 
/// Each column corresponds to a TaskStatus (Todo, In Progress, Done).
/// The column displays tasks for that status and accepts dropped tasks.
/// 
/// When a task is dropped, it dispatches a TaskMoved event to the bloc.
class TaskColumn extends StatelessWidget {
  final TaskStatus status;
  final String title;
  final List<TaskEntity> tasks;

  const TaskColumn({
    super.key,
    required this.status,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskCardData>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        
        // Calculate the new index based on drop position
        // For simplicity, we append to the end of the list
        // A more sophisticated implementation would calculate based on y position
        final newIndex = tasks.length;

        // Dispatch TaskMoved event
        context.read<TaskBoardBloc>().add(TaskMoved(
          taskId: data.taskId,
          fromStatus: data.fromStatus,
          toStatus: status,
          oldIndex: data.oldIndex,
          newIndex: newIndex,
        ));
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.blue.shade50
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.blue
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Task list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: tasks[index],
                        currentStatus: status,
                        currentIndex: index,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns a color for each status column header.
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }
}
