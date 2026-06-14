enum MessageSendStatus {
  pending,
  sent,
  failed,
}

class ChatMessageEntity {
  final String localId;
  final String? serverId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final MessageSendStatus status;

  const ChatMessageEntity({
    required this.localId,
    required this.serverId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.status,
  });

  ChatMessageEntity copyWith({
    String? serverId,
    MessageSendStatus? status,
  }) {
    return ChatMessageEntity(
      localId: localId,
      serverId: serverId ?? this.serverId,
      userId: userId,
      text: text,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}