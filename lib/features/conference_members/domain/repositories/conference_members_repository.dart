import '../entities/conference_participant_entity.dart';
import '../entities/result.dart';

/// Repository abstraction for conference members operations.
/// 
/// This is a domain layer interface and must remain framework-agnostic.
/// The actual implementation will be in the data layer.
/// 
/// This follows the Dependency Inversion Principle: high-level modules
/// (use cases) depend on abstractions, not concrete implementations.
abstract interface class ConferenceMembersRepository {
  /// Fetches the list of conference participants.
  /// 
  /// Returns [Success] with the list of participants if successful.
  /// Returns [FailureResult] with an error message if the operation failed.
  Future<Result<List<ConferenceParticipantEntity>>> getParticipants();

  /// Updates the mute status of a participant.
  /// 
  /// Returns [Success] if the update was persisted successfully.
  /// Returns [FailureResult] with an error message if the operation failed.
  /// 
  /// Parameters:
  /// - participantId: The unique identifier of the participant
  /// - isMuted: The new mute status
  Future<Result<void>> updateMuteStatus({
    required String participantId,
    required bool isMuted,
  });
}
