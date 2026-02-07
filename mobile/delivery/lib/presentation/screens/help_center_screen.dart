import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<_FAQItem> _faqItems = [
    _FAQItem(
      question: 'Comment accepter une livraison ?',
      answer: 'Quand une nouvelle livraison est disponible, vous recevez une notification. Allez dans l\'onglet "Livraisons" et appuyez sur "Accepter" pour prendre en charge la commande.',
      icon: Icons.delivery_dining,
    ),
    _FAQItem(
      question: 'Comment recharger mon portefeuille ?',
      answer: 'Allez dans votre profil > Portefeuille > Recharger. Vous pouvez payer par Mobile Money (Orange Money, MTN, Moov) ou par carte bancaire via JEKO.',
      icon: Icons.account_balance_wallet,
    ),
    _FAQItem(
      question: 'Pourquoi je ne peux plus livrer ?',
      answer: 'Si votre solde est insuffisant pour couvrir les commissions, vous ne pouvez plus accepter de livraisons. Rechargez votre portefeuille pour continuer.',
      icon: Icons.block,
    ),
    _FAQItem(
      question: 'Comment fonctionne la commission ?',
      answer: 'Une commission de 200 FCFA est prélevée sur chaque livraison terminée. Cette commission est déduite automatiquement de votre portefeuille.',
      icon: Icons.percent,
    ),
    _FAQItem(
      question: 'Comment confirmer une livraison ?',
      answer: 'À la livraison, demandez le code de confirmation au client. Entrez ce code à 4 chiffres dans l\'application pour valider la livraison et recevoir votre paiement.',
      icon: Icons.check_circle,
    ),
    _FAQItem(
      question: 'Comment mettre à jour ma position GPS ?',
      answer: 'Activez la localisation sur votre téléphone. L\'application met à jour votre position automatiquement toutes les 30 secondes quand vous êtes en ligne.',
      icon: Icons.location_on,
    ),
    _FAQItem(
      question: 'Comment voir l\'itinéraire vers le client ?',
      answer: 'Quand vous avez une livraison en cours, appuyez sur le bouton "Navigation" pour ouvrir Google Maps avec l\'itinéraire vers le client.',
      icon: Icons.map,
    ),
    _FAQItem(
      question: 'Comment changer mon mot de passe ?',
      answer: 'Allez dans Profil > Paramètres > Changer le mot de passe. Entrez votre mot de passe actuel puis le nouveau mot de passe deux fois.',
      icon: Icons.lock,
    ),
    _FAQItem(
      question: 'Que faire si le client est absent ?',
      answer: 'Essayez d\'appeler le client. Si après plusieurs tentatives il reste injoignable, contactez le support via les paramètres pour signaler le problème.',
      icon: Icons.person_off,
    ),
    _FAQItem(
      question: 'Comment contacter le support ?',
      answer: 'Allez dans Paramètres > Aide & Support > Contacter le support. Vous pouvez appeler directement ou envoyer un email.',
      icon: Icons.support_agent,
    ),
  ];

  String _searchQuery = '';

  List<_FAQItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems.where((item) =>
      item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.answer.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec gradient
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade800,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Centre d\'aide',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Questions fréquentes',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Barre de recherche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Rechercher une question...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Liste des FAQ
          _filteredItems.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun résultat trouvé',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _FAQTile(item: _filteredItems[index]),
                  childCount: _filteredItems.length,
                ),
              ),

          // Section contact en bas
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  Icon(Icons.headset_mic, size: 48, color: Colors.blue.shade600),
                  const SizedBox(height: 12),
                  const Text(
                    'Besoin d\'aide supplémentaire ?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notre équipe support est disponible 7j/7 de 8h à 22h',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Retour aux paramètres pour contacter
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Utilisez "Contacter le support" pour appeler'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Utilisez "Envoyer un email" pour écrire'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  final IconData icon;

  _FAQItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}

class _FAQTile extends StatefulWidget {
  final _FAQItem item;

  const _FAQTile({required this.item});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _isExpanded ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
        boxShadow: _isExpanded
          ? [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isExpanded 
                        ? Colors.blue.shade100 
                        : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.item.icon,
                      size: 20,
                      color: _isExpanded 
                        ? Colors.blue.shade700 
                        : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isExpanded 
                          ? Colors.blue.shade800 
                          : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _isExpanded 
                        ? Colors.blue.shade600 
                        : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 48),
                  child: Text(
                    widget.item.answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
                crossFadeState: _isExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
