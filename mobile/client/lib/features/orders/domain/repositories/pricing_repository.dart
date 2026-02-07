import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pricing_entity.dart';

/// Interface Repository pour la tarification
/// Définit le contrat que doit respecter l'implémentation Data layer
abstract class PricingRepository {
  /// Récupérer la configuration de tarification
  Future<Either<Failure, PricingConfigEntity>> getPricing();

  /// Calculer les frais pour un panier donné (via API)
  Future<Either<Failure, PricingCalculationEntity>> calculateFees({
    required int subtotal,
    required int deliveryFee,
    required String paymentMode,
  });

  /// Estimer les frais de livraison selon la distance
  Future<Either<Failure, int>> estimateDeliveryFee({
    required double distanceKm,
  });
}
