import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/example_entity.dart';
import '../../domain/entities/example_request_entity.dart';
import '../../domain/usecases/create_example_usecase.dart';
import '../../domain/usecases/get_example_usecase.dart';
import '../../../../infrastructure/errors/result.dart';
import 'example_event.dart';
import 'example_state.dart';

/// Bloc for managing example feature state.
///
/// This Bloc coordinates the presentation flow for the example feature.
/// It handles events, executes use cases, and emits new states.
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final GetExampleUseCase getExampleUseCase;
  final CreateExampleUseCase createExampleUseCase;

  ExampleBloc({
    required this.getExampleUseCase,
    required this.createExampleUseCase,
  }) : super(const ExampleInitial()) {
    on<ExampleStarted>(_onStarted);
    on<ExamplesRequested>(_onExamplesRequested);
    on<ExampleCreated>(_onExampleCreated);
    on<ExampleUpdated>(_onExampleUpdated);
    on<ExampleDeleted>(_onExampleDeleted);
  }

  /// Handles ExampleStarted event.
  Future<void> _onStarted(
    ExampleStarted event,
    Emitter<ExampleState> emit,
  ) async {
    add(const ExamplesRequested());
  }

  /// Handles ExamplesRequested event.
  Future<void> _onExamplesRequested(
    ExamplesRequested event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    final result = await getExampleUseCase();

    switch (result) {
      case Success<List<ExampleEntity>>():
        emit(ExampleLoaded(result.data));
      case FailureResult<List<ExampleEntity>>():
        emit(ExampleError(result.failure.message));
    }
  }

  /// Handles ExampleCreated event.
  Future<void> _onExampleCreated(
    ExampleCreated event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    final result = await createExampleUseCase(event.request);

    switch (result) {
      case Success<ExampleEntity>():
        add(const ExamplesRequested());
      case FailureResult<ExampleEntity>():
        emit(ExampleError(result.failure.message));
    }
  }

  /// Handles ExampleUpdated event.
  Future<void> _onExampleUpdated(
    ExampleUpdated event,
    Emitter<ExampleState> emit,
  ) async {
    // TODO: Implement update logic
    add(const ExamplesRequested());
  }

  /// Handles ExampleDeleted event.
  Future<void> _onExampleDeleted(
    ExampleDeleted event,
    Emitter<ExampleState> emit,
  ) async {
    // TODO: Implement delete logic
    add(const ExamplesRequested());
  }
}
