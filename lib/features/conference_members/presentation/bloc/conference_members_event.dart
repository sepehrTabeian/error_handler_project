import 'package:equatable/equatable.dart';

/// Base class for all conference members events.
/// 
/// Events represent user actions or system events that trigger state changes.
/// Following the Bloc pattern, events are immutable and extend Equatable.
abstract class ConferenceMembersEvent extends Equatable {
  const ConferenceMembersEvent();

  @override
  List<Object?> get props => [];
}

/// Event fired when the conference members screen is first loaded.
/// 
/// This triggers loading the initial list of participants from the repository.
class ConferenceMembersStarted extends ConferenceMembersEvent {
  const ConferenceMembersStarted();
}

/// Event fired when the search query changes.
/// 
/// This updates the search query in the state.
/// The actual filtering is done in the state's filteredParticipants getter.
/// 
/// Why local search does not require debounce:
/// - Local filtering is O(n) where n is the number of participants
/// - For a few hundred participants, this is fast enough to run on every keystroke
/// - No network calls are made, so no need to debounce API requests
/// 
/// Why remote search should use debounce/restartable:
/// - Remote search makes API calls on every keystroke
/// - Debouncing reduces the number of API calls by waiting for the user to stop typing
/// - Restartable transformer cancels previous in-flight requests when a new one arrives
/// - This prevents race conditions and reduces server load
class ConferenceMembersSearchChanged extends ConferenceMembersEvent {
  final String query;

  const ConferenceMembersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event fired when a participant's selection is toggled.
/// 
/// This adds or removes the participant ID from the selected set.
/// 
/// Important: Never mutate state.selectedParticipantIds directly.
/// Always create a new Set from the existing one.
/// 
/// Correct:
/// final updatedSelectedIds = Set<String>.from(state.selectedParticipantIds);
/// 
/// Wrong:
/// state.selectedParticipantIds.add(id);
class ConferenceParticipantSelectionToggled extends ConferenceMembersEvent {
  final String participantId;

  const ConferenceParticipantSelectionToggled(this.participantId);

  @override
  List<Object?> get props => [participantId];
}

/// Event fired when a participant's mute status is toggled.
/// 
/// This performs an optimistic update of the mute status,
/// calls the use case to persist the change, and rolls back on failure.
class ConferenceParticipantMuteToggled extends ConferenceMembersEvent {
  final String participantId;

  const ConferenceParticipantMuteToggled(this.participantId);

  @override
  List<Object?> get props => [participantId];
}

/// Event fired when all selections should be cleared.
/// 
/// This resets the selectedParticipantIds set to empty.
class ConferenceSelectionCleared extends ConferenceMembersEvent {
  const ConferenceSelectionCleared();
}
