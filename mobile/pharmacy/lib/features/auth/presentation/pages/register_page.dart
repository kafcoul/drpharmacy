import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/error_display.dart';
import '../../../../core/utils/error_messages.dart';
import '../providers/auth_provider.dart';
import '../providers/state/auth_state.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // Owner Name
  final _pharmacyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _licenseController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _pharmacyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _licenseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final authState = ref.read(authProvider);
    
    // Empêcher les soumissions multiples
    if (authState.status == AuthStatus.loading) {
      ErrorSnackBar.showWarning(
        context,
        'Inscription en cours, veuillez patienter...',
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register(
            name: _nameController.text.trim(),
            pName: _pharmacyNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            licenseNumber: _licenseController.text.trim(),
            city: _cityController.text.trim(),
            address: _addressController.text.trim(),
            password: _passwordController.text,
          );
    } else {
      // Afficher un message pour les erreurs de validation
      ErrorSnackBar.showWarning(
        context,
        'Veuillez corriger les erreurs du formulaire',
      );
    }
  }

  /// Convertit les messages d'erreur techniques en messages lisibles pour l'utilisateur
  String _getReadableErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    // Email déjà utilisé
    if (errorLower.contains('email') && (errorLower.contains('taken') || errorLower.contains('already') || errorLower.contains('existe'))) {
      return 'Cette adresse email est déjà utilisée.\n\nUtilisez une autre adresse ou connectez-vous avec votre compte existant.';
    }
    
    // Numéro de téléphone déjà utilisé
    if (errorLower.contains('phone') && (errorLower.contains('taken') || errorLower.contains('already') || errorLower.contains('existe'))) {
      return 'Ce numéro de téléphone est déjà associé à un compte.\n\nUtilisez un autre numéro ou contactez le support.';
    }
    
    // Numéro de licence déjà utilisé
    if (errorLower.contains('license') && (errorLower.contains('taken') || errorLower.contains('already') || errorLower.contains('existe'))) {
      return 'Ce numéro de licence est déjà enregistré.\n\nVérifiez le numéro ou contactez le support.';
    }
    
    // Mot de passe trop court
    if (errorLower.contains('password') && (errorLower.contains('short') || errorLower.contains('minimum') || errorLower.contains('caractères'))) {
      return 'Le mot de passe est trop court.\n\nIl doit contenir au moins 8 caractères.';
    }
    
    // Email invalide
    if (errorLower.contains('email') && errorLower.contains('invalid')) {
      return 'L\'adresse email n\'est pas valide.\n\nVérifiez le format de l\'email.';
    }
    
    // Erreur réseau
    if (errorLower.contains('network') || errorLower.contains('connexion') || errorLower.contains('internet')) {
      return 'Problème de connexion internet.\n\nVérifiez votre connexion et réessayez.';
    }
    
    // Erreur serveur
    if (errorLower.contains('server') || errorLower.contains('500')) {
      return 'Le serveur est temporairement indisponible.\n\nVeuillez réessayer dans quelques instants.';
    }
    
    return error;
  }

  void _showSuccessDialog(BuildContext context) {
    // S'assurer qu'aucun dialogue n'est ouvert
    if (Navigator.of(context).canPop()) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false, // Empêcher la fermeture avec le bouton retour
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    size: 60,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Inscription réussie !',
                  style: Theme.of(dialogContext).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre demande a été envoyée avec succès.\n\nL\'administrateur doit approuver votre compte avant que vous puissiez vous connecter. Vous serez notifié par email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Délai d\'approbation : 24-48h',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      // Réinitialiser l'état d'auth AVANT la navigation
                      ref.read(authProvider.notifier).resetToUnauthenticated();
                      Navigator.of(dialogContext).pop();
                      context.go('/login');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retour à la connexion',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      // Éviter les doublons - ne traiter que si l'état a changé
      if (previous?.status == next.status) return;
      
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        // Fermer tout dialogue existant d'abord
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst || route is! DialogRoute);
        
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 28),
                const SizedBox(width: 12),
                const Expanded(child: Text('Échec de l\'inscription')),
              ],
            ),
            content: Text(
              _getReadableErrorMessage(next.errorMessage!),
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Compris'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      } else if (next.status == AuthStatus.registered) {
        // Inscription réussie - afficher le dialogue de succès
        _showSuccessDialog(context);
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48), // Top spacing
              // Header
              Icon(
                Icons.local_pharmacy_rounded,
                size: 60,
                color: Colors.teal[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Création de compte',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.teal[900],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoignez le réseau DR-PHARMA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.teal[600],
                    ),
              ),
              const SizedBox(height: 32),

              // Form
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nom du propriétaire
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration(
                            'Nom du pharmacien titulaire',
                            Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom complet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Nom de la pharmacie
                        TextFormField(
                          controller: _pharmacyNameController,
                          decoration: _buildInputDecoration(
                            'Nom de la pharmacie',
                            Icons.store_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom de la pharmacie';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // License Number
                        TextFormField(
                          controller: _licenseController,
                          decoration: _buildInputDecoration(
                            'Numéro de licence',
                            Icons.badge_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le numéro de licence';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration(
                            'Adresse Email',
                            Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Téléphone
                        TextFormField(
                          controller: _phoneController,
                          decoration: _buildInputDecoration(
                            'Numéro de téléphone',
                            Icons.phone_outlined,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un numéro de téléphone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Ville
                        TextFormField(
                          controller: _cityController,
                          decoration: _buildInputDecoration(
                            'Ville',
                            Icons.location_city,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la ville';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Adresse
                        TextFormField(
                          controller: _addressController,
                          decoration: _buildInputDecoration(
                            'Adresse complète',
                            Icons.location_on_outlined,
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une adresse';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          decoration: _buildInputDecoration(
                            'Mot de passe',
                            Icons.lock_outline,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir un mot de passe';
                            }
                            if (value.length < 8) {
                              return 'Le mot de passe doit faire au moins 8 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirmation Mot de passe
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: _buildInputDecoration(
                            'Confirmer le mot de passe',
                            Icons.lock_outline,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Bouton Valider
                        SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Inscription en cours...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "S'inscrire",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Vous avez déjà un compte ?",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal[600]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }
}

