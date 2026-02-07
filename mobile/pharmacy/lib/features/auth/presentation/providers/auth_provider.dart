import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_di_providers.dart';
import 'state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  bool _isInitialized = false;

  AuthNotifier(this._repository) : super(const AuthState()) {
    // Ne pas appeler checkAuthStatus ici pour éviter le loading initial
    // L'initialisation sera faite manuellement quand nécessaire
  }

  /// Initialise le provider en vérifiant l'état d'authentification
  /// Doit être appelé une seule fois au démarrage de l'app
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    debugPrint('🔍 [AuthNotifier] checkAuthStatus() appelé');
    
    // Ne pas mettre en loading pour éviter l'effet de loader inattendu
    // state = state.copyWith(status: AuthStatus.loading);
    
    final result = await _repository.getCurrentUser();

    result.fold(
      (failure) {
        debugPrint('🔍 [AuthNotifier] checkAuthStatus - Pas d\'utilisateur connecté: ${failure.message}');
        state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
      },
      (user) {
        debugPrint('🔍 [AuthNotifier] checkAuthStatus - Utilisateur trouvé: ${user.email}');
        state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null);
      },
    );
  }

  Future<void> login(String email, String password) async {
    debugPrint('🔐 [AuthNotifier] login() appelé avec email: $email');
    debugPrint('🔐 [AuthNotifier] État actuel: ${state.status}');
    
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, originalError: null);
    debugPrint('🔐 [AuthNotifier] État mis à loading');

    try {
      debugPrint('🔐 [AuthNotifier] Appel de repository.login()...');
      final result = await _repository.login(email: email, password: password);
      debugPrint('🔐 [AuthNotifier] Résultat reçu du repository');

      result.fold(
        (failure) {
          debugPrint('❌ [AuthNotifier] Échec login: ${failure.message}');
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
            originalError: failure.originalError,
          );
        },
        (authResponse) {
          debugPrint('✅ [AuthNotifier] Login réussi pour: ${authResponse.user.email}');
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: authResponse.user,
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [AuthNotifier] Exception inattendue: $e');
      debugPrint('💥 [AuthNotifier] StackTrace: $stackTrace');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Erreur inattendue: $e',
        originalError: e,
      );
    }
  }

  Future<void> register({
    required String name,
    required String pName,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String city,
    required String address,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.register(
      name: name,
      pName: pName,
      email: email,
      phone: phone,
      password: password,
      licenseNumber: licenseNumber,
      city: city,
      address: address,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authResponse) => state = state.copyWith(
        status: AuthStatus.registered,
        user: authResponse.user,
      ),
    );
  }

  /// Réinitialise l'état pour revenir à l'écran de login sans loader
  /// Doit être appelé après une inscription réussie ou quand on navigue vers login
  void resetToUnauthenticated() {
    debugPrint('🔄 [AuthNotifier] resetToUnauthenticated() appelé');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Efface le message d'erreur et remet le status à unauthenticated
  /// ✅ IMPORTANT: Doit changer le status pour éviter les états incohérents
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    } else if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  Future<void> forgotPassword(String email) async {
    await _repository.forgotPassword(email: email);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
