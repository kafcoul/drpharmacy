import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';
import 'data/services/jeko_payment_service.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/background_location_service.dart';

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
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DR-PHARMA Courier',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
