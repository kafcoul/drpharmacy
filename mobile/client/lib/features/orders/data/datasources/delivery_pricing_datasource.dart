import '../../../../core/network/api_client.dart';
import '../../../../core/services/app_logger.dart';

/// DataSource pour l'estimation des frais de livraison
class DeliveryPricingDataSource {
  final ApiClient _apiClient;

  DeliveryPricingDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Récupérer les paramètres de tarification
  /// GET /api/delivery/pricing
  Future<DeliveryPricingResponse> getPricing() async {
    try {
      final response = await _apiClient.get('/delivery/pricing');
      final data = response.data as Map<String, dynamic>;
      return DeliveryPricingResponse.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('[DeliveryPricing] getPricing error',
          error: e, stackTrace: stackTrace);
      // Retourner les valeurs par défaut en cas d'erreur
      return DeliveryPricingResponse.defaults();
    }
  }

  /// Estimer les frais de livraison
  /// POST /api/delivery/estimate
  Future<DeliveryEstimateResponse> estimate({
    double? distanceKm,
    double? pharmacyLat,
    double? pharmacyLng,
    double? deliveryLat,
    double? deliveryLng,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (distanceKm != null) {
        body['distance_km'] = distanceKm;
      } else if (pharmacyLat != null &&
          pharmacyLng != null &&
          deliveryLat != null &&
          deliveryLng != null) {
        body['pharmacy_lat'] = pharmacyLat;
        body['pharmacy_lng'] = pharmacyLng;
        body['delivery_lat'] = deliveryLat;
        body['delivery_lng'] = deliveryLng;
      }

      final response = await _apiClient.post('/delivery/estimate', data: body);
      final data = response.data as Map<String, dynamic>;
      return DeliveryEstimateResponse.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('[DeliveryPricing] estimate error',
          error: e, stackTrace: stackTrace);
      // Retourner les frais minimum par défaut
      return DeliveryEstimateResponse.defaults();
    }
  }
}

/// Réponse pour les paramètres de tarification
class DeliveryPricingResponse {
  final int baseFee;
  final int feePerKm;
  final int minFee;
  final int maxFee;
  final String currency;

  DeliveryPricingResponse({
    required this.baseFee,
    required this.feePerKm,
    required this.minFee,
    required this.maxFee,
    required this.currency,
  });

  factory DeliveryPricingResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryPricingResponse(
      baseFee: json['base_fee'] ?? 200,
      feePerKm: json['fee_per_km'] ?? 100,
      minFee: json['min_fee'] ?? 300,
      maxFee: json['max_fee'] ?? 5000,
      currency: json['currency'] ?? 'XOF',
    );
  }

  factory DeliveryPricingResponse.defaults() {
    return DeliveryPricingResponse(
      baseFee: 200,
      feePerKm: 100,
      minFee: 300,
      maxFee: 5000,
      currency: 'XOF',
    );
  }

  /// Calculer les frais localement (pour estimation rapide)
  int calculateFee(double distanceKm) {
    int fee = baseFee + (distanceKm * feePerKm).ceil();
    if (fee < minFee) fee = minFee;
    if (fee > maxFee) fee = maxFee;
    return fee;
  }
}

/// Réponse pour l'estimation des frais
class DeliveryEstimateResponse {
  final double distanceKm;
  final int deliveryFee;
  final String currency;
  final int baseFee;
  final int distanceFee;

  DeliveryEstimateResponse({
    required this.distanceKm,
    required this.deliveryFee,
    required this.currency,
    required this.baseFee,
    required this.distanceFee,
  });

  factory DeliveryEstimateResponse.fromJson(Map<String, dynamic> json) {
    final breakdown = json['breakdown'] ?? {};
    return DeliveryEstimateResponse(
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      deliveryFee: json['delivery_fee'] ?? 300,
      currency: json['currency'] ?? 'XOF',
      baseFee: breakdown['base_fee'] ?? 200,
      distanceFee: breakdown['distance_fee'] ?? 100,
    );
  }

  factory DeliveryEstimateResponse.defaults() {
    return DeliveryEstimateResponse(
      distanceKm: 0,
      deliveryFee: 300, // Frais minimum par défaut
      currency: 'XOF',
      baseFee: 200,
      distanceFee: 100,
    );
  }
}
