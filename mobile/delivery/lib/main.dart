import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'data/services/jeko_payment_service.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/background_location_service.dart';
import 'core/services/auth_session_service.dart';
import 'core/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('fr_FR', null); // Add this line

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  // Initialiser les deep links pour les paiements JEKO
  try {
    await JekoPaymentService.initDeepLinks();
    debugPrint('✅ Deep links initialized');
  } catch (e) {
    debugPrint('❌ Deep links init error: $e');
  }
  
  // Initialiser le service de localisation en arrière-plan
  try {
    await BackgroundLocationService.initialize();
    debugPrint('✅ Background location service initialized');
  } catch (e) {
    debugPrint('❌ Background location init error: $e');
  }

  // Initialiser le cache local
  await CacheService.instance.init();
  debugPrint('✅ Cache service initialized');
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  /// Clé globale de navigation pour permettre la redirection depuis les services
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _listenSessionExpiration();
  }

  /// Écoute l'expiration de session pour rediriger vers le login automatiquement
  void _listenSessionExpiration() {
    AuthSessionService.instance.sessionStream.listen((state) {
      if (state == AuthSessionState.expired) {
        final navigator = MyApp.navigatorKey.currentState;
        if (navigator != null) {
          debugPrint('🔐 [SESSION] Redirection vers LoginScreen');
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
          // Afficher le message après que la navigation soit terminée
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = MyApp.navigatorKey.currentContext;
            if (ctx != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Session expirée. Veuillez vous reconnecter.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'DR-PHARMA Courier',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
