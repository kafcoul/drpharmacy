import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../../../core/providers/core_providers.dart';

// Provider pour le data source
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRemoteDataSourceImpl(apiClient: apiClient);
});

// Provider pour récupérer les messages
final chatMessagesProvider = FutureProvider.family<List<ChatMessageModel>, ChatMessagesParams>((ref, params) async {
  final dataSource = ref.watch(chatRemoteDataSourceProvider);
  return dataSource.getMessages(params.deliveryId, params.participantType, params.participantId);
});

// Paramètres pour le provider
class ChatMessagesParams {
  final int deliveryId;
  final String participantType;
  final int participantId;

  ChatMessagesParams({
    required this.deliveryId,
    required this.participantType,
    required this.participantId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessagesParams &&
          deliveryId == other.deliveryId &&
          participantType == other.participantType &&
          participantId == other.participantId;

  @override
  int get hashCode => Object.hash(deliveryId, participantType, participantId);
}

// Notifier pour envoyer des messages
class ChatNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> sendMessage({
    required int deliveryId,
    required String receiverType,
    required int receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);
      await dataSource.sendMessage(deliveryId, receiverType, receiverId, message);
      
      // Invalider le cache des messages pour rafraîchir
      ref.invalidate(chatMessagesProvider(ChatMessagesParams(
        deliveryId: deliveryId,
        participantType: receiverType,
        participantId: receiverId,
      )));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, AsyncValue<void>>(() {
  return ChatNotifier();
});
