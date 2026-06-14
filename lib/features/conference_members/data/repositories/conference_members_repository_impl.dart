import '../../domain/entities/conference_participant_entity.dart';
import '../../domain/entities/participant_role.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/conference_members_repository.dart';

/// Implementation of ConferenceMembersRepository.
/// 
/// This is in the data layer and can use framework-specific dependencies
/// like Dio, HTTP clients, storage, etc.
/// 
/// For demonstration purposes, this implementation simulates API calls
/// with occasional failures to demonstrate rollback behavior.
class ConferenceMembersRepositoryImpl
    implements ConferenceMembersRepository {
  int _callCount = 0;

  @override
  Future<Result<List<ConferenceParticipantEntity>>> getParticipants() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return sample participants
    final participants = [
      ConferenceParticipantEntity(
        id: '1',
        fullName: 'John Smith',
        role: ParticipantRole.host,
        isMuted: false,
        isOnline: true,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ConferenceParticipantEntity(
        id: '2',
        fullName: 'Jane Doe',
        role: ParticipantRole.moderator,
        isMuted: false,
        isOnline: true,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      ConferenceParticipantEntity(
        id: '3',
        fullName: 'Bob Johnson',
        role: ParticipantRole.member,
        isMuted: true,
        isOnline: true,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      ConferenceParticipantEntity(
        id: '4',
        fullName: 'Alice Williams',
        role: ParticipantRole.member,
        isMuted: false,
        isOnline: false,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ConferenceParticipantEntity(
        id: '5',
        fullName: 'Charlie Brown',
        role: ParticipantRole.guest,
        isMuted: false,
        isOnline: true,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];

    return Success(participants);
  }

  @override
  Future<Result<void>> updateMuteStatus({
    required String participantId,
    required bool isMuted,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _callCount++;

    // Simulate failure every 5th call to demonstrate rollback
    if (_callCount % 5 == 0) {
      return const FailureResult(
          'Failed to update mute status. Please try again.');
    }

    // In a real implementation, this would make an API call
    // Example:
    // try {
    //   await dio.patch('/participants/$participantId', data: {
    //     'isMuted': isMuted,
    //   });
    //   return const Success(null);
    // } catch (e) {
    //   return FailureResult(e.toString());
    // }

    return const Success(null);
  }
}
