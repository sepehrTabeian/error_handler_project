import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';
import 'package:error_handler_project/features/chat/domain/entities/send_message_request_entity.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> watchMessages();

  Future<Result<void>> sendMessage(SendMessageRequestEntity request);

  Future<Result<void>> syncPendingMessages();

  Future<Result<void>> connectRealtime();

  Future<void> disconnectRealtime();
}