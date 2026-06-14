import 'package:equatable/equatable.dart';
import '../../domain/entities/conference_participant_entity.dart';

/// Base class for all conference members states.
/// 
/// States represent the immutable data that the UI renders.
/// Following the Bloc pattern, states are immutable and extend Equatable.
abstract class ConferenceMembersState extends Equatable {
  const ConferenceMembersState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is first created.
class ConferenceMembersInitial extends ConferenceMembersState {
  const ConferenceMembersInitial();
}

/// Loading state while fetching participants.
class ConferenceMembersLoading extends ConferenceMembersState {
  const ConferenceMembersLoading();
}

/// Loaded state containing the conference members data.
/// 
/// Why List is used for display:
/// - UI needs to render participants in a predictable order
/// - ListView.builder works naturally with an ordered list
/// - Sorting by role, name, or join time is straightforward with List
/// - The order is important for the user experience
/// 
/// Why Set is used for selected IDs:
/// - Checking whether a user is selected should be O(1) average
/// - Avoid using List&lt;String&gt; for selected IDs because List.contains is O(n)
/// - This matters when there are many participants
/// - Set provides efficient add, remove, and contains operations
/// 
/// When Map would be useful:
/// - If frequent lookup/update by participantId is needed (e.g., mute/unmute)
/// - For mute/unmute, updating participant by id can be optimized with Map
/// - If using only List, indexWhere is O(n)
/// - For small code challenge, List is acceptable, but Map would improve performance for large lists
/// 
/// Why local search does not require Set:
/// - Search filtering is computed from the original participants list
/// - The filtered result is a new List, not a Set
/// - Set is only needed for selection tracking, not for search results
/// - Search needs to preserve order, which Set does not guarantee
/// 
/// Why search filtering is O(n) and acceptable for local lists:
/// - Local filtering iterates through all participants once
/// - For a few hundred participants, this is fast enough (milliseconds)
/// - No network calls are involved
/// - The complexity is linear with the number of participants
/// - If the list grows to thousands, consider server-side search or pagination
class ConferenceMembersLoaded extends ConferenceMembersState {
  /// The complete list of participants.
  /// 
  /// This list is never mutated directly. All operations create new lists.
  final List<ConferenceParticipantEntity> participants;

  /// The current search query.
  /// 
  /// Used by filteredParticipants getter to filter the participants list.
  final String searchQuery;

  /// Set of selected participant IDs.
  /// 
  /// Using Set provides O(1) average time complexity for:
  /// - Checking if a participant is selected (contains)
  /// - Adding a participant to selection (add)
  /// - Removing a participant from selection (remove)
  /// 
  /// Never mutate this set directly. Always create a new Set from the existing one.
  final Set<String> selectedParticipantIds;

  /// Optional error message from a failed operation (e.g., mute update failed).
  final String? errorMessage;

  const ConferenceMembersLoaded({
    required this.participants,
    this.searchQuery = '',
    this.selectedParticipantIds = const {},
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced.
  /// 
  /// Used for immutable state updates.
  ConferenceMembersLoaded copyWith({
    List<ConferenceParticipantEntity>? participants,
    String? searchQuery,
    Set<String>? selectedParticipantIds,
    String? errorMessage,
  }) {
    return ConferenceMembersLoaded(
      participants: participants ?? this.participants,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedParticipantIds: selectedParticipantIds ?? this.selectedParticipantIds,
      errorMessage: errorMessage,
    );
  }

  /// Computed getter for filtered participants based on search query.
  /// 
  /// Search filters participants by:
  /// - fullName (case-insensitive)
  /// - role name (case-insensitive)
  /// 
  /// Implementation details:
  /// - Trim the query to remove leading/trailing whitespace
  /// - Convert to lowercase for case-insensitive matching
  /// - If query is empty, return all participants
  /// - Filter by checking if name or role contains the query
  /// 
  /// This is a local search operation with O(n) complexity.
  /// For a few hundred participants, this is fast enough.
  /// For remote search, use debounce + restartable transformer.
  List<ConferenceParticipantEntity> get filteredParticipants {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return participants;

    return participants.where((participant) {
      final name = participant.fullName.toLowerCase();
      final role = participant.role.name.toLowerCase();

      return name.contains(query) || role.contains(query);
    }).toList();
  }

  /// Computed getter for the number of selected participants.
  int get selectedCount => selectedParticipantIds.length;

  /// Computed getter for whether any participants are selected.
  bool get hasSelection => selectedParticipantIds.isNotEmpty;

  @override
  List<Object?> get props => [
        participants,
        searchQuery,
        selectedParticipantIds,
        errorMessage,
      ];
}

/// Error state when loading participants fails.
class ConferenceMembersFailure extends ConferenceMembersState {
  final String message;

  const ConferenceMembersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
