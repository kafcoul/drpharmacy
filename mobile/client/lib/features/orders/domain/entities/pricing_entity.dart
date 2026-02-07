import 'package:equatable/equatable.dart';

/// Configuration de tarification - Entity du Domain Layer
/// Aucune dépendance Flutter/HTTP - données pures
class PricingConfigEntity extends Equatable {
  final DeliveryPricingEntity delivery;
  final ServicePricingEntity service;

  const PricingConfigEntity({
    required this.delivery,
    required this.service,
  });

  /// Valeurs par défaut si l'API n'est pas disponible
  const PricingConfigEntity.defaults()
      : delivery = const DeliveryPricingEntity.defaults(),
        service = const ServicePricingEntity.defaults();

  @override
  List<Object?> get props => [delivery, service];
}

/// Paramètres de tarification livraison
class DeliveryPricingEntity extends Equatable {
  final int baseFee;
  final int feePerKm;
  final int minFee;
  final int maxFee;

  const DeliveryPricingEntity({
    required this.baseFee,
    required this.feePerKm,
    required this.minFee,
    required this.maxFee,
  });

  const DeliveryPricingEntity.defaults()
      : baseFee = 200,
        feePerKm = 100,
        minFee = 300,
        maxFee = 5000;

  /// Calculer les frais de livraison pour une distance donnée
  int calculateFee(double distanceKm) {
    int fee = baseFee + (distanceKm * feePerKm).ceil();
    return fee.clamp(minFee, maxFee);
  }

  @override
  List<Object?> get props => [baseFee, feePerKm, minFee, maxFee];
}

/// Paramètres de tarification service et paiement
class ServicePricingEntity extends Equatable {
  final ServiceFeeConfigEntity serviceFee;
  final PaymentFeeConfigEntity paymentFee;

  const ServicePricingEntity({
    required this.serviceFee,
    required this.paymentFee,
  });

  const ServicePricingEntity.defaults()
      : serviceFee = const ServiceFeeConfigEntity.defaults(),
        paymentFee = const PaymentFeeConfigEntity.defaults();

  @override
  List<Object?> get props => [serviceFee, paymentFee];
}

/// Configuration des frais de service
class ServiceFeeConfigEntity extends Equatable {
  final bool enabled;
  final double percentage;
  final int min;
  final int max;

  const ServiceFeeConfigEntity({
    required this.enabled,
    required this.percentage,
    required this.min,
    required this.max,
  });

  const ServiceFeeConfigEntity.defaults()
      : enabled = true,
        percentage = 3,
        min = 100,
        max = 2000;

  /// Calculer les frais de service pour un montant donné
  int calculateFee(int subtotal) {
    if (!enabled) return 0;
    int fee = (subtotal * percentage / 100).ceil();
    return fee.clamp(min, max);
  }

  @override
  List<Object?> get props => [enabled, percentage, min, max];
}

/// Configuration des frais de paiement
class PaymentFeeConfigEntity extends Equatable {
  final bool enabled;
  final int fixedFee;
  final double percentage;

  const PaymentFeeConfigEntity({
    required this.enabled,
    required this.fixedFee,
    required this.percentage,
  });

  const PaymentFeeConfigEntity.defaults()
      : enabled = true,
        fixedFee = 50,
        percentage = 1.5;

  /// Modes de paiement en espèces (pas de frais)
  static const cashModes = ['cash', 'on_delivery'];

  /// Calculer les frais de paiement pour un montant donné
  /// Retourne 0 pour les paiements en espèces
  int calculateFee(int amount, String paymentMode) {
    if (!enabled) return 0;
    if (cashModes.contains(paymentMode)) return 0;
    
    int percentageFee = (amount * percentage / 100).ceil();
    return fixedFee + percentageFee;
  }

  @override
  List<Object?> get props => [enabled, fixedFee, percentage];
}

/// Résultat du calcul des frais
class PricingCalculationEntity extends Equatable {
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int paymentFee;
  final int totalAmount;
  final int pharmacyAmount;

  const PricingCalculationEntity({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.paymentFee,
    required this.totalAmount,
    required this.pharmacyAmount,
  });

  /// Calcul local des frais
  factory PricingCalculationEntity.calculate({
    required int subtotal,
    required int deliveryFee,
    required String paymentMode,
    required PricingConfigEntity config,
  }) {
    final serviceFee = config.service.serviceFee.calculateFee(subtotal);
    final amountBeforePayment = subtotal + deliveryFee + serviceFee;
    final paymentFee = config.service.paymentFee.calculateFee(amountBeforePayment, paymentMode);
    final totalAmount = amountBeforePayment + paymentFee;

    return PricingCalculationEntity(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      paymentFee: paymentFee,
      totalAmount: totalAmount,
      pharmacyAmount: subtotal,
    );
  }

  @override
  List<Object?> get props => [subtotal, deliveryFee, serviceFee, paymentFee, totalAmount, pharmacyAmount];
}
