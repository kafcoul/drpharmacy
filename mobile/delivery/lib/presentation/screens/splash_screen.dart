import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'pending_approval_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       duration: const Duration(seconds: 2),
       vsync: this,
    )..forward();
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _checkSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    // Check if onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    final onboardingCompleted = prefs.getBool('courier_onboarding_completed') ?? false;
    
    if (!onboardingCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }
    
    // Check if token exists
    final token = prefs.getString('auth_token');
    
    if (token != null && token.isNotEmpty) {
      // Token exists, try to validate by getting profile
      try {
        await ref.read(authRepositoryProvider).getProfile();
        if (!mounted) return;
        // Profile loaded successfully, go to Dashboard
        _navigateTo(const DashboardScreen());
        return;
      } catch (e) {
        if (!mounted) return;
        // Vérifier si c'est une erreur de statut (pending, suspended, rejected)
        final errorMessage = e.toString();
        
        if (errorMessage.contains('PENDING_APPROVAL:')) {
          final message = errorMessage.split('PENDING_APPROVAL:').last.replaceAll('Exception:', '').trim();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PendingApprovalScreen(
                status: 'pending_approval',
                message: message.isNotEmpty ? message : 'Votre compte est en attente d\'approbation.',
              ),
            ),
          );
          return;
        }
        
        if (errorMessage.contains('SUSPENDED:')) {
          final message = errorMessage.split('SUSPENDED:').last.replaceAll('Exception:', '').trim();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PendingApprovalScreen(
                status: 'suspended',
                message: message.isNotEmpty ? message : 'Votre compte a été suspendu.',
              ),
            ),
          );
          return;
        }
        
        if (errorMessage.contains('REJECTED:')) {
          final message = errorMessage.split('REJECTED:').last.replaceAll('Exception:', '').trim();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PendingApprovalScreen(
                status: 'rejected',
                message: message.isNotEmpty ? message : 'Votre demande a été refusée.',
              ),
            ),
          );
          return;
        }
        
        // Token invalid or expired, clear it
        await prefs.remove('auth_token');
        if (!mounted) return;
      }
    }
    
    // No valid token, go to Login
    _navigateTo(const LoginScreen());
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_shipping_rounded, size: 80, color: Colors.blue.shade700),
               ),
               const SizedBox(height: 24),
               Text(
                 'DR-PHARMA',
                 style: TextStyle(
                   fontSize: 32,
                   fontWeight: FontWeight.bold,
                   color: Colors.blue.shade900,
                   letterSpacing: 2.0,
                 ),
               ),
               const SizedBox(height: 8),
               Text(
                 'LIVREUR',
                 style: TextStyle(
                   fontSize: 16,
                   letterSpacing: 5.0,
                   color: Colors.blue.shade400,
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
