import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/conference_members_repository_impl.dart';
import '../../domain/usecases/get_conference_participants_usecase.dart';
import '../../domain/usecases/update_participant_mute_status_usecase.dart';
import '../bloc/conference_members_bloc.dart';
import '../bloc/conference_members_event.dart';
import '../bloc/conference_members_state.dart';
import '../widgets/conference_member_search_field.dart';
import '../widgets/conference_member_tile.dart';

/// Page displaying the conference members list.
/// 
/// This page contains:
/// - Search TextField at the top
/// - Selected count if any participants selected
/// - ListView.builder for filteredParticipants
/// - Each tile shows avatar, fullName, role, online/offline indicator, mute/unmute icon, checkbox
/// 
/// Performance notes:
/// - Use ListView.builder for participant rendering
/// - Use ValueKey(participant.id) for each tile
/// - Avoid rebuilding the whole page when only selection changes if possible
/// - For advanced optimization, use BlocSelector per participant tile
/// - For very large participant lists, consider pagination or server-side search
/// - For remote search, use debounce + restartable transformer
/// - For local search with a few hundred users, local filtering is acceptable
class ConferenceMembersPage extends StatelessWidget {
  const ConferenceMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // In a real app, use dependency injection (e.g., GetIt, Provider)
        // For this example, we create the dependencies manually
        final repository = ConferenceMembersRepositoryImpl();
        final getParticipantsUseCase = GetConferenceParticipantsUseCase(repository);
        final updateMuteStatusUseCase =
            UpdateParticipantMuteStatusUseCase(repository);
        return ConferenceMembersBloc(
          getParticipantsUseCase,
          updateMuteStatusUseCase,
        )..add(const ConferenceMembersStarted());
      },
      child: const ConferenceMembersView(),
    );
  }
}

/// The actual view widget for the conference members page.
/// 
/// Separated from the page to allow for easier testing and separation of concerns.
class ConferenceMembersView extends StatelessWidget {
  const ConferenceMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conference Members'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<ConferenceMembersBloc, ConferenceMembersState>(
            buildWhen: (previous, current) {
              // Only rebuild when selection count changes
              final previousCount = previous is ConferenceMembersLoaded
                  ? previous.selectedCount
                  : 0;
              final currentCount = current is ConferenceMembersLoaded
                  ? current.selectedCount
                  : 0;
              return previousCount != currentCount;
            },
            builder: (context, state) {
              if (state is ConferenceMembersLoaded && state.hasSelection) {
                return Row(
                  children: [
                    Text(
                      '${state.selectedCount} selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () {
                        context
                            .read<ConferenceMembersBloc>()
                            .add(const ConferenceSelectionCleared());
                      },
                      tooltip: 'Clear selection',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<ConferenceMembersBloc, ConferenceMembersState>(
        listener: (context, state) {
          // Show error message in SnackBar when a mute update fails
          if (state is ConferenceMembersLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<ConferenceMembersBloc, ConferenceMembersState>(
          builder: (context, state) {
            if (state is ConferenceMembersLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ConferenceMembersFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is ConferenceMembersLoaded) {
              return Column(
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConferenceMemberSearchField(
                      initialQuery: state.searchQuery,
                    ),
                  ),
                  // Participant list
                  Expanded(
                    child: state.filteredParticipants.isEmpty
                        ? Center(
                            child: Text(
                              state.searchQuery.isEmpty
                                  ? 'No participants'
                                  : 'No participants found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.filteredParticipants.length,
                            itemBuilder: (context, index) {
                              final participant =
                                  state.filteredParticipants[index];
                              final isSelected =
                                  state.selectedParticipantIds.contains(
                                        participant.id,
                                      );
                              return ConferenceMemberTile(
                                participant: participant,
                                isSelected: isSelected,
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
