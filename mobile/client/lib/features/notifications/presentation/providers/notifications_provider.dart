import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import 'notifications_notifier.dart';
import 'notifications_state.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// DataSource provider (uses ApiClient with auth token)
final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return NotificationsRemoteDataSourceImpl(apiClient);
    });

/// Repository provider
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final remoteDataSource = ref.watch(notificationsRemoteDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return GetNotificationsUseCase(repository);
});

final markNotificationAsReadUseCaseProvider = Provider<MarkNotificationAsReadUseCase>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return MarkNotificationAsReadUseCase(repository);
});

final markAllNotificationsReadUseCaseProvider = Provider<MarkAllNotificationsReadUseCase>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return MarkAllNotificationsReadUseCase(repository);
});

// ============================================================================
// PRESENTATION LAYER PROVIDER
// ============================================================================

/// Provider principal pour les notifications
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      return NotificationsNotifier(
        getNotificationsUseCase: ref.watch(getNotificationsUseCaseProvider),
        markNotificationAsReadUseCase: ref.watch(markNotificationAsReadUseCaseProvider),
        markAllNotificationsReadUseCase: ref.watch(markAllNotificationsReadUseCaseProvider),
        remoteDataSource: ref.watch(notificationsRemoteDataSourceProvider),
      );
    });

// Unread count provider (for badge)
// Returns 0 if no notifications loaded yet (prevents API call before login)
final unreadCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  // Only return count if notifications were actually loaded
  if (notificationsState.status == NotificationsStatus.loaded) {
    return notificationsState.unreadCount;
  }
  return 0;
});
