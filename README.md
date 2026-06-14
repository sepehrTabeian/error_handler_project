# Error Handler Project

A production-grade Flutter application demonstrating Clean Architecture, offline-first patterns, and comprehensive error handling.

## Overview

This project showcases a robust Flutter application architecture with the following key features:

- **Clean Architecture**: Domain, data, and presentation layers with clear separation of concerns
- **Offline-First Chat**: Real-time messaging with WebSocket and REST fallback, local database persistence
- **Authentication**: JWT-based authentication with secure token storage
- **State Management**: Bloc pattern with immutable states and optimistic updates
- **Dependency Injection**: GetIt service locator with lazy singletons and factories
- **Error Handling**: Comprehensive error mapping from exceptions to user-friendly failures
- **Startup Pipeline**: Structured initialization sequence with session restoration
- **Kanban Task Board**: Drag-and-drop task management with optimistic updates and rollback
- **Conference Members**: Participant management with search, selection, and mute controls

## Architecture

### Clean Architecture

The project follows Clean Architecture principles with three distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  (Bloc, Events, States, Widgets, Pages)                    │
└──────────────────────────┬──────────────────────────────────┘
                           │ depends on
┌──────────────────────────▼──────────────────────────────────┐
│                      Domain Layer                           │
│  (Entities, Use Cases, Repository Interfaces)              │
└──────────────────────────┬──────────────────────────────────┘
                           │ depends on
┌──────────────────────────▼──────────────────────────────────┐
│                       Data Layer                             │
│  (Repository Implementations, Data Sources, DTOs)            │
└──────────────────────────┬──────────────────────────────────┘
                           │ depends on
┌──────────────────────────▼──────────────────────────────────┐
│                   Infrastructure Layer                        │
│  (Networking, Database, Storage, Session, Errors)           │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Rule

**Dependencies must point inward**: Presentation → Domain ← Data → Infrastructure

- Domain layer is framework-agnostic (no Flutter, Dio, JSON imports)
- Data layer implements domain interfaces
- Presentation layer depends only on domain abstractions

## Folder Structure

