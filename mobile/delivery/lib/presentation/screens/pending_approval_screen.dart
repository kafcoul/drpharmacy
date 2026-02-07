import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class PendingApprovalScreen extends ConsumerWidget {
  final String status; // 'pending_approval', 'suspended', 'rejected'
  final String message;

  const PendingApprovalScreen({
    super.key,
    required this.status,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IconData icon;
    Color iconColor;
    String title;

    switch (status) {
      case 'suspended':
        icon = Icons.block;
        iconColor = Colors.orange;
        title = 'Compte Suspendu';
        break;
      case 'rejected':
        icon = Icons.cancel;
        iconColor = Colors.red;
        title = 'Inscription Refusée';
        break;
      default: // pending_approval
        icon = Icons.hourglass_empty;
        iconColor = Colors.blue;
        title = 'En Attente d\'Approbation';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: iconColor),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (status == 'pending_approval') ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vous recevrez une notification dès que votre compte sera validé.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Effacer le token et retourner au login
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('auth_token');
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Retour à la connexion'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (status != 'pending_approval') ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Ouvrir le support
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contactez-nous à support@drpharma.ci')),
                    );
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contacter le support'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
