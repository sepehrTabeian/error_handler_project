import 'package:equatable/equatable.dart';
import 'participant_role.dart';

/// Conference participant entity representing a participant in a conference.
/// 
/// This is a domain entity and must remain framework-agnostic.
/// No Flutter, Dio, or other framework imports should be added.
class ConferenceParticipantEntity extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final ParticipantRole role;
  final bool isMuted;
  final bool isOnline;
  final DateTime joinedAt;

  const ConferenceParticipantEntity({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isMuted,
    required this.isOnline,
    required this.joinedAt,
  });

  /// Creates a copy of this participant with the given fields replaced.
  /// 
  /// This is used for immutable state updates, especially when
  /// changing mute status or other properties.
  ConferenceParticipantEntity copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    ParticipantRole? role,
    bool? isMuted,
    bool? isOnline,
    DateTime? joinedAt,
  }) {
    return ConferenceParticipantEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline ?? this.isOnline,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        avatarUrl,
        role,
        isMuted,
        isOnline,
        joinedAt,
      ];
}
