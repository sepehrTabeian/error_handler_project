import '../../domain/entities/example_entity.dart';
import 'package:equatable/equatable.dart';

/// Base class for all example feature states.
///
/// States represent the UI state of the feature.
/// States are immutable and should never be mutated directly.
sealed class ExampleState extends Equatable {
  const ExampleState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class ExampleInitial extends ExampleState {
  const ExampleInitial();
}

/// Loading state while fetching data.
class ExampleLoading extends ExampleState {
  const ExampleLoading();
}

/// Loaded state with example data.
class ExampleLoaded extends ExampleState {
  final List<ExampleEntity> examples;

  const ExampleLoaded(this.examples);

  @override
  List<Object?> get props => [examples];
}

/// Error state with error message.
class ExampleError extends ExampleState {
  final String message;

  const ExampleError(this.message);

  @override
  List<Object?> get props => [message];
}
