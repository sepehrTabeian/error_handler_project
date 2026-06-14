import '../../domain/entities/example_entity.dart';
import '../../domain/entities/example_request_entity.dart';

/// Base class for all example feature events.
///
/// Events represent user actions or system events that trigger
/// state changes in the Bloc.
sealed class ExampleEvent {
  const ExampleEvent();
}

/// Event fired when the example screen is first loaded.
class ExampleStarted extends ExampleEvent {
  const ExampleStarted();
}

/// Event fired when user requests to fetch examples.
class ExamplesRequested extends ExampleEvent {
  const ExamplesRequested();
}

/// Event fired when user creates a new example.
class ExampleCreated extends ExampleEvent {
  final ExampleRequestEntity request;

  const ExampleCreated(this.request);
}

/// Event fired when user updates an example.
class ExampleUpdated extends ExampleEvent {
  final ExampleEntity entity;

  const ExampleUpdated(this.entity);
}

/// Event fired when user deletes an example.
class ExampleDeleted extends ExampleEvent {
  final String id;

  const ExampleDeleted(this.id);
}
