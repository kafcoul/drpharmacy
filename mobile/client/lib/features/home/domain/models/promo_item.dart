/// Modèle pour les éléments promotionnels du slider
/// NOTE: Domain layer - pas de dépendance Flutter
/// Les couleurs sont stockées comme int (valeur hexadécimale)
/// Conversion en Color dans la couche Presentation
class PromoItem {
  final String badge;
  final String title;
  final String subtitle;
  final List<int> gradientColorValues; // Hex color values (e.g., 0xFF00A86B)
  final String? actionType; // 'onDuty', 'prescription', etc.

  const PromoItem({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradientColorValues,
    this.actionType,
  });
}

/// Liste des promotions par défaut
class PromoData {
  static const List<PromoItem> defaultPromos = [
    PromoItem(
      badge: 'Nouveau',
      title: 'Livraison Gratuite',
      subtitle: 'Sur votre première commande',
      gradientColorValues: [0xFF00A86B, 0xFF008556],
    ),
    PromoItem(
      badge: '-20%',
      title: 'Vitamines & Compléments',
      subtitle: 'Profitez des promotions santé',
      gradientColorValues: [0xFF00BCD4, 0xFF0097A7],
    ),
    PromoItem(
      badge: 'Pharmacie de garde',
      title: 'Service 24h/24',
      subtitle: 'Trouvez une pharmacie ouverte près de vous',
      gradientColorValues: [0xFFFF5722, 0xFFE64A19],
      actionType: 'onDuty',
    ),
    PromoItem(
      badge: 'Ordonnance',
      title: 'Envoyez votre ordonnance',
      subtitle: 'Recevez vos médicaments à domicile',
      gradientColorValues: [0xFF9C27B0, 0xFF7B1FA2],
      actionType: 'prescription',
    ),
  ];
}
