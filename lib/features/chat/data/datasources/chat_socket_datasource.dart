import 'package:error_handler_project/features/chat/data/dto/chat_message_dto.dart';
import 'package:error_handler_project/features/chat/data/dto/send_message_dto.dart';

abstract class ChatSocketDataSource {
  Stream<ChatMessageDto> watchIncomingMessages();

  Future<void> connect();

  Future<void> disconnect();

  Future<void> sendMessage(SendMessageDto request);
}