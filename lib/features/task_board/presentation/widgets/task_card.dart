import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_status.dart';

/// Widget representing a single task card in the Kanban board.
/// 
/// This widget is draggable, allowing users to move tasks between columns.
/// The card displays the task title and description.
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final TaskStatus currentStatus;
  final int currentIndex;

  const TaskCard({
    super.key,
    required this.task,
    required this.currentStatus,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskCardData>(
      data: TaskCardData(
        taskId: task.id,
        fromStatus: currentStatus,
        oldIndex: currentIndex,
      ),
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 280,
          child: _buildCard(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(context),
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context, {bool isDragging = false}) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Data class passed when a task card is dragged.
/// 
/// Contains the information needed to dispatch a TaskMoved event
/// when the task is dropped.
class TaskCardData {
  final String taskId;
  final TaskStatus fromStatus;
  final int oldIndex;

  TaskCardData({
    required this.taskId,
    required this.fromStatus,
    required this.oldIndex,
  });
}
