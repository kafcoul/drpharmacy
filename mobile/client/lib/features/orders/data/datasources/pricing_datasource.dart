import '../../../../core/network/api_client.dart';
import '../../../../core/services/app_logger.dart';

/// DataSource pour récupérer les paramètres de tarification depuis l'API
/// Permet de calculer les frais de service et paiement côté client
class PricingDataSource {
  final ApiClient _apiClient;

  PricingDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Récupérer tous les paramètres de tarification
  Future<PricingConfig> getPricing() async {
    try {
      final response = await _apiClient.get('/pricing');
      final data = response.data as Map<String, dynamic>;
      return PricingConfig.fromJson(data['data']);
    } catch (e, stackTrace) {
      AppLogger.error('[Pricing] getPricing error', error: e, stackTrace: stackTrace);
      // Retourner les valeurs par défaut en cas d'erreur
      return PricingConfig.defaults();
    }
  }

  /// Calculer les frais pour un panier donné
  Future<PricingCalculation> calculateFees({
    required int subtotal,
    required int deliveryFee,
    required String paymentMode,
  }) async {
    try {
      final response = await _apiClient.post('/pricing/calculate', data: {
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'payment_mode': paymentMode,
      });
      final data = response.data as Map<String, dynamic>;
      return PricingCalculation.fromJson(data['data']);
    } catch (e, stackTrace) {
      AppLogger.error('[Pricing] calculateFees error', error: e, stackTrace: stackTrace);
      // Calculer localement en cas d'erreur
      return PricingCalculation(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        serviceFee: 0,
        paymentFee: 0,
        totalAmount: subtotal + deliveryFee,
        pharmacyAmount: subtotal,
      );
    }
  }

  /// Estimer les frais de livraison selon la distance
  Future<DeliveryEstimate> estimateDelivery({required double distanceKm}) async {
    try {
      final response = await _apiClient.post('/pricing/delivery', data: {
        'distance_km': distanceKm,
      });
      final data = response.data as Map<String, dynamic>;
      return DeliveryEstimate.fromJson(data['data']);
    } catch (e, stackTrace) {
      AppLogger.error('[Pricing] estimateDelivery error', error: e, stackTrace: stackTrace);
      // Calcul par défaut
      return DeliveryEstimate(
        distanceKm: distanceKm,
        deliveryFee: 300, // minimum par défaut
      );
    }
  }
}

/// Configuration complète de la tarification
class PricingConfig {
  final DeliveryPricing delivery;
  final ServicePricing service;

  PricingConfig({
    required this.delivery,
    required this.service,
  });

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      delivery: DeliveryPricing.fromJson(json['delivery']),
      service: ServicePricing.fromJson(json['service']),
    );
  }

  /// Valeurs par défaut si l'API n'est pas disponible
  factory PricingConfig.defaults() {
    return PricingConfig(
      delivery: DeliveryPricing.defaults(),
      service: ServicePricing.defaults(),
    );
  }
}

/// Paramètres de tarification livraison
class DeliveryPricing {
  final int baseFee;
  final int feePerKm;
  final int minFee;
  final int maxFee;

  DeliveryPricing({
    required this.baseFee,
    required this.feePerKm,
    required this.minFee,
    required this.maxFee,
  });

  factory DeliveryPricing.fromJson(Map<String, dynamic> json) {
    return DeliveryPricing(
      baseFee: json['base_fee'] ?? 200,
      feePerKm: json['fee_per_km'] ?? 100,
      minFee: json['min_fee'] ?? 300,
      maxFee: json['max_fee'] ?? 5000,
    );
  }

  factory DeliveryPricing.defaults() {
    return DeliveryPricing(
      baseFee: 200,
      feePerKm: 100,
      minFee: 300,
      maxFee: 5000,
    );
  }

  /// Calculer les frais de livraison pour une distance donnée
  int calculateFee(double distanceKm) {
    int fee = baseFee + (distanceKm * feePerKm).ceil();
    if (fee < minFee) fee = minFee;
    if (fee > maxFee) fee = maxFee;
    return fee;
  }
}

/// Paramètres de tarification service et paiement
class ServicePricing {
  final ServiceFeeConfig serviceFee;
  final PaymentFeeConfig paymentFee;

  ServicePricing({
    required this.serviceFee,
    required this.paymentFee,
  });

