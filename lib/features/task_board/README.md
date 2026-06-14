# Task Board Feature

## Business Goal

The task board feature provides a Kanban-style interface for managing tasks across different stages (Todo, In Progress, Done). It demonstrates optimistic updates with rollback on failure, providing a smooth user experience even during network issues.

## Architecture

### Clean Architecture Layers

```
Presentation Layer
├── TaskBoardBloc (State management)
├── TaskBoardEvent (User actions)
├── TaskBoardState (UI state)
├── TaskCard (Task widget)
├── TaskColumn (Column widget)
└── TaskBoardPage (UI)
    ↓ depends on
Domain Layer
├── TaskEntity (Domain entity)
├── TaskStatus (Status enum)
├── TaskBoardRepository (Repository interface)
└── MoveTaskUseCase (Business logic)
    ↓ depends on
Data Layer
├── TaskBoardRepositoryImpl (Repository implementation)
└── (No external data sources - simulated for demo)
```

## Entities

### TaskEntity

Domain entity representing a task:

- **id**: Unique task identifier
- **title**: Task title
- **description**: Task description
- **status**: Current status (todo, inProgress, done)
- **order**: Position within the status column

### TaskStatus

Enum representing task status:
- **todo**: Task not started
- **inProgress**: Task in progress
- **done**: Task completed

### Result<T>

Generic result type for success/failure:
- **Success<T>**: Successful operation with data
- **FailureResult<T>**: Failed operation with error message

## Repository

### TaskBoardRepository Interface

```dart
abstract class TaskBoardRepository {
  Future<Result<void>> moveTask({
    required String taskId,
    required TaskStatus newStatus,
    required int newIndex,
  });
}
```

### TaskBoardRepositoryImpl

Simulated implementation for demonstration:
- Simulates network delay
- Simulates occasional failures (every 5th call)
- In production, would make actual API calls

## Use Case

### MoveTaskUseCase

Orchestrates task movement:

**Flow**:
1. Receive task movement request
2. Delegate to repository
3. Return Result<void>

**Parameters**:
- **taskId**: ID of task to move
- **newStatus**: Target status column
- **newIndex**: Target position within column

## Bloc

### TaskBoardBloc

Manages task board state with optimistic updates:

**Events**:
- `TaskBoardStarted`: Initialize board
- `TaskMoved`: User moved a task
- `TaskMoveRolledBack`: Rollback failed move

**States**:
- **TaskBoardInitial**: Initial state
- **TaskBoardLoading**: Loading tasks
- **TaskBoardLoaded**: Board loaded with tasks
- **TaskBoardError**: Error state

**Optimistic Update Flow**:
```
User drags task
    ↓
Bloc updates state immediately (optimistic)
    ↓
UI shows new position
    ↓
Call use case to persist
    ↓
├─ Success → State remains
│
└─ Failure → Rollback to previous state
```

### Sequential Processing

Uses `sequential()` transformer from bloc_concurrency:
- Ensures task moves are processed in order
- Prevents race conditions from rapid moves
- Each move completes before next starts

## Optimistic Updates

### Why Optimistic Updates?

- **Immediate Feedback**: UI responds instantly to user actions
- **Better UX**: No waiting for network confirmation
- **Perceived Performance**: App feels faster

### Implementation

1. User drags task to new position
2. Bloc updates state immediately (before API call)
3. UI shows task in new position
4. Repository call made in background
5. If success, state remains
6. If failure, state rolls back to previous position

### Rollback Strategy

When API call fails:
- Restore previous task position
- Show error message to user
- Maintain data consistency
- Allow user to retry

## Data Structure

### Board State

```
Map<TaskStatus, List<TaskEntity>>
{
  TaskStatus.todo: [task1, task2, ...],
  TaskStatus.inProgress: [task3, task4, ...],
  TaskStatus.done: [task5, task6, ...],
}
```

### Why Map<TaskStatus, List<TaskEntity>>?

**Advantages**:
- **Efficient Column Access**: Direct access by status key
- **No Filtering**: No need to filter flat list on every rebuild
- **Clear Structure**: Matches UI structure (columns)
- **Type Safety**: Compile-time type checking

**Performance**:
- O(1) access to column by status
- No O(n) filtering on rebuild
- Efficient for large task lists

### Immutability

Board state is immutable:
- Every change creates a new Map
- Deep copy of affected lists
- Prevents accidental mutations
- Enables time-travel debugging

## UI Components

### TaskCard

Widget displaying a single task:
- Shows task title and description
- Draggable for reordering
- Visual feedback during drag

### TaskColumn

Widget displaying a status column:
- Header with status name and task count
- List of TaskCard widgets
- Drop zone for tasks
- Visual feedback during drag-over

### TaskBoardPage

Main page with:
- Three columns (Todo, In Progress, Done)
- Drag and drop between columns
- Reordering within columns
- Error display

## Performance Considerations

### Data Structures

- **Map<TaskStatus, List<TaskEntity>>**: Efficient column access
- **ListView.builder**: Efficient rendering of large lists
- **ValueKey**: Optimizes widget rebuilds
- **Equatable**: Efficient state comparison

### Rendering

- Only rebuild changed columns
- Only rebuild moved task cards
- Use const widgets where possible
- Avoid unnecessary rebuilds

### State Updates

- Immutable state prevents unnecessary rebuilds
- Equatable checks for actual changes
- Bloc emits only when state changes

## Error Handling

### Network Errors

- Rollback optimistic update
- Show error message: "Failed to move task. Please try again."
- Allow user to retry

### Validation Errors

- Validate task data before move
- Prevent invalid moves
- Show validation errors

## Testing Considerations

### Unit Tests

- MoveTaskUseCase with mocked repository
- Repository with simulated failures
- Bloc event handling and state emissions
- Optimistic update logic
- Rollback logic

### Integration Tests

- End-to-end drag and drop
- API failure scenarios
- Rollback verification
- Sequential move processing

### Widget Tests

- TaskCard rendering
- TaskColumn rendering
- Drag and drop gestures
- Error state display

## Future Enhancements

### Persistence

- Add local database for task storage
- Sync with remote API
- Offline task management
- Conflict resolution

### Real-time Updates

- WebSocket for real-time task updates
- Multi-user collaboration
- Conflict detection
- Automatic refresh

### Advanced Features

- Task filtering and search
- Task labels/tags
- Due dates and reminders
- Task assignments
- Comments on tasks
- Attachments

## Guidelines

- Always use immutable state
- Implement optimistic updates for better UX
- Rollback on failure to maintain consistency
- Use sequential processing for dependent operations
- Test rollback scenarios thoroughly
- Show user-friendly error messages
- Log technical errors for debugging
- Keep UI responsive during API calls
- Use efficient data structures
- Avoid unnecessary rebuilds
