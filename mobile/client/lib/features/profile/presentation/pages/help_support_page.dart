import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQItem(
            'Comment suivre ma commande ?',
            'Allez dans l\'onglet "Commandes" en bas de l\'écran pour voir toutes vos commandes en cours et leur statut.',
          ),
          _buildFAQItem(
            'Comment payer ?',
            'Nous acceptons les paiements par Mobile Money (Orange, MTN, Moov) et les paiements à la livraison.',
          ),
          _buildFAQItem(
            'Comment annuler une commande ?',
            'Vous pouvez annuler une commande tant qu\'elle n\'a pas été confirmée par la pharmacie. Allez dans les détails de la commande pour voir l\'option.',
          ),
          _buildFAQItem(
            'J\'ai un problème avec ma livraison',
            'Si le coursier a du retard ou un problème, vous pouvez le contacter directement depuis la page de suivi de commande.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Contactez-nous',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primary),
            title: const Text('Email'),
            subtitle: const Text('support@drpharma.com'),
            onTap: () {
              // TODO: Implement email launch
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.primary),
            title: const Text('Téléphone'),
            subtitle: const Text('+225 07 00 00 00 00'),
            onTap: () {
              // TODO: Implement phone launch
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