```
lib/
├── app/
│   ├── di/
│   │   └── di.dart (empty - replaced by core/di)
│   ├── router/
│   │   └── (empty - to be implemented with go_router)
│   └── startup/
│       └── initialize_session_usecase.dart
├── core/
│   └── di/
│       └── injection_container.dart (GetIt configuration)
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── dto/
│   │   │       ├── login_request_dto.dart
│   │   │       └── login_response_dto.dart
│   │   ├── domain/
│   │   │   ├── entity/
│   │   │   │   ├── auth_session_entity.dart
│   │   │   │   └── login_request_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── repository.dart
│   │   │   └── usecases/
│   │   │       └── login_usecase.dart
│   │   └── presentation/
│   │       └── (to be implemented)
│   ├── chat/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── chat_local_datasource.dart
│   │   │   │   ├── chat_remote_datasource.dart
│   │   │   │   ├── chat_socket_datasource.dart
│   │   │   │   ├── drift_chat_local_datasource.dart
│   │   │   │   └── web_socket_chat_datasource.dart
│   │   │   ├── dto/
│   │   │   │   ├── chat_message_dto.dart
│   │   │   │   └── send_message_dto.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── chat_message_entity.dart
│   │   │   │   └── send_message_request_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_message_usecase.dart
│   │   │       ├── sync_pending_messages_usecase.dart
│   │   │       └── watch_messages_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── chat_bloc.dart
│   │       │   ├── chat_event.dart
│   │       │   └── chat_state.dart
│   │       └── page/
│   │           └── chat_page.dart
│   ├── conference_members/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── conference_members_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── conference_participant_entity.dart
│   │   │   │   ├── participant_role.dart
│   │   │   │   └── result.dart
│   │   │   ├── repositories/
│   │   │   │   └── conference_members_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_conference_participants_usecase.dart
│   │   │       └── update_participant_mute_status_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── conference_members_bloc.dart
│   │       │   ├── conference_members_event.dart
│   │       │   └── conference_members_state.dart
│   │       ├── widgets/
│   │       │   ├── conference_member_tile.dart
│   │       │   └── conference_member_search_field.dart
│   │       └── pages/
│   │           └── conference_members_page.dart
│   ├── payment/
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   │   └── payment_remote_datasource.dart
│   │   │   ├── dto/
│   │   │   │   ├── payment_request_dto.dart
│   │   │   │   └── payment_response_dto.dart
│   │   │   └── repositories/
│   │   │       └── payment_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── payment_entity.dart
│   │   │   │   └── payment_request_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── payment_repository.dart
│   │   │   └── pay_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── payment_bloc.dart
│   │       │   ├── payment_event.dart
│   │       │   └── payment_state.dart
│   │       └── page/
│   │           └── payment_page.dart
│   └── task_board/
│       ├── data/
│       │   └── repositories/
│       │       └── task_board_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── result.dart
│       │   │   ├── task_entity.dart
│       │   │   └── task_status.dart
│       │   ├── repositories/
│       │   │   └── task_board_repository.dart
│       │   └── usecases/
│       │       └── move_task_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── task_board_bloc.dart
│           │   ├── task_board_event.dart
│           │   └── task_board_state.dart
│           ├── widgets/
│           │   ├── task_card.dart
│           │   └── task_column.dart
│           └── pages/
│               └── task_board_page.dart
├── infrastructure/
│   ├── auth/
│   │   ├── jwt_token_payload_reader.dart
│   │   ├── secure_token_storage.dart
│   │   ├── token_payload_reader.dart
│   │   ├── token_provider.dart
│   │   ├── token_storage.dart
│   │   ├── token_user_id_resolver.dart
│   │   └── user_id_resolver.dart
│   ├── database/
│   │   └── app_database.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── app_failure.dart
│   │   ├── app_failure_mapper.dart
│   │   ├── api_error_response.dart
│   │   ├── dio_error_mapper.dart
│   │   └── result.dart
│   ├── network/
│   │   ├── auth_interseptor.dart
│   │   └── dio_client.dart
│   └── session/
│       └── user_context_service.dart
├── startup/
│   ├── startup_config.dart
│   ├── startup_dependencies.dart
│   ├── startup_runner.dart
│   └── startup_session.dart
└── main.dart
```

## Dependency Injection

The project uses GetIt as the service locator for dependency injection. All dependencies are registered in `lib/core/di/injection_container.dart`.

### Registration Strategy

**LazySingleton**: For repositories, services, data sources, and singletons
- Expensive to create (database connections, HTTP clients)
- Maintain state (cached tokens, active connections)
- Should be shared across the application

**Factory**: For use cases and blocs
- Stateless (no mutable state)
- Should be recreated per call (no shared state)
- Multiple instances may exist (e.g., same bloc in different screens)

### Registration Order

1. **Infrastructure** (lowest level, no dependencies on app code)
   - Storage (token storage)
   - Networking (Dio client, interceptors, error mappers)
   - Database (local SQLite database)
   - Session management (user context)

2. **Data Sources** (depend on infrastructure)
   - Remote data sources (REST APIs)
   - Socket data sources (WebSocket connections)
   - Local data sources (SQLite database)

3. **Repositories** (depend on data sources and infrastructure)
   - Orchestrate data flow between data sources and use cases
   - Implement repository abstractions from domain layer

4. **Use Cases** (depend on repositories)
   - Encapsulate single business rules
   - Entry point for business logic from presentation layer

5. **Blocs** (depend on use cases)
   - Manage state for specific features
   - Consumed by the UI

### Example Usage

```dart
// In a widget
final chatBloc = getIt<ChatBloc>();
```

## Startup Flow

The application startup is orchestrated by the `StartupRunner` class in `lib/startup/startup_runner.dart`.

### Startup Pipeline

1. **Initialize Flutter Bindings**
   - Required for native plugins (Firebase, SQLite)
   - Ensures Flutter framework is ready

2. **Load Environment Configuration**
   - Load API URLs, WebSocket URLs, environment flags
   - Load from environment variables or config files

3. **Configure Dependency Injection**
   - Register all services with GetIt
   - Initialize in dependency order

4. **Initialize Database**
   - Open SQLite database
   - Run pending migrations

