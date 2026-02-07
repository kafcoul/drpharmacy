import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service global de gestion de session
/// 
/// Utilisé par l'AuthInterceptor pour notifier l'app
/// quand une session expire (401 sur route protégée)
/// 
/// Usage:
/// ```dart
/// // Dans main.dart ou app.dart
/// ref.listen(sessionExpiredProvider, (previous, next) {
///   if (next) {
///     context.go('/login');
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text('Session expirée, reconnectez-vous')),
///     );
///   }
/// });
/// ```
class SessionManager extends StateNotifier<bool> {
  SessionManager() : super(false);
  
  /// Déclenché quand la session expire (401 global)
  void onSessionExpired() {
    state = true;
    // Reset après un délai pour permettre de re-déclencher
    Future.delayed(const Duration(seconds: 3), () {
      state = false;
    });
  }
  
  /// Reset manuel de l'état
  void reset() {
    state = false;
  }
}

/// Provider pour écouter les expirations de session
final sessionExpiredProvider = StateNotifierProvider<SessionManager, bool>((ref) {
  return SessionManager();
});

/// Provider qui expose le callback pour l'intercepteur
/// 
/// L'intercepteur peut appeler ce callback quand il reçoit un 401
final sessionExpiredCallbackProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(sessionExpiredProvider.notifier).onSessionExpired();
  };
});
