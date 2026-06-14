class SendMessageDto {
  final String localId;
  final String userId;
  final String text;
  final String createdAt;

  const SendMessageDto({
    required this.localId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_message_id': localId,
      'user_id': userId,
      'text': text,
      'created_at': createdAt,
    };
  }
}