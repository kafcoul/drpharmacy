import '../../../../core/network/api_client.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getMessages(int deliveryId, String participantType, int participantId);
  Future<ChatMessageModel> sendMessage(int deliveryId, String receiverType, int receiverId, String message);
  Future<int> getUnreadCount(int deliveryId);
  Future<void> markAsRead(int deliveryId, String senderType, int senderId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ChatMessageModel>> getMessages(int deliveryId, String participantType, int participantId) async {
    final response = await apiClient.get(
      '/pharmacy/deliveries/$deliveryId/chat',
      queryParameters: {
        'participant_type': participantType,
        'participant_id': participantId.toString(),
      },
    );

    final messages = response.data['messages'] as List? ?? [];
    return messages.map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(int deliveryId, String receiverType, int receiverId, String message) async {
    final response = await apiClient.post(
      '/pharmacy/deliveries/$deliveryId/chat',
      data: {
        'receiver_type': receiverType,
        'receiver_id': receiverId,
        'message': message,
      },
    );

    return ChatMessageModel.fromJson(response.data['message']);
  }

  @override
  Future<int> getUnreadCount(int deliveryId) async {
    final response = await apiClient.get('/pharmacy/deliveries/$deliveryId/chat/unread');
    return response.data['unread_count'] as int? ?? 0;
  }

  @override
  Future<void> markAsRead(int deliveryId, String senderType, int senderId) async {
    await apiClient.post(
      '/pharmacy/deliveries/$deliveryId/chat/read',
      data: {
        'sender_type': senderType,
        'sender_id': senderId,
      },
    );
  }
}
