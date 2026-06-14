import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';
import 'package:equatable/equatable.dart';

class ChatState extends Equatable {
  final List<ChatMessageEntity> messages;
  final bool isSending;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isSending,
    errorMessage,
  ];
}