import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../domain/entities/pharmacy_entity.dart';

/// État des pharmacies pour AsyncNotifier
/// Contient les différentes listes de pharmacies
class PharmaciesAsyncState {
  final List<PharmacyEntity> pharmacies;
  final List<PharmacyEntity> nearbyPharmacies;
  final List<PharmacyEntity> onDutyPharmacies;
  final List<PharmacyEntity> featuredPharmacies;
  final PharmacyEntity? selectedPharmacy;
  final bool hasReachedMax;
  final int currentPage;

  const PharmaciesAsyncState({
    this.pharmacies = const [],
    this.nearbyPharmacies = const [],
    this.onDutyPharmacies = const [],
    this.featuredPharmacies = const [],
    this.selectedPharmacy,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  PharmaciesAsyncState copyWith({
    List<PharmacyEntity>? pharmacies,
    List<PharmacyEntity>? nearbyPharmacies,
    List<PharmacyEntity>? onDutyPharmacies,
    List<PharmacyEntity>? featuredPharmacies,
    PharmacyEntity? selectedPharmacy,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return PharmaciesAsyncState(
      pharmacies: pharmacies ?? this.pharmacies,
      nearbyPharmacies: nearbyPharmacies ?? this.nearbyPharmacies,
      onDutyPharmacies: onDutyPharmacies ?? this.onDutyPharmacies,
      featuredPharmacies: featuredPharmacies ?? this.featuredPharmacies,
      selectedPharmacy: selectedPharmacy ?? this.selectedPharmacy,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// AsyncNotifier moderne pour les pharmacies
/// Avantages:
/// - Gestion automatique loading/error/data via AsyncValue
/// - Chargement initial automatique via build()
/// - Meilleure intégration avec ref.watch()
/// - Pas de status enum manuel
class PharmaciesAsyncNotifier extends AsyncNotifier<PharmaciesAsyncState> {
  @override
  Future<PharmaciesAsyncState> build() async {
    // Chargement initial automatique
    return _loadInitialData();
  }

  Future<PharmaciesAsyncState> _loadInitialData() async {
    final getPharmaciesUseCase = ref.read(getPharmaciesUseCaseProvider);
    final getFeaturedPharmaciesUseCase = ref.read(getFeaturedPharmaciesUseCaseProvider);

    // Charger les pharmacies et les pharmacies vedettes en parallèle
    final results = await Future.wait([
      getPharmaciesUseCase(page: 1, perPage: 20),
      getFeaturedPharmaciesUseCase(),
    ]);

    final pharmaciesResult = results[0];
    final featuredResult = results[1];

    List<PharmacyEntity> pharmacies = [];
    List<PharmacyEntity> featured = [];

    pharmaciesResult.fold(
      (failure) => throw Exception(failure.message),
      (data) => pharmacies = data,
    );

    featuredResult.fold(
      (failure) {}, // Ignorer l'erreur pour featured, non critique
      (data) => featured = data,
    );

    return PharmaciesAsyncState(
      pharmacies: pharmacies,
      featuredPharmacies: featured,
      hasReachedMax: pharmacies.length < 20,
      currentPage: 1,
    );
  }

  /// Rafraîchir toutes les données
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadInitialData());
  }

  /// Charger plus de pharmacies (pagination)
  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.hasReachedMax) return;

    final getPharmaciesUseCase = ref.read(getPharmaciesUseCaseProvider);
    final nextPage = currentState.currentPage + 1;

    final result = await getPharmaciesUseCase(page: nextPage, perPage: 20);

    result.fold(
      (failure) {
        // Garder les données existantes en cas d'erreur de pagination
      },
      (newPharmacies) {
        state = AsyncValue.data(currentState.copyWith(
          pharmacies: [...currentState.pharmacies, ...newPharmacies],
          hasReachedMax: newPharmacies.length < 20,
          currentPage: nextPage,
        ));
      },
    );
  }

  /// Charger les pharmacies à proximité
  Future<void> fetchNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    final currentState = state.valueOrNull ?? const PharmaciesAsyncState();
    final getNearbyPharmaciesUseCase = ref.read(getNearbyPharmaciesUseCaseProvider);

    final result = await getNearbyPharmaciesUseCase(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (pharmacies) {
        state = AsyncValue.data(currentState.copyWith(
          nearbyPharmacies: pharmacies,
        ));
      },
    );
  }

  /// Charger les pharmacies de garde
  Future<void> fetchOnDutyPharmacies() async {
    final currentState = state.valueOrNull ?? const PharmaciesAsyncState();
    final getOnDutyPharmaciesUseCase = ref.read(getOnDutyPharmaciesUseCaseProvider);

    final result = await getOnDutyPharmaciesUseCase();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (pharmacies) {
        state = AsyncValue.data(currentState.copyWith(
          onDutyPharmacies: pharmacies,
        ));
      },
    );
  }

  /// Charger les détails d'une pharmacie
  Future<void> fetchPharmacyDetails(int id) async {
    final currentState = state.valueOrNull ?? const PharmaciesAsyncState();
    final getPharmacyDetailsUseCase = ref.read(getPharmacyDetailsUseCaseProvider);

    final result = await getPharmacyDetailsUseCase(id);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (pharmacy) {
        state = AsyncValue.data(currentState.copyWith(
          selectedPharmacy: pharmacy,
        ));
      },
    );
  }

  /// Effacer la pharmacie sélectionnée
  void clearSelectedPharmacy() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(PharmaciesAsyncState(
        pharmacies: currentState.pharmacies,
        nearbyPharmacies: currentState.nearbyPharmacies,
        onDutyPharmacies: currentState.onDutyPharmacies,
        featuredPharmacies: currentState.featuredPharmacies,
        selectedPharmacy: null,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
      ));
    }
  }
}

/// Provider moderne AsyncNotifierProvider
/// Usage: `ref.watch(pharmaciesAsyncProvider)`
/// Retourne `AsyncValue<PharmaciesAsyncState>` avec `.when()` pour l'UI
final pharmaciesAsyncProvider =
    AsyncNotifierProvider<PharmaciesAsyncNotifier, PharmaciesAsyncState>(() {
  return PharmaciesAsyncNotifier();
});

/// Providers dérivés pour accéder facilement aux sous-données
final featuredPharmaciesProvider = Provider<List<PharmacyEntity>>((ref) {
  return ref.watch(pharmaciesAsyncProvider).valueOrNull?.featuredPharmacies ?? [];
});

final nearbyPharmaciesProvider = Provider<List<PharmacyEntity>>((ref) {
  return ref.watch(pharmaciesAsyncProvider).valueOrNull?.nearbyPharmacies ?? [];
});

final onDutyPharmaciesProvider = Provider<List<PharmacyEntity>>((ref) {
  return ref.watch(pharmaciesAsyncProvider).valueOrNull?.onDutyPharmacies ?? [];
});

final selectedPharmacyProvider = Provider<PharmacyEntity?>((ref) {
  return ref.watch(pharmaciesAsyncProvider).valueOrNull?.selectedPharmacy;
});
