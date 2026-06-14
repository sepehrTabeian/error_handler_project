import 'package:error_handler_project/features/chat/data/dto/chat_message_dto.dart';

// lib/features/chat/data/datasources/chat_local_datasource.dart

import '../dto/chat_message_dto.dart';

abstract class ChatLocalDataSource {
  Stream<List<ChatMessageDto>> watchMessages();

  Future<void> saveMessage(ChatMessageDto message);

  Future<void> updateMessage(ChatMessageDto message);

  Future<List<ChatMessageDto>> getPendingMessages();

  Future<List<ChatMessageDto>> getFailedMessages();

  Future<void> markAsPending(String localId);

  Future<void> deleteMessage(String localId);
}