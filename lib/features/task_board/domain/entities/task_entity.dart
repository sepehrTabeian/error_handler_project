import 'package:equatable/equatable.dart';
import 'task_status.dart';

/// Task entity representing a task in the Kanban board.
/// 
/// This is a domain entity and must remain framework-agnostic.
/// No Flutter, Dio, or other framework imports should be added.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final int order;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.order,
  });

  /// Creates a copy of this task with the given fields replaced.
  /// 
  /// This is used for immutable state updates, especially when
  /// changing the task status during optimistic updates.
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    int? order,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, title, description, status, order];
}
