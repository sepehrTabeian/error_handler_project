# Core Module

## Purpose

The core module contains application-level infrastructure that is shared across all features. It provides foundational services and configurations that are not specific to any particular business domain.

## Responsibilities

- **Dependency Injection**: Centralized service locator configuration using GetIt
- **App Configuration**: Global app settings and constants
- **Shared Utilities**: Common utilities used across the application
- **Type Definitions**: Shared types and interfaces used across features

## What Should Be Placed Here

✅ **Include**:
- Dependency injection container configuration
- Global app constants (API endpoints, timeouts, etc.)
- Shared type definitions (Result, Failure, etc.)
- Cross-cutting concerns (logging, analytics interfaces)
- App-level configuration classes

❌ **Do Not Include**:
- Feature-specific business logic
- UI components
- Feature-specific entities or use cases
- Data sources or repositories
- Platform-specific implementations

## Why Core Exists

1. **Centralization**: Provides a single location for app-wide configuration
2. **Reusability**: Shared utilities and types can be used by all features
3. **Consistency**: Ensures consistent dependency injection across the app
4. **Maintainability**: Changes to core infrastructure are isolated in one place

## Structure

```
lib/core/
├── di/
│   └── injection_container.dart  # GetIt service locator configuration
```

## Dependency Injection

The `injection_container.dart` file configures all application dependencies using GetIt. Dependencies are registered in the following order:

1. **Infrastructure**: Storage, networking, database, session
2. **Data Sources**: Remote, local, socket data sources
3. **Repositories**: Repository implementations
4. **Use Cases**: Business logic use cases
5. **Blocs**: State management blocs

### Registration Strategy

- **LazySingleton**: For stateful or expensive-to-create services
- **Factory**: For stateless use cases and blocs

## Usage

```dart
// Get a registered dependency
final chatBloc = getIt<ChatBloc>();
final dio = getIt<Dio>();
final database = getIt<AppDatabase>();
```

## Guidelines

- Keep core module framework-agnostic where possible
- Avoid feature-specific logic
- Prefer interfaces over concrete implementations
- Document why each dependency is registered as singleton or factory
- Keep registration order consistent with dependency graph
