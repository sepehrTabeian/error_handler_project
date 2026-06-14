# Example Feature Template

This is a template for adding new features to the application. Use this structure as a reference when creating new features.

## Feature Structure

```
example_feature/
├── data/
│   ├── datasources/
│   │   ├── example_local_datasource.dart
│   │   ├── example_remote_datasource.dart
│   │   └── example_socket_datasource.dart
│   ├── dto/
│   │   ├── example_entity_dto.dart
│   │   └── example_request_dto.dart
│   └── repositories/
│       └── example_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── example_entity.dart
│   │   └── example_request_entity.dart
│   ├── repositories/
│   │   └── example_repository.dart
│   └── usecases/
│       ├── get_example_usecase.dart
│       └── create_example_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── example_bloc.dart
    │   ├── example_event.dart
    │   └── example_state.dart
    ├── widgets/
    │   └── example_widget.dart
    └── pages/
        └── example_page.dart
```

## Layer Responsibilities

### Domain Layer
- **Entities**: Business objects, framework-agnostic
- **Repositories**: Abstract interfaces for data access
- **Use Cases**: Single business rules, orchestrate data flow

### Data Layer
- **Data Sources**: External system integrations (API, database, WebSocket)
- **DTOs**: Data transfer objects for serialization
- **Repository Implementations**: Implement domain interfaces

### Presentation Layer
- **Bloc**: State management with events and states
- **Widgets**: Reusable UI components
- **Pages**: Screen-level widgets

## Key Principles

1. **Clean Architecture**: Dependencies point inward (Presentation → Domain ← Data)
2. **Framework Agnostic Domain**: No Flutter, Dio, or JSON imports in domain layer
3. **Immutable State**: States are never mutated, always new instances
4. **Result Pattern**: Use Result<T> for success/failure handling
5. **Dependency Injection**: Register in core/di/injection_container.dart

## Adding a New Feature

1. Copy this template structure
2. Replace "example" with your feature name
3. Implement domain layer first (entities, repositories, use cases)
4. Implement data layer (data sources, DTOs, repository implementations)
5. Implement presentation layer (bloc, widgets, pages)
6. Register dependencies in core/di/injection_container.dart
7. Add navigation in main.dart or router
8. Write tests for each layer

## Checklist

- [ ] Domain entities are framework-agnostic
- [ ] Repository interfaces are in domain layer
- [ ] Repository implementations are in data layer
- [ ] Use cases encapsulate single business rules
- [ ] DTOs handle serialization/deserialization
- [ ] Bloc uses immutable states
- [ ] Events represent user actions
- [ ] States represent UI states
- [ ] Widgets are reusable and focused
- [ ] Dependencies are registered in DI container
- [ ] Error handling uses Result pattern
- [ ] Failures have user-friendly messages
