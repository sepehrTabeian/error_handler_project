import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conference_members_bloc.dart';
import '../bloc/conference_members_event.dart';

/// Search field widget for filtering conference participants.
/// 
/// Dispatches ConferenceMembersSearchChanged event when the user types.
/// 
/// Why this does not use debounce:
/// - Local search filtering is fast enough for a few hundred participants
/// - The actual filtering is done in the state's filteredParticipants getter
/// - No API calls are made for local search
/// - The UI updates immediately on every keystroke
/// 
/// If this were remote search:
/// - Use debounce to wait for user to stop typing before making API call
/// - Use restartable transformer to cancel previous in-flight requests
/// - This reduces server load and prevents race conditions
class ConferenceMemberSearchField extends StatelessWidget {
  final String initialQuery;

  const ConferenceMemberSearchField({
    super.key,
    this.initialQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search participants...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: initialQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  context
                      .read<ConferenceMembersBloc>()
                      .add(const ConferenceMembersSearchChanged(''));
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onChanged: (query) {
        context
            .read<ConferenceMembersBloc>()
            .add(ConferenceMembersSearchChanged(query));
      },
    );
  }
}
