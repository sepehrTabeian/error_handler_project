# Conference Members Feature

## Business Goal

The conference members feature provides a panel for managing conference participants. It enables viewing participants, searching by name, selecting multiple participants, and toggling mute status for participants with appropriate permissions.

## Architecture

### Clean Architecture Layers

```
Presentation Layer
├── ConferenceMembersBloc (State management)
├── ConferenceMembersEvent (User actions)
├── ConferenceMembersState (UI state)
├── ConferenceMemberTile (Participant widget)
├── ConferenceMemberSearchField (Search widget)
└── ConferenceMembersPage (UI)
    ↓ depends on
Domain Layer
├── ConferenceParticipantEntity (Domain entity)
├── ParticipantRole (Role enum)
├── Result<T> (Result type)
├── ConferenceMembersRepository (Repository interface)
├── GetConferenceParticipantsUseCase (Fetch participants)
└── UpdateParticipantMuteStatusUseCase (Toggle mute)
    ↓ depends on
Data Layer
├── ConferenceMembersRepositoryImpl (Repository implementation)
└── (No external data sources - simulated for demo)
```

## Entities

### ConferenceParticipantEntity

Domain entity representing a conference participant:

- **id**: Unique participant identifier
- **name**: Participant display name
- **role**: Participant role (host, moderator, speaker, attendee)
- **isOnline**: Whether participant is currently online
- **isMuted**: Whether participant is muted
- **avatarUrl**: Optional avatar image URL

### ParticipantRole

Enum representing participant role:
- **host**: Conference host (full permissions)
- **moderator**: Moderator (can mute others)
- **speaker**: Speaker (can be muted)
- **attendee**: Regular attendee (can be muted)

### Result<T>

Generic result type for success/failure:
- **Success<T>**: Successful operation with data
- **FailureResult<T>**: Failed operation with error message

## Repository

### ConferenceMembersRepository Interface

```dart
abstract class ConferenceMembersRepository {
  Future<Result<List<ConferenceParticipantEntity>>> getParticipants();
  Future<Result<void>> updateMuteStatus(String participantId, bool isMuted);
}
```

### ConferenceMembersRepositoryImpl

Simulated implementation for demonstration:
- Simulates network delay
- Generates mock participant data
- Simulates occasional failures for mute toggle
- In production, would make actual API calls

## Use Cases

### GetConferenceParticipantsUseCase

Fetches conference participants:

**Flow**:
1. Call repository to fetch participants
2. Return Result<List<ConferenceParticipantEntity>>
3. Handle errors gracefully

### UpdateParticipantMuteStatusUseCase

Toggles participant mute status:

**Flow**:
1. Validate participant ID
2. Call repository to update mute status
3. Return Result<void>
4. Handle errors gracefully

**Optimistic Update**:
- UI updates immediately
- Repository call in background
- Rollback on failure

## Bloc

### ConferenceMembersBloc

Manages conference members state:

**Events**:
- `ConferenceMembersStarted`: Initialize and load participants
- `ConferenceParticipantsLoaded`: Internal event after load
- `ConferenceSearchQueryChanged`: User changed search query
- `ConferenceParticipantSelectionToggled`: User toggled selection
- `ConferenceParticipantMuteToggled`: User toggled mute status

**States**:
- **ConferenceMembersInitial**: Initial state
- **ConferenceMembersLoading**: Loading participants
- **ConferenceMembersLoaded**: Participants loaded
- **ConferenceMembersError**: Error state

**Computed Getters**:
- **filteredParticipants**: Participants filtered by search query
- **selectedParticipantIds**: Set of selected participant IDs
- **selectedCount**: Number of selected participants

### State Immutability

State is immutable with computed getters:
- **participants**: List of all participants (List)
- **selectedParticipantIds**: Set of selected IDs (Set)
- **searchQuery**: Current search query

### Data Structure Rationale

**Why List for participants?**
- UI needs to render participants in a predictable order
- ListView.builder works naturally with ordered list
- Sorting by role, name, or join time is straightforward
- Order is important for user experience

**Why Set for selected IDs?**
- Checking whether a user is selected should be O(1) average
- Avoid using List<String> for selected IDs (List.contains is O(n))
- Matters when there are many participants
- Set provides efficient add, remove, and contains operations

**Why Map would be useful?**
- If frequent lookup/update by participantId is needed (e.g., mute/unmute)
- For mute/unmute, updating participant by id can be optimized with Map
- If using only List, indexWhere is O(n)
- For small code challenge, List is acceptable, but Map would improve performance for large lists

