import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/app_logger.dart';
import '../../domain/entities/pricing_entity.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../models/pricing_model.dart';

/// Implémentation du repository de tarification
class PricingRepositoryImpl implements PricingRepository {
  final ApiClient _apiClient;

  PricingRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Either<Failure, PricingConfigEntity>> getPricing() async {
    try {
      final response = await _apiClient.get('/pricing');
      final data = response.data as Map<String, dynamic>;
      final model = PricingConfigModel.fromJson(data['data']);
      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('[PricingRepository] getPricing error', error: e, stackTrace: stackTrace);
      // Retourner les valeurs par défaut plutôt qu'une erreur
      // pour ne pas bloquer l'utilisateur
      return const Right(PricingConfigEntity.defaults());
    }
  }

  @override
  Future<Either<Failure, PricingCalculationEntity>> calculateFees({
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
      final model = PricingCalculationModel.fromJson(data['data']);
      return Right(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('[PricingRepository] calculateFees error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: 'Erreur lors du calcul des frais'));
    }
  }

  @override
  Future<Either<Failure, int>> estimateDeliveryFee({
    required double distanceKm,
  }) async {
    try {
      final response = await _apiClient.post('/pricing/delivery', data: {
        'distance_km': distanceKm,
      });
      final data = response.data as Map<String, dynamic>;
      final deliveryFee = data['data']['delivery_fee'] as int? ?? 300;
      return Right(deliveryFee);
    } catch (e, stackTrace) {
      AppLogger.error('[PricingRepository] estimateDeliveryFee error', error: e, stackTrace: stackTrace);
      // Retourner le minimum par défaut
      return const Right(300);
    }
  }
}
