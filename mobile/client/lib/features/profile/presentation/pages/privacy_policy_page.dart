import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Politique de Confidentialité',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. Collecte des données\n'
              'Nous collectons les informations que vous nous fournissez lors de l\'inscription et de l\'utilisation de nos services (nom, téléphone, adresse, ordonnances).\n\n'
              '2. Utilisation des données\n'
              'Vos données sont utilisées pour traiter vos commandes, améliorer nos services et communiquer avec vous.\n\n'
              '3. Partage des données\n'
              'Nous partageons vos données (nom, adresse, téléphone) uniquement avec les pharmacies et les coursiers pour l\'exécution de vos commandes.\n\n'
              '4. Sécurité\n'
              'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles pour protéger vos données.\n\n'
              '5. Vos droits\n'
              'Vous avez le droit d\'accéder, de rectifier ou de supprimer vos données personnelles. Contactez le support pour exercer ces droits.\n\n'
              '6. Cookies et traceurs\n'
              'L\'application utilise des identifiants techniques pour son fonctionnement et des outils d\'analyse pour améliorer l\'expérience utilisateur.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
