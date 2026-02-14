import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// État de la session utilisateur
enum AuthSessionState {
  /// Session active et valide
  authenticated,
  /// Session expirée (401 reçu)
  expired,
  /// Déconnecté volontairement
  loggedOut,
}

/// Service centralisé pour gérer l'état de la session d'authentification.
/// 
/// Quand l'interceptor Dio reçoit un 401, il appelle [onSessionExpired]
/// qui nettoie le token et notifie l'UI via un StreamController.
class AuthSessionService {
  AuthSessionService._();
  static final AuthSessionService _instance = AuthSessionService._();
  static AuthSessionService get instance => _instance;

  final _controller = StreamController<AuthSessionState>.broadcast();

  /// Stream que l'UI écoute pour réagir aux changements de session
  Stream<AuthSessionState> get sessionStream => _controller.stream;

  /// Indique si une expiration est en cours de traitement (évite les doublons)
  bool _isHandlingExpiration = false;

  /// Appelé par l'interceptor quand un 401 est reçu
  /// Nettoie le token et notifie l'UI une seule fois
  Future<void> onSessionExpired() async {
    // Éviter les appels multiples simultanés (plusieurs requêtes 401 en parallèle)
    if (_isHandlingExpiration) return;
    _isHandlingExpiration = true;

    try {
      debugPrint('🔐 [SESSION] Token expiré — nettoyage en cours...');
      
      // Supprimer le token stocké
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      debugPrint('🔐 [SESSION] Token supprimé — notification de l\'UI');
      
      // Notifier l'UI
      _controller.add(AuthSessionState.expired);
    } catch (e) {
      debugPrint('❌ [SESSION] Erreur lors du nettoyage: $e');
    } finally {
      // Réinitialiser après un court délai pour permettre les futures détections
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingExpiration = false;
      });
    }
  }

  /// Appelé lors d'une déconnexion volontaire
  void onLoggedOut() {
    _controller.add(AuthSessionState.loggedOut);
    _isHandlingExpiration = false;
  }

  /// Appelé lors d'une connexion réussie
  void onAuthenticated() {
    _controller.add(AuthSessionState.authenticated);
    _isHandlingExpiration = false;
  }

  /// Libérer les ressources
  void dispose() {
    _controller.close();
  }
}

/// Provider Riverpod pour écouter l'état de session dans l'UI
final authSessionProvider = StreamProvider<AuthSessionState>((ref) {
  return AuthSessionService.instance.sessionStream;
});
