import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Contact
          _buildSectionCard(
            context,
            title: 'Nous contacter',
            children: [
              _buildContactTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'support@dr-pharma.com',
                onTap: () => _launchUrl('mailto:support@dr-pharma.com'),
              ),
              const Divider(height: 1),
              _buildContactTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Téléphone',
                subtitle: '+225 07 00 00 00 00',
                onTap: () => _launchUrl('tel:+22507000000000'),
              ),
              const Divider(height: 1),
              _buildContactTile(
                context,
                icon: Icons.chat_outlined,
                title: 'WhatsApp',
                subtitle: 'Chat en direct',
                onTap: () => _launchUrl('https://wa.me/22507000000000'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // FAQ Section
          _buildSectionCard(
            context,
            title: 'Questions fréquentes',
            children: [
              _buildFaqItem(
                context,
                question: 'Comment ajouter un produit à mon inventaire ?',
                answer: 'Allez dans l\'onglet "Stock", appuyez sur le bouton "+", puis scannez le code-barres ou entrez les informations manuellement.',
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: 'Comment traiter une commande ?',
                answer: 'Dans l\'onglet "Commandes", appuyez sur une commande en attente, puis utilisez les boutons "Confirmer" ou "Préparer" selon l\'état de la commande.',
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: 'Comment modifier les informations de ma pharmacie ?',
                answer: 'Allez dans "Profil" > "Ma Pharmacie" > appuyez sur l\'icône de modification pour éditer les informations.',
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: 'Comment activer le mode garde ?',
                answer: 'Dans "Profil" > "Mode Garde", vous pouvez activer/désactiver le mode garde et définir vos horaires de garde.',
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: 'Comment voir mes statistiques de vente ?',
                answer: 'Accédez à "Rapports & Analytics" depuis le menu profil pour voir vos statistiques détaillées.',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Ressources
          _buildSectionCard(
            context,
            title: 'Ressources',
            children: [
              _buildResourceTile(
                context,
                icon: Icons.play_circle_outline,
                title: 'Tutoriels vidéo',
                onTap: () => _launchUrl('https://dr-pharma.com/tutoriels'),
              ),
              const Divider(height: 1),
              _buildResourceTile(
                context,
                icon: Icons.menu_book_outlined,
                title: 'Guide d\'utilisation',
                onTap: () => _launchUrl('https://dr-pharma.com/guide'),
              ),
              const Divider(height: 1),
              _buildResourceTile(
                context,
                icon: Icons.update_outlined,
                title: 'Notes de mise à jour',
                onTap: () => _showChangelogDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Report Bug
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bug_report_outlined, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signaler un problème',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Aidez-nous à améliorer l\'application',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => _showReportBugDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      children: [
        Text(
          answer,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showChangelogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notes de mise à jour'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVersionItem('1.0.0', 'Janvier 2026', [
                'Version initiale',
                'Gestion des commandes',
                'Inventaire et scanner',
                'Notifications push',
                'Mode garde',
                'Rapports et analytics',
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(String version, String date, List<String> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Version $version',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              date,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...changes.map((c) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(c, style: const TextStyle(fontSize: 14))),
            ],
          ),
        )),
      ],
    );
  }

  void _showReportBugDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Décrivez le problème rencontré :'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Description du problème...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Merci pour votre signalement !')),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
