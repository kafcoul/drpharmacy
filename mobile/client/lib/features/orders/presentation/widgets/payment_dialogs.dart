import 'package:flutter/material.dart';

/// Dialogue de sélection du fournisseur de paiement
class PaymentProviderDialog extends StatelessWidget {
  const PaymentProviderDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentProviderDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choisir le moyen de paiement'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: [
        _buildProviderOption(
          context: context,
          provider: 'jeko',
          name: 'Jèko',
          description: 'Wave, Orange Money, MTN, Moov, Djamo',
          icon: Icons.account_balance_wallet,
          iconColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildProviderOption({
    required BuildContext context,
    required String provider,
    required String name,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, provider),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialogue de chargement pour le paiement
class PaymentLoadingDialog extends StatelessWidget {
  const PaymentLoadingDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentLoadingDialog(),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initialisation du paiement...'),
            ],
          ),
        ),
      ),
    );
  }
}
