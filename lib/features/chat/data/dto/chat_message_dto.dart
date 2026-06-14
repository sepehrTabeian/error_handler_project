import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageDto {
  final String localId;
  final String? serverId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final MessageSendStatus status;

  const ChatMessageDto({
    required this.localId,
    required this.serverId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.status,
  });

  factory ChatMessageDto.fromEntity(ChatMessageEntity entity) {
    return ChatMessageDto(
      localId: entity.localId,
      serverId: entity.serverId,
      userId: entity.userId,
      text: entity.text,
      createdAt: entity.createdAt,
      status: entity.status,
    );
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      localId: localId,
      serverId: serverId,
      userId: userId,
      text: text,
      createdAt: createdAt,
      status: status,
    );
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      localId: json['client_message_id'] as String,
      serverId: json['id'] as String?,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: MessageSendStatus.sent,
    );
  }

  ChatMessageDto copyWith({
    String? serverId,
    MessageSendStatus? status,
  }) {
    return ChatMessageDto(
      localId: localId,
      serverId: serverId ?? this.serverId,
      userId: userId,
      text: text,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}