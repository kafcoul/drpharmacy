import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/pricing_entity.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  error,
}

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> items;
  final String? errorMessage;
  final int? selectedPharmacyId;
  
  /// Frais de livraison calculés dynamiquement selon la distance
  /// null = pas encore calculé (utiliser le minimum par défaut)
  final double? calculatedDeliveryFee;
  
  /// Distance en km pour la livraison (pour affichage)
  final double? deliveryDistanceKm;
  
  /// Configuration de tarification (frais de service et paiement)
  final PricingConfigEntity? pricingConfig;
  
  /// Mode de paiement sélectionné (pour calcul des frais de paiement)
  final String paymentMode;

  const CartState({
    required this.status,
    required this.items,
    this.errorMessage,
    this.selectedPharmacyId,
    this.calculatedDeliveryFee,
    this.deliveryDistanceKm,
    this.pricingConfig,
    this.paymentMode = 'cash',
  });

  const CartState.initial()
      : status = CartStatus.initial,
        items = const [],
        errorMessage = null,
        selectedPharmacyId = null,
        calculatedDeliveryFee = null,
        deliveryDistanceKm = null,
        pricingConfig = null,
        paymentMode = 'cash';

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? errorMessage,
    int? selectedPharmacyId,
    bool clearPharmacyId = false,
    double? calculatedDeliveryFee,
    double? deliveryDistanceKm,
    bool clearDeliveryFee = false,
    PricingConfigEntity? pricingConfig,
    String? paymentMode,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      selectedPharmacyId: clearPharmacyId ? null : (selectedPharmacyId ?? this.selectedPharmacyId),
      calculatedDeliveryFee: clearDeliveryFee ? null : (calculatedDeliveryFee ?? this.calculatedDeliveryFee),
      deliveryDistanceKm: clearDeliveryFee ? null : (deliveryDistanceKm ?? this.deliveryDistanceKm),
      pricingConfig: pricingConfig ?? this.pricingConfig,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, selectedPharmacyId, calculatedDeliveryFee, deliveryDistanceKm, pricingConfig, paymentMode];

  // Helper getters
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  
  /// Nombre total d'articles (somme des quantités) - utilisé pour le badge
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  /// Nombre de produits différents dans le panier
  int get uniqueProductCount => items.length;
  
  /// Alias pour itemCount (rétrocompatibilité)
  int get totalQuantity => itemCount;
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  /// Frais de livraison minimum par défaut (utilisé avant calcul)
  static const double defaultMinDeliveryFee = 300.0;
  
  /// Frais de livraison:
  /// - Si calculés dynamiquement: utilise calculatedDeliveryFee
  /// - Sinon: utilise le minimum par défaut (300 FCFA)
  /// - Si panier vide: 0
  double get deliveryFee {
    if (isEmpty) return 0.0;
    return calculatedDeliveryFee ?? defaultMinDeliveryFee;
  }
  
  /// Indique si les frais ont été calculés dynamiquement
  bool get hasCalculatedDeliveryFee => calculatedDeliveryFee != null;
  
  /// Frais de service (pourcentage sur le subtotal)
  /// Calculés depuis la config si disponible, sinon 0
  double get serviceFee {
    if (isEmpty || pricingConfig == null) return 0.0;
    return pricingConfig!.service.serviceFee.calculateFee(subtotal.toInt()).toDouble();
  }
  
  /// Frais de paiement (pour paiement en ligne uniquement)
  /// 0 pour paiement en espèces
  double get paymentFee {
    if (isEmpty || pricingConfig == null) return 0.0;
    final amountBeforePayment = subtotal + deliveryFee + serviceFee;
    return pricingConfig!.service.paymentFee.calculateFee(amountBeforePayment.toInt(), paymentMode).toDouble();
  }
  
  /// Indique si la config de tarification est chargée
  bool get hasPricingConfig => pricingConfig != null;
  
  /// Total incluant tous les frais
  double get total => subtotal + deliveryFee + serviceFee + paymentFee;

  // Check if cart has items from a specific pharmacy
  bool hasPharmacyItems(int pharmacyId) {
    return items.any((item) => item.product.pharmacy.id == pharmacyId);
  }

  // Get item by product ID
  CartItemEntity? getItem(int productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si le panier contient des produits nécessitant une ordonnance
  bool get hasPrescriptionRequiredItems {
    return items.any((item) => item.product.requiresPrescription);
  }

  /// Retourne la liste des produits nécessitant une ordonnance
  List<CartItemEntity> get prescriptionRequiredItems {
    return items.where((item) => item.product.requiresPrescription).toList();
  }

  /// Retourne les noms des produits nécessitant une ordonnance
  List<String> get prescriptionRequiredProductNames {
    return prescriptionRequiredItems.map((item) => item.product.name).toList();
  }
}
