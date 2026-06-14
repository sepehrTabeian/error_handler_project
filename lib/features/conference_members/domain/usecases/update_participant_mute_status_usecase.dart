import '../entities/result.dart';
import '../repositories/conference_members_repository.dart';

/// Use case for updating a participant's mute status.
/// 
/// This is a domain layer use case and must remain framework-agnostic.
/// It encapsulates a single business rule: updating mute status.
/// 
/// Use cases are the entry point for business logic from the presentation layer.
/// They orchestrate the flow of data between the presentation and data layers.
class UpdateParticipantMuteStatusUseCase {
  final ConferenceMembersRepository _repository;

  UpdateParticipantMuteStatusUseCase(this._repository);

  /// Executes the update mute status operation.
  /// 
  /// Delegates to the repository to persist the change.
  /// Returns the result from the repository.
  Future<Result<void>> call({
    required String participantId,
    required bool isMuted,
  }) {
    return _repository.updateMuteStatus(
      participantId: participantId,
      isMuted: isMuted,
    );
  }
}
