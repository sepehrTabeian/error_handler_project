# Error Handling in Clean Architecture (Flutter)

## Introduction

One of the most common mistakes in Flutter projects is handling errors in every layer, building UI messages inside DataSources, or exposing technical exceptions directly to Bloc and UI.

The goal of Clean Architecture is that each layer has a single responsibility.

---

# Golden Rule

Before adding any `try/catch`, ask yourself:

1. Does this layer understand the meaning of this error?
2. Should this layer make a decision about this error?
3. Should this layer transform this error into another type?

If the answer to all of these questions is **No**, the `try/catch` is probably unnecessary.

---

# Error Flow

```text
API / SDK
    ↓
DataSource
    ↓
Repository
    ↓
UseCase
    ↓
Bloc
    ↓
UI
```

---

# Layer Responsibilities

## DataSource

Responsible for communicating with external resources.

Examples:

- Dio
- Firebase
- Secure Storage
- SQLite
- WebSocket

### Responsibility

Convert technical errors into application-specific exceptions.

```dart
try {
  final response = await dio.get('/products');
  return ProductDto.fromJson(response.data);
} catch (error) {
  throw errorMapper.map(error);
}
```

### Typical Errors

```text
DioException
SocketException
FormatException
TimeoutException
```

### Never

```dart
showDialog(...);
showSnackBar(...);
Navigator.push(...);
```

---

## Repository

Repository is the boundary between Data and Domain.

### Responsibility

Convert technical exceptions into Failures understandable by Domain.

```dart
try {
  final dto = await remoteDataSource.getProducts();
  return Success(dto.toEntity());
} catch (error) {
  return FailureResult(failureMapper.map(error));
}
```

---

## UseCase

The place for business rules.

### Responsibility

Business validation and business-specific failures.

```dart
if (userContext.userId == null) {
  return const FailureResult(UserIdRequiredFailure());
}
```

### Examples

```text
UserIdRequiredFailure
InsufficientBalanceFailure
OrderExpiredFailure
SubscriptionRequiredFailure
```

---

## Bloc

Responsible for converting Results into States.

```dart
final result = await payUseCase();

switch (result) {
  case Success():
    emit(PaymentSuccess());

  case FailureResult():
    emit(PaymentFailure(result.failure.message));
}
```

### Responsibility

```text
Failure → State
```

---

## UI

UI only renders State.

```dart
BlocListener<PaymentBloc, PaymentState>(
  listener: (context, state) {
    if (state is PaymentFailure) {
      showDialog(...);
    }
  },
)
```

### Responsibility

```text
State → Widget
```

---

# Recommended Project Structure

```text
lib/
│
├── infrastructure/
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── failure.dart
│   │   ├── dio_error_mapper.dart
│   │   └── failure_mapper.dart
│   │
│   ├── network/
│   │   └── dio_client.dart
│   │
│   └── session/
│       ├── user_context_service.dart
│       └── in_memory_user_context_service.dart
│
├── features/
│   └── payment/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── app/
    ├── startup/
    ├── router/
    └── di/
```

---

# Exception vs Failure

## Exception

Something that happened at runtime.

```dart
NetworkException
ServerException
ParsingException
UnauthorizedException
```

## Failure

Something the Domain and Presentation layers understand.

```dart
NetworkFailure
ServerFailure
UserIdRequiredFailure
UnauthorizedFailure
```

---

# Recommended Flow

```text
DioException
    ↓
NetworkException
    ↓
NetworkFailure
    ↓
PaymentFailureState
    ↓
Dialog / Snackbar
```

---

# Anti Pattern: God Error Manager

Avoid:

```dart
class ErrorManager {
  // everything
}
```

Instead use small focused classes:

```text
DioErrorMapper
    ↓
FailureMapper
    ↓
Bloc
    ↓
UI
```

Each class should have one responsibility.

---

# Mental Model

Always ask:

"What should this layer understand?"

DataSource:

```text
Technical Errors
```

Repository:

```text
Failure Mapping
```

UseCase:

```text
Business Rules
```

Bloc:

```text
State Management
```

UI:

```text
Rendering
```

If every layer only performs its own responsibility, the project becomes easier to test, maintain, scale, and reason about.