5. **Restore Session**
   - Check for stored authentication tokens
   - Validate and decode JWT tokens
   - Extract user ID and set user context

6. **Configure Logging**
   - Set up log levels based on environment
   - Configure log destinations

7. **Configure Error Reporting**
   - Enable crash reporting in production
   - Set up error tracking services

8. **Launch Application**
   - Run the app with configured dependencies
   - Show appropriate screen based on session state

### Error Handling

Startup failures are caught and handled gracefully:
- Development: Detailed error information shown
- Production: User-friendly error message with retry option
- All errors logged for debugging

## State Management

The project uses the **Bloc pattern** for state management.

### Bloc Architecture

```
UI Widget
    │
    │ adds events
    ▼
Bloc
    │
    │ processes events
    ▼
Use Cases
    │
    │ executes business logic
    ▼
Repositories
    │
    │ fetches/persists data
    ▼
Data Sources
```

### State Principles

- **Immutable**: States are never mutated, always new instances
- **Single Source of Truth**: Each feature has one Bloc managing its state
- **Optimistic Updates**: UI updates immediately, with rollback on failure
- **Event-Driven**: UI emits events, Bloc emits states

### Example

```dart
// Widget
BlocBuilder<ChatBloc, ChatState>(
  builder: (context, state) {
    if (state.isSending) {
      return CircularProgressIndicator();
    }
    return ListView(children: state.messages.map(...));
  },
)

// Emit event
context.read<ChatBloc>().add(ChatMessageSubmitted(text));
```

## Offline-First Strategy

The chat feature implements an offline-first architecture where the local database is the single source of truth.

### Offline-First Flow

```
User sends message
    │
    ▼
Save to local database (status: pending)
    │
    ▼
UI shows message immediately
    │
    ▼
Try WebSocket first
    │
    ├─ Success → Update local (status: sent)
    │
    └─ Failure → Try REST fallback
                    │
                    ├─ Success → Update local (status: sent)
                    │
                    └─ Failure → Update local (status: failed)
```

### Key Principles

1. **Local Database is SSOT**: UI always reads from local database
2. **Immediate UI Update**: Message appears immediately after local save
3. **Dual Sync Strategy**: WebSocket for real-time, REST as fallback
4. **Pending Queue**: Failed messages stored for retry
5. **Automatic Retry**: Sync pending messages on startup/connectivity restore

### Data Flow

```
WebSocket/REST → Repository → Local Database → Stream → Bloc → UI
```

Incoming socket messages are saved to local database, not emitted directly to UI. This keeps the offline-first flow consistent.

## WebSocket Architecture

The chat feature uses WebSocket for real-time messaging.

### Connection Flow

```
1. Connect with token as query parameter
2. Listen for incoming messages
3. Parse JSON payloads
4. Convert to DTOs
5. Save to local database
6. UI updates through database stream
```

### Message Types

- `message.created`: New message received from server
- `message.send`: Send message to server

### Error Handling

- Connection errors trigger REST fallback
- Automatic reconnection strategy (to be implemented)
- Socket status monitoring (to be implemented)

## Error Handling Strategy

The project has a comprehensive error handling system with three layers:

### 1. Exception Layer (Infrastructure)

```dart
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException { ... }
class UnauthorizedException extends AppException { ... }
class ServerException extends AppException { ... }
class ValidationException extends AppException { ... }
class ParsingException extends AppException { ... }
class UnknownException extends AppException { ... }
```

### 2. Failure Layer (Domain)

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { ... }
class UnauthorizedFailure extends Failure { ... }
class ServerFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
class ParsingFailure extends Failure { ... }
class UnknownFailure extends Failure { ... }
```

### 3. Result Type (Domain)

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
```

### Error Mapping

```
DioException → DioErrorMapper → AppException → FailureMapper → Failure → FailureResult
```

### User-Facing Messages

Failures contain localized Persian messages for user display:
- Network: "اتصال اینترنت را بررسی کنید"
- Unauthorized: "لطفا دوباره وارد شوید"
- Server: "خطا در ارتباط با سرور"
- Validation: Field-specific error messages
- Parsing: "خطا در پردازش اطلاعات"

