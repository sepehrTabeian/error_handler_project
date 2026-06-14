# Chat Feature

## Business Goal

The chat feature enables real-time messaging between users with offline-first capabilities. Users can send and receive messages even when offline, with automatic synchronization when connectivity is restored.

## Architecture

### Clean Architecture Layers

```
Presentation Layer
├── ChatBloc (State management)
├── ChatEvent (User actions)
├── ChatState (UI state)
└── ChatPage (UI)
    ↓ depends on
Domain Layer
├── ChatMessageEntity (Domain entity)
├── SendMessageRequestEntity (Request entity)
├── ChatRepository (Repository interface)
├── SendMessageUseCase (Business logic)
├── SyncPendingMessagesUseCase (Sync logic)
└── WatchMessagesUseCase (Stream logic)
    ↓ depends on
Data Layer
├── ChatRepositoryImpl (Repository implementation)
├── ChatLocalDataSource (Local database)
├── ChatRemoteDataSource (REST API)
├── ChatSocketDataSource (WebSocket)
├── ChatMessageDto (Data transfer object)
└── SendMessageDto (Request DTO)
```

## Entities

### ChatMessageEntity

Domain entity representing a chat message:

- **localId**: Unique identifier generated locally
- **serverId**: Unique identifier from server (nullable until synced)
- **userId**: ID of the user who sent the message
- **text**: Message content
- **createdAt**: Timestamp when message was created
- **status**: Send status (pending, sent, failed)

### MessageSendStatus

Enum representing message send state:
- **pending**: Message saved locally, not yet sent
- **sent**: Message successfully sent to server
- **failed**: Message send failed, will retry

## Repository

### ChatRepository Interface

```dart
abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> watchMessages();
  Future<Result<void>> sendMessage(SendMessageRequestEntity request);
  Future<Result<void>> syncPendingMessages();
  Future<Result<void>> connectRealtime();
  Future<void> disconnectRealtime();
}
```

### ChatRepositoryImpl

Offline-first implementation with:
- Local database as single source of truth
- WebSocket for real-time messaging
- REST as fallback for sending
- Automatic sync of pending messages

## Use Cases

### SendMessageUseCase

Validates and sends a message:
- Validates message text is not empty
- Delegates to repository for offline-first sending
- Returns Result<void> for success/failure

### SyncPendingMessagesUseCase

Retries messages that failed to send:
- Fetches pending and failed messages from local database
- Retries each message via REST
- Updates local status on success/failure

### WatchMessagesUseCase

Streams messages from local database:
- Returns Stream<List<ChatMessageEntity>>
- UI automatically updates when database changes
- Ordered by creation time (newest first)

## Bloc

### ChatBloc

Coordinates chat presentation flow:

**Events**:
- `ChatStarted`: Initialize message watching and sync pending
- `ChatMessageSubmitted`: User submits a message
- `ChatPendingSyncRequested`: Manual sync trigger
- `ChatMessagesChanged`: Internal event from database stream

**States**:
- `messages`: List of chat messages
- `isSending`: Whether a message is currently being sent
- `errorMessage`: Error message to display

**Key Behaviors**:
- Subscribes to local database stream on start
- Automatically syncs pending messages on start
- UI updates automatically when database changes
- Shows error messages for failed operations

## Offline-First Strategy

### Single Source of Truth

**Local database is the single source of truth for the UI**:
- UI always reads from local database
- WebSocket and REST are only synchronization mechanisms
- Incoming socket messages are saved to database, not emitted directly

### Send Flow

```
User sends message
    ↓
Save to local database (status: pending)
    ↓
UI shows message immediately
    ↓
Try WebSocket first
    ↓
├─ Success → Update local (status: sent)
│
└─ Failure → Try REST fallback
            ↓
            ├─ Success → Update local (status: sent)
            │
            └─ Failure → Update local (status: failed)
```

### Receive Flow

```
WebSocket receives message
    ↓
Parse JSON to DTO
    ↓
Save to local database (status: sent)
    ↓
Database stream emits change
    ↓
Bloc receives change
    ↓
UI updates automatically
```

### Sync Strategy

Pending messages are synced:
- On chat screen open
- On app startup
- On connectivity restore
- On manual retry button press

Sync process:
1. Fetch pending and failed messages
2. Mark each as pending (in progress)
3. Send via REST
4. Update status to sent or failed
5. Stop on first failure

## WebSocket Architecture

### Connection

WebSocket connection established with:
- URL from environment configuration
- Access token as query parameter
- Automatic authentication

### Message Types

**Incoming**:
- `message.created`: New message from server

**Outgoing**:
- `message.send`: Send message to server

### Error Handling

- Connection errors trigger REST fallback for sending
- Automatic reconnection strategy (to be implemented)
- Socket status monitoring (to be implemented)

## Data Sources

### ChatLocalDataSource

Abstract interface for local database operations:
- `watchMessages()`: Stream of all messages
- `saveMessage()`: Insert or replace message
- `updateMessage()`: Update existing message
- `getPendingMessages()`: Fetch pending messages
- `getFailedMessages()`: Fetch failed messages
- `markAsPending()`: Mark message as pending
- `deleteMessage()`: Delete message

### DriftChatLocalDataSource

Drift/SQLite implementation:
- Uses AppDatabase for persistence
- Streams database changes for reactive UI
- Orders messages by creation time
- Filters by status for pending/failed queries

### ChatRemoteDataSource

REST API for message sending:
- POST /chat/messages
- Returns server-assigned message ID
- Maps Dio errors to AppException

### ChatSocketDataSource

WebSocket for real-time messaging:
- `connect()`: Establish WebSocket connection
- `disconnect()`: Close connection
- `sendMessage()`: Send message through socket
- `watchIncomingMessages()`: Stream of incoming messages

### WebSocketChatDataSource

WebSocket implementation:
- Uses web_socket_channel package
- Broadcast stream for multiple listeners
- Parses JSON payloads to DTOs
- Handles connection lifecycle

## Data Transfer Objects

### ChatMessageDto

DTO for message data transfer:
- Maps to/from ChatMessageEntity
- Handles JSON serialization
- Includes copyWith for updates

### SendMessageDto

DTO for sending messages:
- Contains local ID, user ID, text, timestamp
- Serialized to JSON for API/Socket

## Performance Considerations

### Data Structures

- **List<ChatMessageEntity>**: For ordered display in UI
- **ListView.builder**: Efficient rendering of large lists
- **ValueKey**: Optimizes widget rebuilds

### Database Queries

- Indexed on createdAt for ordering
- Indexed on status for filtering pending/failed
- Watch queries use efficient streaming

### Memory Management

- Stream subscriptions cancelled on Bloc close
- WebSocket connections closed on disconnect
- Database connections managed by Drift

## Testing Considerations

### Unit Tests

- Use cases: Test business logic in isolation
- Repository: Test with mocked data sources
- Bloc: Test event handling and state emissions

### Integration Tests

- Repository with real database
- Data sources with mock server
- End-to-end message flow

### Widget Tests

- ChatPage UI rendering
- Message list display
- Input field behavior
- Error state display

## Guidelines

- Never mutate state directly, always create new instances
- Local database is SSOT, never bypass it
- Handle network failures gracefully with fallback
- Use streams for reactive UI updates
- Cancel subscriptions to avoid memory leaks
- Validate user input before processing
- Show user-friendly error messages
- Log technical errors for debugging
