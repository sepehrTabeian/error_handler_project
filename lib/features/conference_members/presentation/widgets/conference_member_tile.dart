import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conference_participant_entity.dart';
import '../../domain/entities/participant_role.dart';
import '../bloc/conference_members_bloc.dart';
import '../bloc/conference_members_event.dart';

/// Widget representing a single conference participant tile.
/// 
/// Displays the participant's avatar, name, role, online status,
/// mute status, and selection state.
/// 
/// Uses ValueKey(participant.id) for efficient ListView.builder updates.
class ConferenceMemberTile extends StatelessWidget {
  final ConferenceParticipantEntity participant;
  final bool isSelected;

  const ConferenceMemberTile({
    super.key,
    required this.participant,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(participant.id),
      leading: _buildAvatar(),
      title: Text(
        participant.fullName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          _buildRoleBadge(),
          const SizedBox(width: 8),
          _buildOnlineIndicator(),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMuteButton(context),
          _buildCheckbox(context),
        ],
      ),
      onTap: () {
        context.read<ConferenceMembersBloc>().add(
              ConferenceParticipantSelectionToggled(participant.id),
            );
      },
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundImage: participant.avatarUrl != null
          ? NetworkImage(participant.avatarUrl!)
          : null,
      child: participant.avatarUrl == null
          ? Text(
              participant.fullName[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          : null,
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor(participant.role).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRoleColor(participant.role),
          width: 1,
        ),
      ),
      child: Text(
        _getRoleDisplayName(participant.role),
        style: TextStyle(
          color: _getRoleColor(participant.role),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: participant.isOnline ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          participant.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: participant.isOnline ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMuteButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        participant.isMuted ? Icons.mic_off : Icons.mic,
        color: participant.isMuted ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        context.read<ConferenceMembersBloc>().add(
              ConferenceParticipantMuteToggled(participant.id),
            );
      },
      tooltip: participant.isMuted ? 'Unmute' : 'Mute',
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: isSelected,
      onChanged: (_) {
        context.read<ConferenceMembersBloc>().add(
              ConferenceParticipantSelectionToggled(participant.id),
            );
      },
    );
  }

  Color _getRoleColor(ParticipantRole role) {
    switch (role) {
      case ParticipantRole.host:
        return Colors.purple;
      case ParticipantRole.moderator:
        return Colors.blue;
      case ParticipantRole.member:
        return Colors.green;
      case ParticipantRole.guest:
        return Colors.orange;
    }
  }

  String _getRoleDisplayName(ParticipantRole role) {
    switch (role) {
      case ParticipantRole.host:
        return 'Host';
      case ParticipantRole.moderator:
        return 'Moderator';
      case ParticipantRole.member:
        return 'Member';
      case ParticipantRole.guest:
        return 'Guest';
    }
  }
}
