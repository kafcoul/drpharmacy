class ChatMessage {
  final int id;
  final String content;
  final bool isMe;
  final String senderName;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.senderName,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      content: json['content'] as String,
      isMe: json['is_me'] as bool,
      senderName: json['sender_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_me': isMe,
      'sender_name': senderName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
