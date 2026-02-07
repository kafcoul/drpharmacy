import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  @JsonKey(name: 'read_at')
  final String? readAt;
  @JsonKey(name: 'created_at')
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: data['title'] ?? 'Notification',
      body: data['message'] ?? '',
      data: data,
      isRead: readAt != null,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
