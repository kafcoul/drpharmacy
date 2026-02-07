import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../products/domain/entities/pharmacy_entity.dart';
import '../../data/datasources/delivery_pricing_datasource.dart';
import 'cart_provider.dart';

/// Provider pour le datasource de tarification livraison
final deliveryPricingDataSourceProvider = Provider<DeliveryPricingDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DeliveryPricingDataSource(apiClient: apiClient);
});

/// État des frais de livraison estimés
class DeliveryFeeState {
  final bool isLoading;
  final double? estimatedFee;
  final double? distanceKm;
  final String? error;

  const DeliveryFeeState({
    this.isLoading = false,
    this.estimatedFee,
    this.distanceKm,
    this.error,
  });

  const DeliveryFeeState.initial()
      : isLoading = false,
        estimatedFee = null,
        distanceKm = null,
        error = null;

  DeliveryFeeState copyWith({
    bool? isLoading,
    double? estimatedFee,
    double? distanceKm,
    String? error,
    bool clearEstimate = false,
  }) {
    return DeliveryFeeState(
      isLoading: isLoading ?? this.isLoading,
      estimatedFee: clearEstimate ? null : (estimatedFee ?? this.estimatedFee),
      distanceKm: clearEstimate ? null : (distanceKm ?? this.distanceKm),
      error: error,
    );
  }
}

/// Notifier pour calculer les frais de livraison dynamiquement
class DeliveryFeeNotifier extends StateNotifier<DeliveryFeeState> {
  final DeliveryPricingDataSource _dataSource;
  final Ref _ref;

  DeliveryFeeNotifier(this._dataSource, this._ref)
      : super(const DeliveryFeeState.initial());

  /// Calculer les frais de livraison selon l'adresse sélectionnée
  Future<void> estimateDeliveryFee({
    required AddressEntity address,
  }) async {
    // Récupérer la pharmacie depuis le panier
    final cartState = _ref.read(cartProvider);
    if (cartState.isEmpty) {
      state = state.copyWith(clearEstimate: true);
      return;
    }

    // Obtenir la pharmacie du premier article
    final pharmacy = cartState.items.first.product.pharmacy;

    // Vérifier si on a les coordonnées nécessaires
    if (pharmacy.latitude == null || pharmacy.longitude == null) {
      // Pas de coordonnées pharmacie, utiliser le minimum
      state = state.copyWith(
        estimatedFee: 300.0,
        distanceKm: null,
        isLoading: false,
      );
      _updateCartDeliveryFee(300.0, null);
      return;
    }

    if (address.latitude == null || address.longitude == null) {
      // Pas de coordonnées adresse, utiliser le minimum
      state = state.copyWith(
        estimatedFee: 300.0,
        distanceKm: null,
        isLoading: false,
      );
      _updateCartDeliveryFee(300.0, null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dataSource.estimate(
        pharmacyLat: pharmacy.latitude,
        pharmacyLng: pharmacy.longitude,
        deliveryLat: address.latitude,
        deliveryLng: address.longitude,
      );

      state = state.copyWith(
        isLoading: false,
        estimatedFee: response.deliveryFee.toDouble(),
        distanceKm: response.distanceKm,
      );

      // Mettre à jour le panier avec les nouveaux frais
      _updateCartDeliveryFee(
        response.deliveryFee.toDouble(),
        response.distanceKm,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du calcul des frais',
        estimatedFee: 300.0, // Fallback au minimum
      );
      _updateCartDeliveryFee(300.0, null);
    }
  }

  /// Estimer les frais de livraison avec coordonnées manuelles
  Future<void> estimateWithCoordinates({
    required PharmacyEntity pharmacy,
    required double deliveryLat,
    required double deliveryLng,
  }) async {
    if (pharmacy.latitude == null || pharmacy.longitude == null) {
      state = state.copyWith(
        estimatedFee: 300.0,
        distanceKm: null,
        isLoading: false,
      );
      _updateCartDeliveryFee(300.0, null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dataSource.estimate(
        pharmacyLat: pharmacy.latitude,
        pharmacyLng: pharmacy.longitude,
        deliveryLat: deliveryLat,
        deliveryLng: deliveryLng,
      );

      state = state.copyWith(
        isLoading: false,
        estimatedFee: response.deliveryFee.toDouble(),
        distanceKm: response.distanceKm,
      );

      _updateCartDeliveryFee(
        response.deliveryFee.toDouble(),
        response.distanceKm,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du calcul des frais',
        estimatedFee: 300.0,
      );
      _updateCartDeliveryFee(300.0, null);
    }
  }

  /// Réinitialiser les frais estimés
  void reset() {
    state = const DeliveryFeeState.initial();
    _ref.read(cartProvider.notifier).clearDeliveryFee();
  }

  void _updateCartDeliveryFee(double fee, double? distanceKm) {
    _ref.read(cartProvider.notifier).updateDeliveryFee(
          deliveryFee: fee,
          distanceKm: distanceKm,
        );
  }
}

/// Provider pour les frais de livraison
final deliveryFeeProvider =
    StateNotifierProvider.autoDispose<DeliveryFeeNotifier, DeliveryFeeState>(
  (ref) {
    final dataSource = ref.watch(deliveryPricingDataSourceProvider);
    return DeliveryFeeNotifier(dataSource, ref);
  },
);