## How to Run the Project

### Prerequisites

- Flutter SDK (>= 3.10.7)
- Dart SDK (>= 3.10.7)
- iOS/Android development environment

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd error_handler_project
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Environment Configuration

Set environment variables for different environments:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Production
flutter run --dart-define=ENVIRONMENT=prod
```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## How to Add a New Feature

Follow this template to add a new feature consistently:

### 1. Create Feature Structure

```
lib/features/your_feature/
├── data/
│   ├── datasources/
│   ├── dto/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── widgets/
    └── pages/
```

### 2. Define Domain Layer

**Entities** (framework-agnostic):
```dart
class YourEntity {
  final String id;
  final String name;
  
  const YourEntity({
    required this.id,
    required this.name,
  });
}
```

**Repository Interface**:
```dart
abstract class YourRepository {
  Future<Result<YourEntity>> fetchData();
}
```

**Use Case**:
```dart
class FetchDataUseCase {
  final YourRepository _repository;
  
  FetchDataUseCase(this._repository);
  
  Future<Result<YourEntity>> call() {
    return _repository.fetchData();
  }
}
```

### 3. Implement Data Layer

**DTOs**:
```dart
class YourDto {
  final String id;
  final String name;
  
  factory YourDto.fromJson(Map<String, dynamic> json) {
    return YourDto(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  
  YourEntity toEntity() {
    return YourEntity(id: id, name: name);
  }
}
```

**Data Source**:
```dart
abstract class YourRemoteDataSource {
  Future<YourDto> fetchData();
}

class YourRemoteDataSourceImpl implements YourRemoteDataSource {
  final Dio dio;
  final DioErrorMapper errorMapper;
  
  YourRemoteDataSourceImpl({
    required this.dio,
    required this.errorMapper,
  });
  
  @override
  Future<YourDto> fetchData() async {
    try {
      final response = await dio.get('/your-endpoint');
      return YourDto.fromJson(response.data);
    } catch (error) {
      throw errorMapper.map(error);
    }
  }
}
```

**Repository Implementation**:
```dart
class YourRepositoryImpl implements YourRepository {
  final YourRemoteDataSource remoteDataSource;
  final FailureMapper failureMapper;
  
  YourRepositoryImpl({
    required this.remoteDataSource,
    required this.failureMapper,
  });
  
  @override
  Future<Result<YourEntity>> fetchData() async {
    try {
      final dto = await remoteDataSource.fetchData();
      return Success(dto.toEntity());
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }
}
```

### 4. Implement Presentation Layer

**Events**:
```dart
sealed class YourEvent {
  const YourEvent();
}

class YourDataRequested extends YourEvent {
  const YourDataRequested();
}
```

**States**:
```dart
class YourState extends Equatable {
  final bool isLoading;
  final YourEntity? data;
  final String? errorMessage;
  
  const YourState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
  });
  
  YourState copyWith({
    bool? isLoading,
    YourEntity? data,
    String? errorMessage,
  }) {
    return YourState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [isLoading, data, errorMessage];
}
```

**Bloc**:
```dart
class YourBloc extends Bloc<YourEvent, YourState> {
  final FetchDataUseCase fetchDataUseCase;
  
  YourBloc({
    required this.fetchDataUseCase,
  }) : super(const YourState()) {
    on<YourDataRequested>(_onDataRequested);
  }
  
  Future<void> _onDataRequested(
    YourDataRequested event,
    Emitter<YourState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await fetchDataUseCase();
    
    switch (result) {
      case Success<YourEntity>():
        emit(state.copyWith(
          isLoading: false,
          data: result.data,
        ));
      case FailureResult<YourEntity>():
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.failure.message,
        ));
    }
  }
}
```

### 5. Register Dependencies

Add to `lib/core/di/injection_container.dart`:

```dart
// In _registerDataSources
getIt.registerLazySingleton<YourRemoteDataSource>(
  () => YourRemoteDataSourceImpl(
    dio: getIt<Dio>(),
    errorMapper: getIt<DioErrorMapper>(),
  ),
);

