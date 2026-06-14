import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatMessageSubmitted extends ChatEvent {
  final String text;

  const ChatMessageSubmitted(this.text);
}

class ChatPendingSyncRequested extends ChatEvent {
  const ChatPendingSyncRequested();
}

class ChatMessagesChanged extends ChatEvent {
  final List<ChatMessageEntity> messages;

  const ChatMessagesChanged(this.messages);
}