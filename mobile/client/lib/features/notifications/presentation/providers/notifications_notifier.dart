import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/app_logger.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import 'notifications_state.dart';

/// Notifier pour la gestion des notifications (Clean Architecture)
/// Utilise les UseCases pour les opérations principales
/// Note: FCM token update reste direct car pas de logique métier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final NotificationsRemoteDataSource remoteDataSource; // Pour FCM token uniquement

  NotificationsNotifier({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsReadUseCase,
    required this.remoteDataSource,
  }) : super(const NotificationsState.initial());

  /// Convertit les erreurs techniques en messages lisibles
  String _getReadableErrorMessage(String error) {
    final errorStr = error.toLowerCase();
    
    if (errorStr.contains('network') || 
        errorStr.contains('connexion') ||
        errorStr.contains('socket') ||
        errorStr.contains('timeout')) {
      return 'Problème de connexion. Vérifiez votre internet.';
    }
    
    if (errorStr.contains('unauthorized') || errorStr.contains('401')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }
    
    if (errorStr.contains('server') || errorStr.contains('500')) {
      return 'Le service est temporairement indisponible.';
    }
    
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Charge toutes les notifications
  Future<void> loadNotifications() async {
    state = state.copyWith(status: NotificationsStatus.loading);

    final result = await getNotificationsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: _getReadableErrorMessage(failure.message),
        );
      },
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
          errorMessage: null,
        );
      },
    );
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    final result = await markNotificationAsReadUseCase(notificationId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: _getReadableErrorMessage(failure.message),
        );
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return NotificationEntity(
              id: notification.id,
              type: notification.type,
              title: notification.title,
              body: notification.body,
              data: notification.data,
              isRead: true,
              createdAt: notification.createdAt,
            );
          }
          return notification;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
      },
    );
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final result = await markAllNotificationsReadUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: _getReadableErrorMessage(failure.message),
        );
      },
      (_) {
        // Update all notifications to read
        final updatedNotifications = state.notifications.map((notification) {
          return NotificationEntity(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      },
    );
  }

  /// Supprime une notification (accès direct DataSource car pas de UseCase créé)
  Future<void> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);

      // Remove from local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: _getReadableErrorMessage(e.toString()),
      );
    }
  }

  /// Update FCM token (pas de logique métier, accès direct)
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await remoteDataSource.updateFcmToken(fcmToken);
    } catch (e) {
      // Silent fail for FCM token update
      AppLogger.warning('FCM token update failed: $e');
    }
  }

  /// Remove FCM token
  Future<void> removeFcmToken() async {
    try {
      await remoteDataSource.removeFcmToken();
    } catch (e) {
      // Silent fail for FCM token removal
    }
  }

  /// Clear error
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
