import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/update_profile_entity.dart';

/// État du profil utilisant AsyncValue pour la gestion automatique loading/error/data
/// Pattern moderne Riverpod 2.x avec AsyncNotifier
class ProfileAsyncNotifier extends AsyncNotifier<ProfileEntity?> {
  @override
  Future<ProfileEntity?> build() async {
    // Chargement automatique au démarrage
    return _fetchProfile();
  }

  Future<ProfileEntity?> _fetchProfile() async {
    final getProfileUseCase = ref.read(getProfileUseCaseProvider);
    final result = await getProfileUseCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (profile) => profile,
    );
  }

  /// Recharge le profil
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }

  /// Met à jour le profil
  Future<bool> updateProfile(UpdateProfileEntity updateData) async {
    final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    
    // Garder l'ancien état pendant le chargement
    state = const AsyncValue.loading();

    final result = await updateProfileUseCase(updateData);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (profile) {
        state = AsyncValue.data(profile);
        return true;
      },
    );
  }

  /// Upload un avatar
  Future<bool> uploadAvatar(Uint8List imageBytes) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return false;

    final uploadAvatarUseCase = ref.read(uploadAvatarUseCaseProvider);

    final result = await uploadAvatarUseCase(imageBytes);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (avatarUrl) {
        final updatedProfile = currentProfile.copyWith(avatar: avatarUrl);
        state = AsyncValue.data(updatedProfile);
        return true;
      },
    );
  }

  /// Supprime l'avatar
  Future<bool> deleteAvatar() async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return false;

    final deleteAvatarUseCase = ref.read(deleteAvatarUseCaseProvider);

    final result = await deleteAvatarUseCase();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        final updatedProfile = currentProfile.copyWith(avatar: null);
        state = AsyncValue.data(updatedProfile);
        return true;
      },
    );
  }
}

/// Provider moderne utilisant AsyncNotifierProvider
/// Avantages:
/// - Gestion automatique des états loading/error/data
/// - Pattern AsyncValue.when() pour UI
/// - Pas besoin de créer un state séparé
/// - Chargement automatique au build
final profileAsyncProvider =
    AsyncNotifierProvider<ProfileAsyncNotifier, ProfileEntity?>(() {
  return ProfileAsyncNotifier();
});

/// Extensions pour faciliter l'utilisation dans les widgets
extension ProfileAsyncValueExtensions on AsyncValue<ProfileEntity?> {
  /// Vérifie si le profil est en cours de chargement
  bool get isLoading => this is AsyncLoading;

  /// Vérifie si une erreur s'est produite
  bool get hasError => this is AsyncError;

  /// Message d'erreur si présent
  String? get errorMessage {
    return whenOrNull(error: (error, _) => error.toString());
  }

  /// Profil actuel ou null
  ProfileEntity? get profile => valueOrNull;
}
