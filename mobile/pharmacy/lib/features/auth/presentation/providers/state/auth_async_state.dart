import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user_entity.dart';

/// # Pattern AsyncValue pour Auth
/// 
/// Cette implémentation utilise `AsyncValue<UserEntity?>` au lieu d'un enum status.
/// 
/// ## Avantages:
/// - Pattern natif Riverpod - plus idiomatique
/// - Gestion automatique des états loading/error/data
/// - Méthodes `.when()`, `.maybeWhen()`, `.whenData()` incluses
/// - Meilleure inférence de type
/// 
/// ## Comparaison:
/// 
/// ### Ancien pattern (enum status):
/// ```dart
/// if (state.status == AuthStatus.loading) { ... }
/// if (state.status == AuthStatus.error) { ... }
/// if (state.status == AuthStatus.authenticated) { ... }
/// ```
/// 
/// ### Nouveau pattern (AsyncValue):
/// ```dart
/// state.when(
///   data: (user) => user != null ? AuthenticatedWidget() : LoginWidget(),
///   loading: () => LoadingWidget(),
///   error: (e, _) => ErrorWidget(e.toString()),
/// );
/// ```

/// État d'authentification utilisant AsyncValue
/// 
/// - `AsyncValue.loading()` → Chargement en cours
/// - `AsyncValue.data(user)` → Authentifié (user != null) ou non (user == null)
/// - `AsyncValue.error(e, st)` → Erreur
typedef AuthAsyncState = AsyncValue<UserEntity?>;

/// Extension pour faciliter l'utilisation de AuthAsyncState
extension AuthAsyncStateX on AuthAsyncState {
  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => valueOrNull != null;
  
  /// Vérifie si l'utilisateur n'est pas authentifié
  bool get isUnauthenticated => !isLoading && !hasError && valueOrNull == null;
  
  /// Récupère l'utilisateur ou null
  UserEntity? get user => valueOrNull;
}

/// Notifier utilisant AsyncValue pattern
/// 
/// Usage:
/// ```dart
/// final authAsyncProvider = StateNotifierProvider<AuthAsyncNotifier, AuthAsyncState>((ref) {
///   return AuthAsyncNotifier(ref.read(authRepositoryProvider));
/// });
/// ```
class AuthAsyncNotifier extends StateNotifier<AuthAsyncState> {
  AuthAsyncNotifier() : super(const AsyncValue.data(null));

  /// Login avec gestion automatique des états
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    // Simule l'appel API - remplacer par le vrai repository
    state = await AsyncValue.guard(() async {
      // await _repository.login(email, password);
      // return user;
      throw UnimplementedError('Remplacer par le vrai repository');
    });
  }

  /// Logout
  void logout() {
    state = const AsyncValue.data(null);
  }

  /// Clear error (revient à unauthenticated)
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EXEMPLE D'UTILISATION DANS UN WIDGET
// ══════════════════════════════════════════════════════════════════════════════

/// Exemple d'utilisation dans un widget:
/// 
/// ```dart
/// class LoginPageWithAsyncValue extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authState = ref.watch(authAsyncProvider);
///     
///     // Écoute les erreurs pour afficher un dialog
///     ref.listen<AuthAsyncState>(authAsyncProvider, (previous, next) {
///       next.whenOrNull(
///         error: (error, _) {
///           ErrorHandler.showErrorDialog(context, error.toString());
///         },
///       );
///     });
///     
///     // Construction de l'UI
///     return authState.when(
///       data: (user) {
///         if (user != null) {
///           // Rediriger vers dashboard
///           WidgetsBinding.instance.addPostFrameCallback((_) {
///             context.go('/dashboard');
///           });
///           return const SizedBox.shrink();
///         }
///         return _buildLoginForm(ref);
///       },
///       loading: () => const Center(child: CircularProgressIndicator()),
///       error: (error, _) => _buildLoginForm(ref), // Affiche le form même en erreur
///     );
///   }
/// }
/// ```