  factory ServicePricing.fromJson(Map<String, dynamic> json) {
    return ServicePricing(
      serviceFee: ServiceFeeConfig.fromJson(json['service_fee']),
      paymentFee: PaymentFeeConfig.fromJson(json['payment_fee']),
    );
  }

  factory ServicePricing.defaults() {
    return ServicePricing(
      serviceFee: ServiceFeeConfig.defaults(),
      paymentFee: PaymentFeeConfig.defaults(),
    );
  }
}

/// Configuration des frais de service
class ServiceFeeConfig {
  final bool enabled;
  final double percentage;
  final int min;
  final int max;

  ServiceFeeConfig({
    required this.enabled,
    required this.percentage,
    required this.min,
    required this.max,
  });

  factory ServiceFeeConfig.fromJson(Map<String, dynamic> json) {
    return ServiceFeeConfig(
      enabled: json['enabled'] ?? true,
      percentage: (json['percentage'] ?? 3).toDouble(),
      min: json['min'] ?? 100,
      max: json['max'] ?? 2000,
    );
  }

  factory ServiceFeeConfig.defaults() {
    return ServiceFeeConfig(
      enabled: true,
      percentage: 3,
      min: 100,
      max: 2000,
    );
  }

  /// Calculer les frais de service pour un montant donné
  int calculateFee(int subtotal) {
    if (!enabled) return 0;
    int fee = (subtotal * percentage / 100).ceil();
    if (fee < min) fee = min;
    if (fee > max) fee = max;
    return fee;
  }
}

/// Configuration des frais de paiement
class PaymentFeeConfig {
  final bool enabled;
  final int fixedFee;
  final double percentage;

  PaymentFeeConfig({
    required this.enabled,
    required this.fixedFee,
    required this.percentage,
  });

  factory PaymentFeeConfig.fromJson(Map<String, dynamic> json) {
    return PaymentFeeConfig(
      enabled: json['enabled'] ?? true,
      fixedFee: json['fixed_fee'] ?? 50,
      percentage: (json['percentage'] ?? 1.5).toDouble(),
    );
  }

  factory PaymentFeeConfig.defaults() {
    return PaymentFeeConfig(
      enabled: true,
      fixedFee: 50,
      percentage: 1.5,
    );
  }

  /// Calculer les frais de paiement pour un montant donné
  /// Retourne 0 pour les paiements en espèces
  int calculateFee(int amount, String paymentMode) {
    if (!enabled) return 0;
    if (paymentMode == 'cash' || paymentMode == 'on_delivery') return 0;
    
    int percentageFee = (amount * percentage / 100).ceil();
    return fixedFee + percentageFee;
  }
}

/// Résultat du calcul des frais
class PricingCalculation {
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int paymentFee;
  final int totalAmount;
  final int pharmacyAmount;

  PricingCalculation({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.paymentFee,
    required this.totalAmount,
    required this.pharmacyAmount,
  });

  factory PricingCalculation.fromJson(Map<String, dynamic> json) {
    return PricingCalculation(
      subtotal: json['subtotal'] ?? 0,
      deliveryFee: json['delivery_fee'] ?? 0,
      serviceFee: json['service_fee'] ?? 0,
      paymentFee: json['payment_fee'] ?? 0,
      totalAmount: json['total_amount'] ?? 0,
      pharmacyAmount: json['pharmacy_amount'] ?? 0,
    );
  }

  /// Calcul local des frais (sans appel API)
  factory PricingCalculation.calculate({
    required int subtotal,
    required int deliveryFee,
    required String paymentMode,
    required PricingConfig config,
  }) {
    final serviceFee = config.service.serviceFee.calculateFee(subtotal);
    final amountBeforePayment = subtotal + deliveryFee + serviceFee;
    final paymentFee = config.service.paymentFee.calculateFee(amountBeforePayment, paymentMode);
    final totalAmount = amountBeforePayment + paymentFee;

    return PricingCalculation(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      paymentFee: paymentFee,
      totalAmount: totalAmount,
      pharmacyAmount: subtotal, // La pharmacie reçoit le prix exact des médicaments
    );
  }
}

/// Résultat de l'estimation de livraison
class DeliveryEstimate {
  final double distanceKm;
  final int deliveryFee;

  DeliveryEstimate({
    required this.distanceKm,
    required this.deliveryFee,
  });

  factory DeliveryEstimate.fromJson(Map<String, dynamic> json) {
    return DeliveryEstimate(
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      deliveryFee: json['delivery_fee'] ?? 0,
    );
  }
}
