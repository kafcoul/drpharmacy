import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Bouton de soumission pour la commande
class CheckoutSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final String totalFormatted;
  final VoidCallback? onPressed;

  const CheckoutSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.totalFormatted,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isSubmitting ? Colors.grey : AppColors.primary,
        ),
        child: isSubmitting ? _buildLoadingContent() : _buildNormalContent(),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
          'Traitement en cours...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNormalContent() {
    return Text(
      'Confirmer la commande - $totalFormatted',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
