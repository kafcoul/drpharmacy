import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart'; // Import pour notificationService
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/ui_state_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/validators/form_validators.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

// Provider IDs pour cette page
const _obscurePasswordId = 'login_obscure_password';
const _useEmailId = 'login_use_email';

/// Écran de connexion premium pour DR-PHARMA
/// Design moderne, minimaliste et professionnel
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // UI state:
  // - obscurePassword -> toggleProvider(_obscurePasswordId)
  // - useEmail -> toggleProvider(_useEmailId)
  // - isRedirecting -> local state (toggleProvider defaults to true, causing loader to show on init)

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Local state for redirecting - not using toggleProvider to avoid default true issue
  bool _isRedirecting = false;
  
  // Erreurs de champs (pour afficher les erreurs serveur sous les champs)
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Check authorization on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated && mounted) {
        final user = authState.user;
        if (user != null && !user.isPhoneVerified) {
          // Rediriger vers OTP si téléphone non vérifié
          context.goToOtpVerification(user.phone);
        } else {
          // Rediriger vers Home si téléphone vérifié
          context.goToHome();
        }
      }
      
      // Initialiser les toggles de mot de passe à true (obscurcir par défaut)
      ref.read(toggleProvider(_obscurePasswordId).notifier).set(true);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Prevent double-tap / multiple submissions
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.loading || _isRedirecting) {
      return;
    }
    
    // Réinitialiser les erreurs
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
    
    // Validation locale d'abord
    final useEmail = ref.read(toggleProvider(_useEmailId));
    final identifier = _phoneController.text.trim();
    final password = _passwordController.text;
    
    // Validation du champ email/téléphone
    if (identifier.isEmpty) {
      setState(() {
        _emailError = useEmail 
            ? 'Veuillez entrer votre adresse email'
            : 'Veuillez entrer votre numéro de téléphone';
      });
      _phoneFocusNode.requestFocus();
      return;
    }
    
    // Validation du format email/téléphone
    if (useEmail) {
      final emailError = FormValidators.validateEmail(identifier);
      if (emailError != null) {
        setState(() => _emailError = emailError);
        _phoneFocusNode.requestFocus();
        return;
      }
    } else {
      final phoneError = FormValidators.validatePhone(identifier);
      if (phoneError != null) {
        setState(() => _emailError = phoneError);
        _phoneFocusNode.requestFocus();
        return;
      }
    }
    
    // Validation du mot de passe
    if (password.isEmpty) {
      setState(() => _passwordError = 'Veuillez entrer votre mot de passe');
      _passwordFocusNode.requestFocus();
      return;
    }
    
    if (password.length < 6) {
      setState(() => _passwordError = 'Le mot de passe doit contenir au moins 6 caractères');
      _passwordFocusNode.requestFocus();
      return;
    }
    
    // Si validation locale OK, envoyer au serveur
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .login(
            email: identifier,
            password: password,
          );
    }
  }

  /// Analyse l'erreur serveur et détermine quel champ est concerné
  void _handleServerError(String? error) {
    debugPrint('🔐 [LoginPage] _handleServerError called with: $error');
    
    if (error == null || error.isEmpty) {
      setState(() => _generalError = 'Une erreur est survenue. Veuillez réessayer.');
      return;
    }
    
    final errorLower = error.toLowerCase();
    
    // Erreurs d'identifiants (email/téléphone incorrect)
    if (errorLower.contains('invalid') || 
        errorLower.contains('credentials') ||
        errorLower.contains('incorrect') ||
        errorLower.contains('identifiants') ||
        errorLower.contains('unauthorized') ||
        errorLower.contains('401')) {
      setState(() {
        _generalError = 'Email ou mot de passe incorrect';
      });
      return;
    }
    
    // Compte non trouvé
    if (errorLower.contains('not found') || 
        errorLower.contains('introuvable') ||
        errorLower.contains('n\'existe pas') ||
        errorLower.contains('no user')) {
      final useEmail = ref.read(toggleProvider(_useEmailId));
      setState(() {
        _emailError = useEmail 
            ? 'Aucun compte associé à cet email'
            : 'Aucun compte associé à ce numéro';
      });
      _phoneFocusNode.requestFocus();
      return;
    }
    
    // Erreur de mot de passe spécifique
    if (errorLower.contains('password') || 
        errorLower.contains('mot de passe')) {
      setState(() => _passwordError = 'Mot de passe incorrect');
      _passwordFocusNode.requestFocus();
      return;
    }
    
    // Compte désactivé/suspendu
    if (errorLower.contains('disabled') || 
        errorLower.contains('suspended') ||
        errorLower.contains('blocked') ||
        errorLower.contains('désactivé') ||
        errorLower.contains('suspendu') ||
        errorLower.contains('bloqué')) {
      setState(() => _generalError = 'Votre compte a été désactivé. Contactez le support.');
      return;
    }
    
    // Erreurs réseau
    if (errorLower.contains('network') || 
        errorLower.contains('connexion') ||
        errorLower.contains('internet') ||
        errorLower.contains('timeout') ||
        errorLower.contains('socket') ||
        errorLower.contains('connection')) {
      setState(() => _generalError = 'Problème de connexion internet. Vérifiez votre connexion.');
      return;
    }
    
    // Erreurs serveur
    if (errorLower.contains('server') || 
        errorLower.contains('500') ||
        errorLower.contains('503') ||
        errorLower.contains('serveur')) {
      setState(() => _generalError = 'Service temporairement indisponible. Réessayez plus tard.');
      return;
    }
    
    // Trop de tentatives
    if (errorLower.contains('too many') || 
        errorLower.contains('rate limit') ||
        errorLower.contains('throttle') ||
        errorLower.contains('tentatives')) {
      setState(() => _generalError = 'Trop de tentatives. Patientez quelques minutes.');
      return;
    }
    
    // Erreur par défaut
    setState(() => _generalError = 'Identifiants incorrects. Vérifiez votre email et mot de passe.');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Watch UI state providers
    final obscurePassword = ref.watch(toggleProvider(_obscurePasswordId));
    final useEmail = ref.watch(toggleProvider(_useEmailId));
    // Use local state for isRedirecting instead of provider (to avoid default true issue)

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) async {
      debugPrint('🔐 [LoginPage] Auth state changed: ${next.status}');
      debugPrint('🔐 [LoginPage] Error message: ${next.errorMessage}');
      
      if (next.status == AuthStatus.authenticated && !_isRedirecting) {
        // Prevent multiple redirections and keep loader visible
        if (mounted) {
          setState(() => _isRedirecting = true);
        }
        
        // Small delay to ensure UI shows loading state
        await Future.delayed(const Duration(milliseconds: 50));
        
        try {
          // Initialiser les notifications après authentification
          await ref.read(notificationServiceProvider).initNotifications();
        } catch (e) {
          // Continue even if notification init fails
          AppLogger.warning('Notification init error: $e');
        }

        if (mounted) {
          // Vérifier si le téléphone est vérifié
          final user = next.user;
          if (user != null && !user.isPhoneVerified) {
            // Rediriger vers OTP si téléphone non vérifié
            // ignore: use_build_context_synchronously
            context.goToOtpVerification(user.phone);
          } else {
            // Rediriger vers Home si téléphone vérifié
            // ignore: use_build_context_synchronously
            context.goToHome();
          }
        }
      } else if (next.status == AuthStatus.error) {
        // Reset redirecting state on error
        if (_isRedirecting && mounted) {
          setState(() => _isRedirecting = false);
        }
        if (mounted) {
          // Afficher l'erreur sous les champs au lieu d'un snackbar
          _handleServerError(next.errorMessage);
        }
      }
    });

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50],
        body: Stack(
          children: [
            // Background Design
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                _buildHeader(isDark),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Container(
                                      width: 50,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    'Bon retour !',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Connectez-vous pour continuer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 30),

                                  // Toggle Phone/Email
                                  _buildToggleMethod(isDark, useEmail),
                                  const SizedBox(height: 24),

                                  // Phone/Email Field
                                  _buildPhoneField(isDark, useEmail),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  _buildPasswordField(isDark, obscurePassword),
                                  
                                  // Erreur générale (identifiants incorrects)
                                  // Afficher l'erreur locale OU l'erreur du serveur
                                  Builder(
                                    builder: (context) {
                                      final errorToShow = _generalError ?? 
                                        (authState.status == AuthStatus.error 
                                          ? _parseErrorMessage(authState.errorMessage) 
                                          : null);
                                      if (errorToShow != null) {
                                        return Column(
                                          children: [
                                            const SizedBox(height: 16),
                                            _buildGeneralErrorBannerWithMessage(isDark, errorToShow),
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.goToForgotPassword(),
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  _buildLoginButton(authState, isDark, _isRedirecting),

                                  const SizedBox(height: 24),

                                  // Security Badge
                                  _buildSecurityBadge(isDark),

                                  const SizedBox(height: 24),

                                  // Register Link
                                  _buildRegisterLink(),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.local_pharmacy_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'DR-PHARMA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleMethod(bool isDark, bool useEmail) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Téléphone',
              isSelected: !useEmail,
              onTap: () => ref.read(toggleProvider(_useEmailId).notifier).set(false),
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Email',
              isSelected: useEmail,
              onTap: () => ref.read(toggleProvider(_useEmailId).notifier).set(true),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? Colors.white54 : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDark = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: hasError 
                  ? Colors.red.shade400
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            prefixIcon: Icon(
              icon,
              color: hasError 
                  ? Colors.red.shade400
                  : (isDark ? Colors.grey[400] : AppColors.primary),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: hasError
                ? Colors.red.shade50.withValues(alpha: isDark ? 0.1 : 1.0)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError 
                  ? BorderSide(color: Colors.red.shade400, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : AppColors.primary, 
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
          validator: validator,
        ),
        // Message d'erreur sous le champ
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark, bool useEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          label: useEmail ? 'Adresse email' : 'Numéro de téléphone',
          icon: useEmail ? Icons.email_outlined : Icons.phone_android_rounded,
          isDark: isDark,
          keyboardType: useEmail
              ? TextInputType.emailAddress
              : TextInputType.phone,
          inputFormatters: useEmail
              ? null
              : [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          onChanged: (_) {
            // Effacer l'erreur quand l'utilisateur tape
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
            if (_generalError != null) {
              setState(() => _generalError = null);
            }
          },
          errorText: _emailError,
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark, bool obscurePassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          label: 'Mot de passe',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          onChanged: (_) {
            // Effacer l'erreur quand l'utilisateur tape
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
            if (_generalError != null) {
              setState(() => _generalError = null);
            }
          },
          suffixIcon: IconButton(
            onPressed: () => ref.read(toggleProvider(_obscurePasswordId).notifier).toggle(),
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          errorText: _passwordError,
        ),
      ],
    );
  }
  
  /// Parse le message d'erreur serveur pour l'afficher de manière claire
  String _parseErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
    
    final errorLower = error.toLowerCase();
    
    // Erreurs d'identifiants
    if (errorLower.contains('invalid') || 
        errorLower.contains('credentials') ||
        errorLower.contains('incorrect') ||
        errorLower.contains('identifiants') ||
        errorLower.contains('unauthorized') ||
        errorLower.contains('401')) {
      return 'Email ou mot de passe incorrect';
    }
    
    // Compte non trouvé
    if (errorLower.contains('not found') || 
        errorLower.contains('introuvable') ||
        errorLower.contains('n\'existe pas') ||
        errorLower.contains('no user')) {
      return 'Aucun compte associé à ces identifiants';
    }
    
    // Compte désactivé
    if (errorLower.contains('disabled') || 
        errorLower.contains('suspended') ||
        errorLower.contains('blocked') ||
        errorLower.contains('désactivé')) {
      return 'Votre compte a été désactivé. Contactez le support.';
    }
    
    // Erreurs réseau
    if (errorLower.contains('network') || 
        errorLower.contains('connexion') ||
        errorLower.contains('internet') ||
        errorLower.contains('timeout') ||
        errorLower.contains('connection')) {
      return 'Problème de connexion. Vérifiez votre internet.';
    }
    
    // Erreurs serveur
    if (errorLower.contains('server') || 
        errorLower.contains('500') ||
        errorLower.contains('503')) {
      return 'Service temporairement indisponible. Réessayez plus tard.';
    }
    
    // Retourner le message original s'il est déjà en français et lisible
    if (error.length < 100 && !error.contains('Exception')) {
      return error;
    }
    
    return 'Identifiants incorrects. Vérifiez votre email et mot de passe.';
  }
  
  /// Widget pour afficher une erreur générale avec un message personnalisé
  Widget _buildGeneralErrorBannerWithMessage(bool isDark, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 18,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _generalError = null);
              // Clear error state in auth notifier
              ref.read(authProvider.notifier).clearError();
            },
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthState authState, bool isDark, bool isRedirecting) {
    // Show loader during login AND during post-login operations (redirecting)
    final isLoading = authState.status == AuthStatus.loading || isRedirecting;
    final loadingText = isRedirecting ? 'Connexion...' : null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      if (loadingText != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          loadingText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : AppColors.primary).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            size: 18,
            color: isDark ? Colors.white70 : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Connexion sécurisée',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => context.goToRegister(),
          child: Text(
            'Créer un compte',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
