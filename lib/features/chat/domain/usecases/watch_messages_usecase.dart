import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';
import 'package:error_handler_project/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<List<ChatMessageEntity>> call() {
    return repository.watchMessages();
  }
}