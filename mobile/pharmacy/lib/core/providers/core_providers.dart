import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/notification_service.dart';
import '../services/cache_service.dart';
import '../services/security_service.dart';
import '../services/offline_storage_service.dart';

// Re-export session manager pour accès facile
export '../services/session_manager.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ==================== CACHE SERVICE ====================
final cacheServiceProvider = Provider<CacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacheService(prefs);
});

// ==================== SECURITY SERVICE ====================
final securityServiceProvider = Provider<SecurityService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SecurityService(prefs);
});

// ==================== OFFLINE STORAGE SERVICE ====================
final offlineStorageProvider = Provider<OfflineStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OfflineStorageService(prefs);
});

// ==================== CONNECTIVITY STATE ====================
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier(ref.watch(networkInfoProvider));
});

class ConnectivityState {
  final bool isConnected;
  final bool hasPendingSync;
  final int pendingActionsCount;

  ConnectivityState({
    required this.isConnected,
    this.hasPendingSync = false,
    this.pendingActionsCount = 0,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? hasPendingSync,
    int? pendingActionsCount,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
      pendingActionsCount: pendingActionsCount ?? this.pendingActionsCount,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final NetworkInfo _networkInfo;

  ConnectivityNotifier(this._networkInfo) 
      : super(ConnectivityState(isConnected: true)) {
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _networkInfo.isConnected;
    state = state.copyWith(isConnected: isConnected);
  }

  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  void setPendingSync(bool hasPending, int count) {
    state = state.copyWith(
      hasPendingSync: hasPending,
      pendingActionsCount: count,
    );
  }
}
