import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final unreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsProvider);
  return state.notifications.where((n) => n.readAt == null).length;
});

class NotificationsState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final String? error;

  NotificationsState({
    this.isLoading = false,
    this.notifications = const [],
    this.error,
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    String? error,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      error: error ?? this.error,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _repository;

  NotificationsNotifier(this._repository) : super(NotificationsState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getNotifications();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (notifications) => state = state.copyWith(isLoading: false, notifications: notifications),
    );
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    
    state = state.copyWith(notifications: updatedList);

    final result = await _repository.markAsRead(id);
    result.fold(
      (failure) => loadNotifications(), // Revert on failure
      (_) => null,
    );
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    loadNotifications();
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repository);
});
