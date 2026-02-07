class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Laravel stores custom data in 'data' column
    final dataContent = json['data'] as Map<String, dynamic>? ?? {};
    
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: dataContent['title'] ?? 'Notification',
      body: dataContent['body'] ?? '',
      data: dataContent,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isRead => readAt != null;
}
