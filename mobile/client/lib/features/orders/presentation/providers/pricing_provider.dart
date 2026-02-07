import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../domain/entities/pricing_entity.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../../data/repositories/pricing_repository_impl.dart';

/// Provider pour le Repository de tarification
final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PricingRepositoryImpl(apiClient: apiClient);
});

/// État de la configuration de tarification
class PricingState {
  final bool isLoading;
  final PricingConfigEntity? config;
  final String? error;

  const PricingState({
    this.isLoading = false,
    this.config,
    this.error,
  });

  const PricingState.initial()
      : isLoading = false,
        config = null,
        error = null;

  PricingState copyWith({
    bool? isLoading,
    PricingConfigEntity? config,
    String? error,
  }) {
    return PricingState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      error: error,
    );
  }
}

/// Notifier pour gérer la configuration de tarification
class PricingNotifier extends StateNotifier<PricingState> {
  final PricingRepository _repository;

  PricingNotifier(this._repository) : super(const PricingState.initial());

  /// Charger la configuration de tarification depuis l'API
  Future<void> loadPricing() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getPricing();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        // Utiliser les valeurs par défaut en cas d'erreur
        config: const PricingConfigEntity.defaults(),
      ),
      (config) => state = state.copyWith(
        isLoading: false,
        config: config,
      ),
    );
  }

  /// Calculer les frais pour un panier
  /// Utilise le calcul local si la config est disponible
  PricingCalculationEntity? calculateFees({
    required int subtotal,
    required int deliveryFee,
    required String paymentMode,
  }) {
    final config = state.config;
    if (config == null) return null;

    return PricingCalculationEntity.calculate(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      paymentMode: paymentMode,
      config: config,
    );
  }

  /// Calculer les frais de livraison pour une distance
  int? calculateDeliveryFee(double distanceKm) {
    final config = state.config;
    if (config == null) return null;
    return config.delivery.calculateFee(distanceKm);
  }
}

/// Provider principal pour la tarification
final pricingProvider = StateNotifierProvider<PricingNotifier, PricingState>((ref) {
  final repository = ref.watch(pricingRepositoryProvider);
  return PricingNotifier(repository);
});

/// Provider pour obtenir la config de tarification (auto-load)
final pricingConfigProvider = FutureProvider<PricingConfigEntity?>((ref) async {
  final notifier = ref.watch(pricingProvider.notifier);
  final state = ref.watch(pricingProvider);
  
  if (state.config == null && !state.isLoading) {
    await notifier.loadPricing();
  }
  
  return ref.watch(pricingProvider).config;
});
