import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/ui_state_providers.dart';

/// Exemple de widget de formulaire utilisant les providers UI au lieu de setState
/// Ce pattern est recommandé pour les nouveaux développements
///
/// Avantages:
/// - État testable indépendamment du widget
/// - Pas besoin de StatefulWidget pour les états simples
/// - Réutilisabilité des états entre widgets

/// Providers spécifiques à ce formulaire
/// Utilise des IDs uniques pour éviter les conflits
const _passwordVisibilityId = 'example_form_password';
const _confirmPasswordVisibilityId = 'example_form_confirm_password';
const _formLoadingId = 'example_form_submit';

class ExampleRiverpodFormWidget extends ConsumerWidget {
  const ExampleRiverpodFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observers - déclenche rebuild quand l'état change
    final obscurePassword = ref.watch(toggleProvider(_passwordVisibilityId));
    final obscureConfirm = ref.watch(toggleProvider(_confirmPasswordVisibilityId));
    final loadingState = ref.watch(loadingProvider(_formLoadingId));

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Champ mot de passe avec toggle visibility
          TextFormField(
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                // Action - utilise .notifier pour modifier l'état
                onPressed: () => ref
                    .read(toggleProvider(_passwordVisibilityId).notifier)
                    .toggle(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirmation mot de passe
          TextFormField(
            obscureText: obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => ref
                    .read(toggleProvider(_confirmPasswordVisibilityId).notifier)
                    .toggle(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Afficher l'erreur si présente
          if (loadingState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                loadingState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Bouton submit avec état de chargement
          ElevatedButton(
            onPressed: loadingState.isLoading
                ? null
                : () => _handleSubmit(ref),
            child: loadingState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(WidgetRef ref) async {
    // Démarrer le chargement
    ref.read(loadingProvider(_formLoadingId).notifier).startLoading();

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 2));

      // Succès - arrêter le chargement
      ref.read(loadingProvider(_formLoadingId).notifier).stopLoading();
    } catch (e) {
      // Erreur - afficher le message
      ref.read(loadingProvider(_formLoadingId).notifier).setError(
        'Une erreur est survenue: $e',
      );
    }
  }
}

/// Version avec StatefulWidget pour les cas nécessitant des controllers
/// Combine setState minimal avec providers pour les états partagés
class ExampleHybridFormWidget extends ConsumerStatefulWidget {
  const ExampleHybridFormWidget({super.key});

  @override
  ConsumerState<ExampleHybridFormWidget> createState() =>
      _ExampleHybridFormWidgetState();
}

class _ExampleHybridFormWidgetState
    extends ConsumerState<ExampleHybridFormWidget> {
  // Controllers nécessitent StatefulWidget pour le dispose
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // États via providers (pas de setState pour ceux-ci)
    final obscurePassword = ref.watch(toggleProvider('hybrid_form_password'));
    final loadingState = ref.watch(loadingProvider('hybrid_form'));

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => ref
                    .read(toggleProvider('hybrid_form_password').notifier)
                    .toggle(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (loadingState.error != null)
            Text(
              loadingState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ElevatedButton(
            onPressed: loadingState.isLoading ? null : _submit,
            child: loadingState.isLoading
                ? const CircularProgressIndicator()
                : const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(loadingProvider('hybrid_form').notifier).startLoading();

    try {
      // Utiliser les valeurs des controllers pour l'appel API
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Appel API avec les credentials
      debugPrint('Submitting form with email: $email, password length: ${password.length}');
      await Future.delayed(const Duration(seconds: 1));

      ref.read(loadingProvider('hybrid_form').notifier).stopLoading();
    } catch (e) {
      ref.read(loadingProvider('hybrid_form').notifier).setError(e.toString());
    }
  }
}
