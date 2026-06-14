import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conference_participant_entity.dart';
import '../../domain/usecases/get_conference_participants_usecase.dart';
import '../../domain/usecases/update_participant_mute_status_usecase.dart';
import 'conference_members_event.dart';
import 'conference_members_state.dart';

/// Bloc for managing conference members state and handling user interactions.
/// 
/// This bloc handles:
/// - Loading participants from the repository
/// - Local search filtering
/// - Participant selection tracking
/// - Mute status updates with optimistic updates and rollback
class ConferenceMembersBloc
    extends Bloc<ConferenceMembersEvent, ConferenceMembersState> {
  final GetConferenceParticipantsUseCase _getParticipantsUseCase;
  final UpdateParticipantMuteStatusUseCase _updateMuteStatusUseCase;

  ConferenceMembersBloc(
    this._getParticipantsUseCase,
    this._updateMuteStatusUseCase,
  ) : super(const ConferenceMembersInitial()) {
    on<ConferenceMembersStarted>(_onStarted);
    on<ConferenceMembersSearchChanged>(_onSearchChanged);
    on<ConferenceParticipantSelectionToggled>(_onSelectionToggled);
    on<ConferenceParticipantMuteToggled>(_onMuteToggled);
    on<ConferenceSelectionCleared>(_onSelectionCleared);
  }

  /// Handles ConferenceMembersStarted event.
  /// 
  /// Emits loading state, calls the use case to fetch participants,
  /// and emits success or failure state based on the result.
  Future<void> _onStarted(
    ConferenceMembersStarted event,
    Emitter<ConferenceMembersState> emit,
  ) async {
    emit(const ConferenceMembersLoading());

    final result = await _getParticipantsUseCase();

    result.when(
      success: (participants) {
        emit(ConferenceMembersLoaded(participants: participants));
      },
      failure: (message) {
        emit(ConferenceMembersFailure(message));
      },
    );
  }

  /// Handles ConferenceMembersSearchChanged event.
  /// 
  /// Updates the search query in the state.
  /// The actual filtering is done in the state's filteredParticipants getter.
  /// 
  /// Why this does not call API for local search:
  /// - Local filtering is done on the already-loaded participants list
  /// - No network calls are needed
  /// - The filteredParticipants getter computes the result on demand
  /// - This is fast enough for a few hundred participants
  /// 
  /// If this were remote search:
  /// - Use restartable transformer to cancel previous requests
  /// - Use debounce to wait for user to stop typing
  /// - Call API with the search query
  /// - Update participants with the server-filtered results
  void _onSearchChanged(
    ConferenceMembersSearchChanged event,
    Emitter<ConferenceMembersState> emit,
  ) {
    if (state is! ConferenceMembersLoaded) return;

    final currentState = state as ConferenceMembersLoaded;

    emit(currentState.copyWith(searchQuery: event.query));
  }

  /// Handles ConferenceParticipantSelectionToggled event.
  /// 
  /// Toggles the selection state of a participant.
  /// 
  /// Important: Never mutate state.selectedParticipantIds directly.
  /// Always create a new Set from the existing one.
  /// 
  /// Correct:
  /// final updatedSelectedIds = Set<String>.from(state.selectedParticipantIds);
  /// 
  /// Wrong:
  /// state.selectedParticipantIds.add(id);
  void _onSelectionToggled(
    ConferenceParticipantSelectionToggled event,
    Emitter<ConferenceMembersState> emit,
  ) {
    if (state is! ConferenceMembersLoaded) return;

    final currentState = state as ConferenceMembersLoaded;

    // Create a new Set from the existing one (immutable update)
    final updatedSelectedIds = Set<String>.from(currentState.selectedParticipantIds);

    if (updatedSelectedIds.contains(event.participantId)) {
      updatedSelectedIds.remove(event.participantId);
    } else {
      updatedSelectedIds.add(event.participantId);
    }

    emit(currentState.copyWith(selectedParticipantIds: updatedSelectedIds));
  }

  /// Handles ConferenceParticipantMuteToggled event.
  /// 
  /// Performs an optimistic update of the mute status,
  /// calls the use case to persist the change, and rolls back on failure.
  /// 
  /// Process:
  /// 1. Save previous participants list for potential rollback
  /// 2. Create optimistic participants list with muted status toggled
  /// 3. Emit optimistic state (UI updates immediately)
  /// 4. Call use case to persist the change
  /// 5. If success: keep optimistic state
  /// 6. If failure: rollback to previous participants list and show error
  Future<void> _onMuteToggled(
    ConferenceParticipantMuteToggled event,
    Emitter<ConferenceMembersState> emit,
  ) async {
    if (state is! ConferenceMembersLoaded) return;

    final currentState = state as ConferenceMembersLoaded;

    // Step 1: Save previous participants for potential rollback
    final previousParticipants = currentState.participants;

    // Step 2: Find the participant and create optimistic update
    final participantIndex =
        previousParticipants.indexWhere((p) => p.id == event.participantId);

    if (participantIndex == -1) {
      // Participant not found, do nothing
      return;
    }

    final participant = previousParticipants[participantIndex];
    final updatedParticipant =
        participant.copyWith(isMuted: !participant.isMuted);

    // Step 3: Create optimistic participants list
    final optimisticParticipants = List<ConferenceParticipantEntity>.from(
      previousParticipants,
    );
    optimisticParticipants[participantIndex] = updatedParticipant;

    // Step 4: Emit optimistic state (UI updates immediately)
    emit(currentState.copyWith(
      participants: optimisticParticipants,
      errorMessage: null,
    ));

    // Step 5: Call use case to persist the change
    final result = await _updateMuteStatusUseCase(
      participantId: event.participantId,
      isMuted: updatedParticipant.isMuted,
    );

    // Step 6: Handle success or failure
    result.when(
      success: (_) {
        // Success: do nothing, optimistic state is now the real state
      },
      failure: (message) {
        // Failure: rollback to previous participants and show error
        emit(currentState.copyWith(
          participants: previousParticipants,
          errorMessage: message,
        ));
      },
    );
  }

  /// Handles ConferenceSelectionCleared event.
  /// 
  /// Clears all selected participant IDs.
  void _onSelectionCleared(
    ConferenceSelectionCleared event,
    Emitter<ConferenceMembersState> emit,
  ) {
    if (state is! ConferenceMembersLoaded) return;

    final currentState = state as ConferenceMembersLoaded;

    emit(currentState.copyWith(selectedParticipantIds: const {}));
  }
}

/// Extension on Result for pattern matching.
extension ResultX<T> on Result<T> {
  void when({
    required void Function(T value) success,
    required void Function(String message) failure,
  }) {
    if (this is Success<T>) {
      success((this as Success<T>).value);
    } else if (this is FailureResult<T>) {
      failure((this as FailureResult<T>).message);
    }
  }
}
