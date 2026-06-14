/// Task status enum representing the three columns in the Kanban board.
/// 
/// This is a domain entity and must remain framework-agnostic.
/// No Flutter, Dio, or other framework imports should be added.
enum TaskStatus {
  todo,
  inProgress,
  done,
}