// In _registerRepositories
getIt.registerLazySingleton<YourRepository>(
  () => YourRepositoryImpl(
    remoteDataSource: getIt<YourRemoteDataSource>(),
    failureMapper: getIt<FailureMapper>(),
  ),
);

// In _registerUseCases
getIt.registerFactory<FetchDataUseCase>(
  () => FetchDataUseCase(getIt<YourRepository>()),
);

// In _registerBlocs
getIt.registerFactory<YourBloc>(
  () => YourBloc(fetchDataUseCase: getIt<FetchDataUseCase>()),
);
```

### 6. Create UI

```dart
class YourPage extends StatelessWidget {
  const YourPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<YourBloc>(),
      child: const YourView(),
    );
  }
}

class YourView extends StatelessWidget {
  const YourView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: BlocBuilder<YourBloc, YourState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const CircularProgressIndicator();
          }
          if (state.data != null) {
            return Text(state.data!.name);
          }
          if (state.errorMessage != null) {
            return Text(state.errorMessage!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## Architecture Review

### Strengths

1. **Clean Architecture**: Clear separation of concerns with dependency inversion
2. **Offline-First**: Robust offline support with local database as SSOT
3. **Error Handling**: Comprehensive error mapping from exceptions to user-friendly failures
4. **Dependency Injection**: Centralized DI with GetIt, proper singleton/factory usage
5. **State Management**: Immutable states with Bloc pattern
6. **Type Safety**: Strong typing with sealed classes for Result, Failure, Exception
7. **Testability**: Abstractions enable easy mocking and testing
8. **Scalability**: Modular feature structure allows independent development

### Weaknesses

1. **No Routing**: go_router is in pubspec.yaml but not implemented
2. **No Localization**: Hardcoded Persian strings, no localization system
3. **No Analytics**: Analytics infrastructure exists but not implemented
4. **No Crash Reporting**: Crash reporting infrastructure exists but not implemented
5. **Limited Testing**: No test files present
6. **No gRPC**: gRPC mentioned in requirements but not implemented
7. **Manual DI**: DI registration is manual, could use code generation
8. **No Background Services**: No background sync or notification handling

### Coupling Issues

1. **Bloc to Use Case**: Blocs directly depend on use cases (acceptable in this architecture)
2. **Repository to Data Source**: Repositories depend on multiple data sources (acceptable)
3. **No Circular Dependencies**: Current architecture has no circular dependencies

### Testability Issues

1. **No Test Files**: No unit, widget, or integration tests
2. **Manual DI**: Manual DI registration makes testing slightly harder
3. **No Mock Generation**: No mock generation setup (e.g., mockito)

### Scalability Concerns

1. **Single Database**: Single SQLite database may become a bottleneck
2. **No Pagination**: No pagination in data fetching
3. **No Caching Strategy**: No explicit caching strategy beyond local database
4. **No Rate Limiting**: No rate limiting for API calls

### Suggested Improvements

1. **Implement go_router**: Add proper navigation with deep linking
2. **Add Localization**: Implement flutter_localizations and ARB files
3. **Add Tests**: Write unit, widget, and integration tests
4. **Implement Analytics**: Add Firebase Analytics or similar
5. **Implement Crash Reporting**: Add Firebase Crashlytics or Sentry
6. **Add Code Generation**: Use injectable or get_it_generator for DI
7. **Add Pagination**: Implement pagination for large datasets
8. **Add Background Sync**: Implement background message sync
9. **Add Notifications**: Implement push notifications
10. **Add Performance Monitoring**: Add Firebase Performance Monitoring

### Clean Architecture Compliance

✅ **Compliant**:
- Domain layer is framework-agnostic
- Dependencies point inward
- Use cases encapsulate business logic
- Repository interfaces in domain layer

❌ **Issues**:
- None significant

### SOLID Compliance

✅ **Single Responsibility**: Each class has one reason to change
✅ **Open/Closed**: Open for extension, closed for modification (sealed classes)
✅ **Liskov Substitution**: Abstractions can be substituted with implementations
✅ **Interface Segregation**: Small, focused interfaces
✅ **Dependency Inversion**: Depend on abstractions, not concretions

## License

[Add your license here]
