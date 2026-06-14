import 'package:error_handler_project/features/chat/domain/repositories/chat_repository.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';

class SyncPendingMessagesUseCase {
  final ChatRepository repository;

  SyncPendingMessagesUseCase(this.repository);

  Future<Result<void>> call() {
    return repository.syncPendingMessages();
  }
}