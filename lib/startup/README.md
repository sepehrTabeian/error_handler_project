# Startup Module

## Purpose

The startup module orchestrates the application initialization sequence. It ensures that all required services are properly initialized before the app launches, handles startup failures gracefully, and restores user sessions.

## Startup Pipeline

The startup process follows this sequence:

```
1. Initialize Flutter Bindings
   ↓
2. Load Environment Configuration
   ↓
3. Configure Dependency Injection
   ↓
4. Initialize Database
   ↓
5. Restore Session
   ↓
6. Configure Logging
   ↓
7. Configure Error Reporting
   ↓
8. Launch Application
```

## Responsibilities

- **Flutter Bindings Initialization**: Prepare Flutter framework for native plugins
- **Configuration Loading**: Load environment-specific settings (API URLs, feature flags)
- **Dependency Injection**: Register all services with the service locator
- **Database Initialization**: Open database and run migrations
- **Session Restoration**: Restore user session from stored tokens
- **Logging Setup**: Configure log levels and destinations
- **Error Reporting Setup**: Enable crash reporting and error tracking
- **Failure Handling**: Handle startup failures gracefully with user-friendly messages

## Components

### StartupConfig

Holds environment-specific configuration values:
- API base URL
- WebSocket URL
- Environment name (dev, staging, prod)
- Feature flags (debug logging, crash reporting, analytics)

### StartupDependencies

Configures the dependency injection container:
- Registers all services with GetIt
- Ensures proper registration order
- Handles initialization failures

### StartupSession

Restores user session from stored authentication:
- Validates stored tokens
- Extracts user ID from JWT
- Sets up user context

### StartupRunner

Orchestrates the entire startup pipeline:
- Coordinates all startup steps
- Handles failures gracefully
- Returns error screen or app widget

## Why Startup Module Exists

1. **Separation of Concerns**: Keeps startup logic separate from main.dart
2. **Testability**: Startup logic can be tested independently
3. **Error Handling**: Centralized error handling for startup failures
4. **Maintainability**: Easy to add or modify startup steps
5. **Debugging**: Clear separation makes startup issues easier to diagnose

## Initialization Order

The order of initialization is critical:

1. **Flutter Bindings First**: Required before any native plugin usage
2. **Configuration Second**: Needed for dependency registration
3. **Dependencies Third**: Required by all other components
4. **Database Fourth**: Depends on dependencies being ready
5. **Session Fifth**: Depends on storage and user context
6. **Logging/Reporting Last**: Can use other initialized services

## Error Handling

Startup failures are caught at each step:

- **Development**: Shows detailed error information with stack traces
- **Production**: Shows user-friendly error message with retry option
- **All Errors**: Logged for debugging and crash reporting

## Usage in main.dart

```dart
void main() {
  runZonedGuarded(
    () {
      FlutterError.onError = _handleFlutterError;
      _runApp();
    },
    _handleZoneError,
  );
}

Future<void> _runApp() async {
  final startupRunner = StartupRunner(
    config: StartupConfig.load(),
    appBuilder: (getIt) => _buildApp(getIt),
  );

  final appWidget = await startupRunner.run();
  runApp(appWidget);
}
```

## Guidelines

- Keep startup steps atomic and focused
- Each step should have clear success/failure criteria
- Log progress at each step for debugging
- Handle failures gracefully with user-friendly messages
- Never block the UI thread during startup
- Consider startup time optimization for large apps
