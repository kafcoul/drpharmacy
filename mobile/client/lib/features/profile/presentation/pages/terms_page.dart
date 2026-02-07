import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Conditions Générales d\'Utilisation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. Introduction\n'
              'Bienvenue sur l\'application DR-PHARMA. En utilisant notre application, vous acceptez les présentes conditions d\'utilisation.\n\n'
              '2. Services\n'
              'DR-PHARMA met en relation des patients avec des pharmacies et des coursiers pour la livraison de produits pharmaceutiques.\n\n'
              '3. Inscription\n'
              'L\'inscription est gratuite. Vous devez fournir des informations exactes et à jour.\n\n'
              '4. Commandes\n'
              'Toute commande passée sur l\'application est ferme et définitive une fois confirmée par la pharmacie.\n\n'
              '5. Paiement\n'
              'Les paiements sont sécurisés. Vous pouvez payer par Mobile Money ou à la livraison.\n\n'
              '6. Livraison\n'
              'Les délais de livraison sont indicatifs. DR-PHARMA ne peut être tenu responsable des retards dus à des circonstances exceptionnelles.\n\n'
              '7. Responsabilité\n'
              'DR-PHARMA n\'est pas une pharmacie et ne vend pas de médicaments. Nous sommes une plateforme technique de mise en relation.\n\n'
              '8. Modification\n'
              'Nous nous réservons le droit de modifier ces conditions à tout moment.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
