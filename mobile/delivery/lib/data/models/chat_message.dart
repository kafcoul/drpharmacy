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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? json['message']?.toString() ?? '',
      isMe: json['is_me'] == true || json['is_mine'] == true,
      senderName: json['sender_name']?.toString() ?? 'Inconnu',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
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
