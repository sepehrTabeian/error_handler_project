import '../entities/conference_participant_entity.dart';
import '../entities/result.dart';
import '../repositories/conference_members_repository.dart';

/// Use case for fetching conference participants.
/// 
/// This is a domain layer use case and must remain framework-agnostic.
/// It encapsulates a single business rule: fetching the list of participants.
/// 
/// Use cases are the entry point for business logic from the presentation layer.
/// They orchestrate the flow of data between the presentation and data layers.
class GetConferenceParticipantsUseCase {
  final ConferenceMembersRepository _repository;

  GetConferenceParticipantsUseCase(this._repository);

  /// Executes the get participants operation.
  /// 
  /// Delegates to the repository to fetch the participants.
  /// Returns the result from the repository.
  Future<Result<List<ConferenceParticipantEntity>>> call() {
    return _repository.getParticipants();
  }
}
