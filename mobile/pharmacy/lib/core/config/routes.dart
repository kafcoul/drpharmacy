import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/security_settings_page.dart';
import '../../features/profile/presentation/pages/appearance_settings_page.dart';
import '../../features/profile/presentation/pages/notification_settings_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/profile/presentation/pages/legal_page.dart';
import '../../features/reports/presentation/pages/reports_dashboard_page.dart';
import '../../features/inventory/presentation/pages/enhanced_scanner_page.dart';
import '../../features/orders/presentation/pages/order_details_wrapper_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/state/auth_state.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/onboarding_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isSplash = state.uri.path == '/';
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';
      final isRecoveringPassword = state.uri.path == '/forgot-password';

      final isOnboarding = state.uri.path == '/onboarding';
      
      // ✅ FIX: Ne pas rediriger si l'utilisateur est en cours d'inscription ou connexion
      // et qu'il y a une erreur ou un chargement - cela permet de rester sur la page
      // pour afficher l'erreur sans perdre les données saisies
      final isAuthInProgress = authState.status == AuthStatus.loading || 
                               authState.status == AuthStatus.error ||
                               authState.status == AuthStatus.registered;

      // Allow splash to run its course
      if (isSplash) return null;
      
      // Allow onboarding to run its course
      if (isOnboarding) return null;

      // ✅ FIX: Si on est sur une page d'auth (login, register, forgot-password) 
      // et qu'une action est en cours (loading, error, registered), ne pas rediriger
      if ((isLoggingIn || isRegistering || isRecoveringPassword) && isAuthInProgress) {
        return null;
      }

      if (!isLoggedIn &&
          !isLoggingIn &&
          !isRegistering &&
          !isRecoveringPassword) {
        return '/login';
      }

      if (isLoggedIn &&
          (isLoggingIn || isRegistering || isRecoveringPassword)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsPage(),
      ),
      GoRoute(
        path: '/appearance-settings',
        builder: (context, state) => const AppearanceSettingsPage(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const LegalPage(type: 'terms'),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const LegalPage(type: 'privacy'),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsDashboardPage(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const EnhancedScannerPage(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailsWrapperPage(orderId: orderId);
        },
      ),
    ],
  );
});

