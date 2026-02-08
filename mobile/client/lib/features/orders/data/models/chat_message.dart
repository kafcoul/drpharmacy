class ChatMessage {
  final int id;
  final String message;
  final String senderType;
  final int senderId;
  final bool isMine;
  final DateTime? readAt;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderType,
    required this.senderId,
    required this.isMine,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      message: json['message'] as String,
      senderType: json['sender_type'] as String,
      senderId: json['sender_id'] as int,
      isMine: json['is_mine'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