**Why local search does not require Set?**
- Search is performed on the full participant list
- Filtering is O(n) regardless of data structure
- Computed getter filters on each query change
- No need for additional Set for search results

## UI Components

### ConferenceMemberTile

Widget displaying a single participant:
- Shows participant name and role badge
- Shows online status indicator
- Shows mute button (with permission check)
- Shows selection checkbox
- Visual feedback for selection and mute state

### ConferenceMemberSearchField

Widget for searching participants:
- Text input field with debounce
- Filters participants by name
- Updates search query in Bloc
- Clear button to reset search

### ConferenceMembersPage

Main page with:
- Header with participant count
- Search field
- List of participant tiles
- Selection summary
- Batch actions (to be implemented)

## Search Strategy

### Local Search

Search is performed locally on the client:
- Filters participants by name (case-insensitive)
- Updates in real-time as user types
- No server round-trip required
- Fast response for large participant lists

### Implementation

```dart
List<ConferenceParticipantEntity> get filteredParticipants {
  if (searchQuery.isEmpty) {
    return participants;
  }
  return participants
      .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();
}
```

### Performance

- O(n) filtering on each query change
- Acceptable for participant lists up to thousands
- Could be optimized with debouncing (already in search field)
- Could use more efficient algorithms for very large lists

## Mute Strategy

### Permission Model

Only certain roles can mute others:
- **Host**: Can mute anyone
- **Moderator**: Can mute speakers and attendees
- **Speaker**: Can be muted by host/moderator
- **Attendee**: Can be muted by host/moderator

### Optimistic Update

Mute toggle uses optimistic updates:
1. User taps mute button
2. Bloc updates state immediately (optimistic)
3. UI shows new mute status
4. Repository call made in background
5. If success, state remains
6. If failure, state rolls back

### Rollback

When API call fails:
- Restore previous mute status
- Show error message to user
- Maintain data consistency
- Allow user to retry

## Selection Strategy

### Multi-Selection

Users can select multiple participants:
- Tap participant tile to toggle selection
- Selection state maintained in Set<String>
- Efficient O(1) add/remove/contains operations
- Selection count displayed in header

### Use Cases for Selection

- Batch mute/unmute (to be implemented)
- Batch remove from conference (to be implemented)
- Send message to selected (to be implemented)
- Export selected list (to be implemented)

## Performance Considerations

### Data Structures

- **List<ConferenceParticipantEntity>**: For ordered display
- **Set<String>**: For efficient selection tracking
- **ListView.builder**: Efficient rendering of large lists
- **ValueKey**: Optimizes widget rebuilds

### Rendering

- Only rebuild changed participant tiles
- Use const widgets where possible
- Avoid unnecessary rebuilds
- Computed getters for filtered results

### State Updates

- Immutable state prevents unnecessary rebuilds
- Never mutate state.selectedParticipantIds directly
- Always create new Set from existing one
- Equatable checks for actual changes

## Error Handling

### Network Errors

- Rollback optimistic update for mute
- Show error message to user
- Allow user to retry

### Validation Errors

- Validate participant ID before operations
- Validate permissions before mute
- Show validation errors

## Testing Considerations

### Unit Tests

- GetConferenceParticipantsUseCase with mocked repository
- UpdateParticipantMuteStatusUseCase with mocked repository
- Bloc event handling and state emissions
- Optimistic update logic
- Rollback logic
- Search filtering logic

### Integration Tests

- End-to-end participant loading
- Mute toggle with API failure
- Selection state management
- Search functionality

### Widget Tests

- ConferenceMemberTile rendering
- ConferenceMemberSearchField behavior
- ConferenceMembersPage UI
- Selection state display
- Mute button visibility based on role

## Future Enhancements

### Real-time Updates

- WebSocket for real-time participant changes
- Automatic refresh on participant join/leave
- Real-time mute status updates
- Online status changes

### Advanced Features

- Participant permissions management
- Raise hand feature
- Screen sharing indicators
- Audio/video indicators
- Breakout room support
- Recording indicators

### Performance

- Pagination for large participant lists
- Virtual scrolling for thousands of participants
- Lazy loading of participant data
- Image caching for avatars

## Guidelines

- Always use immutable state
- Never mutate state.selectedParticipantIds directly
- Always create new Set from existing one
- Implement optimistic updates for better UX
- Rollback on failure to maintain consistency
- Use efficient data structures (List for display, Set for selection)
- Test rollback scenarios thoroughly
- Show user-friendly error messages
- Log technical errors for debugging
- Keep UI responsive during API calls
- Validate permissions before actions
- Use computed getters for derived state
