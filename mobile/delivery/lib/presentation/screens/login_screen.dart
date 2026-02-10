import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/biometric_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  
  // Erreurs par champ
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    final canCheck = await biometricService.canCheckBiometrics();
    final isEnabled = ref.read(biometricSettingsProvider);
    
    if (mounted) {
      setState(() {
        _biometricAvailable = canCheck;
        _biometricEnabled = isEnabled;
      });
      
      // Si biométrie activée, proposer automatiquement
      if (canCheck && isEnabled) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _loginWithBiometric();
        });
      }
    }
  }

  Future<void> _loginWithBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    
    try {
      setState(() => _isLoading = true);
      
      final authenticated = await biometricService.authenticate(
        reason: 'Authentifiez-vous pour accéder à l\'application',
      );
      
      if (authenticated) {
        // Récupérer les credentials stockés et se connecter
        final authRepository = ref.read(authRepositoryProvider);
        final hasStoredCredentials = await authRepository.hasStoredCredentials();
        
        if (hasStoredCredentials) {
          await authRepository.loginWithStoredCredentials();
          
          // Initialize notifications after successful login
          await ref.read(notificationServiceProvider).initNotifications();
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Veuillez d\'abord vous connecter avec vos identifiants'),
                backgroundColor: Colors.orange.shade700,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur biométrique: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    // Prevent double-tap / multiple submissions
    if (_isLoading) return;
    
    // Réinitialiser les erreurs
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(_emailController.text.trim(), _passwordController.text);

      // Initialize notifications after successful login
      await ref.read(notificationServiceProvider).initNotifications();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Extraire le message d'erreur proprement
        String errorMessage = e.toString()
            .replaceAll('Exception:', '')
            .replaceAll('Exception', '')
            .trim();
        
        // Parser les erreurs et les associer aux champs appropriés
        final errorLower = errorMessage.toLowerCase();
        
        if (errorLower.contains('email') || errorLower.contains('identifiant') || 
            errorLower.contains('utilisateur') || errorLower.contains('user') ||
            errorLower.contains('phone') || errorLower.contains('téléphone')) {
          setState(() => _emailError = errorMessage);
        } else if (errorLower.contains('mot de passe') || errorLower.contains('password') ||
                   errorLower.contains('credentials') || errorLower.contains('identifiants')) {
          // Pour les erreurs d'identifiants, afficher sous les deux champs
          setState(() {
            _emailError = 'Identifiants incorrects';
            _passwordError = 'Vérifiez votre mot de passe';
          });
        } else if (errorMessage.contains('DioException') || errorMessage.contains('SocketException')) {
          setState(() => _generalError = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
        } else {
          // Erreur générale sous le formulaire
          setState(() => _generalError = errorMessage);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Branding colors
    const primaryColor = Color(0xFF1E88E5); // Blue 600
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Curve
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DR-PHARMA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ESPACE LIVREUR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Login Form Section
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Erreur générale (connexion serveur, etc.)
                          if (_generalError != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _generalError!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Identifier Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(fontSize: 16),
                            onChanged: (_) {
                              if (_emailError != null) setState(() => _emailError = null);
                            },
                            decoration: InputDecoration(
                              labelText: 'Email ou Téléphone',
                              hintText: 'ex: +225 0102030405',
                              prefixIcon: Icon(Icons.person_outline, color: _emailError != null ? Colors.red : primaryColor),
                              filled: true,
                              fillColor: _emailError != null ? Colors.red.shade50 : Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              errorText: _emailError,
                              errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _emailError != null ? Colors.red.shade300 : Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _emailError != null ? Colors.red : primaryColor, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.red.shade300),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre identifiant';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 16),
                            onChanged: (_) {
                              if (_passwordError != null) setState(() => _passwordError = null);
                            },
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: Icon(Icons.lock_outline, color: _passwordError != null ? Colors.red : primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: _passwordError != null ? Colors.red.shade50 : Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              errorText: _passwordError,
                              errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _passwordError != null ? Colors.red.shade300 : Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _passwordError != null ? Colors.red : primaryColor, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.red.shade300),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // Action Button
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'SE CONNECTER',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                          
                          // Bouton biométrique
                          if (_biometricAvailable && _biometricEnabled && !_isLoading)
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'ou',
                                        style: TextStyle(color: Colors.grey.shade500),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 52,
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _loginWithBiometric,
                                    icon: const Icon(Icons.fingerprint, size: 24),
                                    label: const Text(
                                      'Connexion biométrique',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                           const SizedBox(height: 24),
                           
                           // Lien vers l'inscription
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Text(
                                 'Pas encore de compte ? ',
                                 style: TextStyle(color: Colors.grey.shade600),
                               ),
                               TextButton(
                                 onPressed: () {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                   );
                                 },
                                 style: TextButton.styleFrom(
                                   padding: EdgeInsets.zero,
                                   minimumSize: Size.zero,
                                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                 ),
                                 child: Text(
                                   'Devenir livreur',
                                   style: TextStyle(
                                     color: Colors.blue.shade700, 
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Footer Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
