import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../data/datasources/address_remote_datasource.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';

/// Provider pour le data source des adresses
final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressRemoteDataSource(apiClient);
});

/// Provider pour le repository des adresses
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final dataSource = ref.watch(addressRemoteDataSourceProvider);
  return AddressRepositoryImpl(dataSource);
});

/// État des adresses
class AddressesState {
  final List<AddressEntity> addresses;
  final bool isLoading;
  final String? error;
  final AddressEntity? selectedAddress;

  const AddressesState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
    this.selectedAddress,
  });

  AddressesState copyWith({
    List<AddressEntity>? addresses,
    bool? isLoading,
    String? error,
    AddressEntity? selectedAddress,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return AddressesState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedAddress: clearSelected ? null : (selectedAddress ?? this.selectedAddress),
    );
  }

  /// Obtenir l'adresse par défaut
  AddressEntity? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull;
}

/// Notifier pour la gestion des adresses
class AddressesNotifier extends StateNotifier<AddressesState> {
  final AddressRepository _repository;

  AddressesNotifier(this._repository) : super(const AddressesState());

  /// Charger toutes les adresses
  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.getAddresses();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (addresses) => state = state.copyWith(
        isLoading: false,
        addresses: addresses,
        selectedAddress: addresses.where((a) => a.isDefault).firstOrNull,
      ),
    );
  }

  /// Créer une nouvelle adresse
  Future<bool> createAddress({
    required String label,
    required String address,
    String? city,
    String? district,
    String? phone,
    String? instructions,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.createAddress(
      label: label,
      address: address,
      city: city,
      district: district,
      phone: phone,
      instructions: instructions,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (newAddress) {
        // Mettre à jour la liste
        var updatedAddresses = [...state.addresses];
        
        // Si la nouvelle adresse est par défaut, retirer le flag des autres
        if (newAddress.isDefault) {
          updatedAddresses = updatedAddresses
              .map((a) => a.copyWith(isDefault: false))
              .toList();
        }
        
        updatedAddresses.add(newAddress);
        
        state = state.copyWith(
          isLoading: false,
          addresses: updatedAddresses,
          selectedAddress: newAddress.isDefault ? newAddress : state.selectedAddress,
        );
        return true;
      },
    );
  }

  /// Mettre à jour une adresse
  Future<bool> updateAddress({
    required int id,
    String? label,
    String? address,
    String? city,
    String? district,
    String? phone,
    String? instructions,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.updateAddress(
      id: id,
      label: label,
      address: address,
      city: city,
      district: district,
      phone: phone,
      instructions: instructions,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedAddress) {
        var updatedAddresses = state.addresses.map((a) {
          if (a.id == id) return updatedAddress;
          // Si l'adresse mise à jour est par défaut, retirer le flag des autres
          if (updatedAddress.isDefault && a.isDefault) {
            return a.copyWith(isDefault: false);
          }
          return a;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          addresses: updatedAddresses,
          selectedAddress: updatedAddress.isDefault ? updatedAddress : 
              (state.selectedAddress?.id == id ? updatedAddress : state.selectedAddress),
        );
        return true;
      },
    );
  }

  /// Supprimer une adresse
  Future<bool> deleteAddress(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.deleteAddress(id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        final updatedAddresses = state.addresses.where((a) => a.id != id).toList();
        
        // Si l'adresse supprimée était la sélectionnée, en choisir une autre
        AddressEntity? newSelected = state.selectedAddress;
        if (state.selectedAddress?.id == id) {
          newSelected = updatedAddresses.where((a) => a.isDefault).firstOrNull ??
              updatedAddresses.firstOrNull;
        }
        
        state = state.copyWith(
          isLoading: false,
          addresses: updatedAddresses,
          selectedAddress: newSelected,
          clearSelected: newSelected == null,
        );
        return true;
      },
    );
  }

  /// Définir une adresse comme adresse par défaut
  Future<bool> setDefaultAddress(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.setDefaultAddress(id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedAddress) {
        final updatedAddresses = state.addresses.map((a) {
          if (a.id == id) return updatedAddress;
          if (a.isDefault) return a.copyWith(isDefault: false);
          return a;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          addresses: updatedAddresses,
          selectedAddress: updatedAddress,
        );
        return true;
      },
    );
  }

  /// Sélectionner une adresse (pour une commande)
  void selectAddress(AddressEntity address) {
    state = state.copyWith(selectedAddress: address);
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider principal pour les adresses
final addressesProvider =
    StateNotifierProvider<AddressesNotifier, AddressesState>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return AddressesNotifier(repository);
});

/// Provider pour les données du formulaire d'adresse
final addressFormDataProvider = FutureProvider<AddressFormData>((ref) async {
  final repository = ref.watch(addressRepositoryProvider);
  final result = await repository.getLabels();
  return result.fold(
    (failure) => AddressFormData(
      labels: ['Maison', 'Bureau', 'Famille', 'Autre'],
    ),
    (data) => data,
  );
});

/// Provider pour les labels disponibles (rétrocompatibilité)
final addressLabelsProvider = FutureProvider<List<String>>((ref) async {
  final formData = await ref.watch(addressFormDataProvider.future);
  return formData.labels;
});

/// Provider pour l'adresse par défaut
final defaultAddressProvider = Provider<AddressEntity?>((ref) {
  final state = ref.watch(addressesProvider);
  return state.defaultAddress;
});

/// Provider pour l'adresse sélectionnée (pour une commande)
final selectedAddressProvider = Provider<AddressEntity?>((ref) {
  final state = ref.watch(addressesProvider);
  return state.selectedAddress;
});
