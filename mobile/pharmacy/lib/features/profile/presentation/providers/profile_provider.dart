import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> updatePharmacy(int id, dynamic data) async {
    state = const AsyncValue.loading();
    
    final result = await _repository.updatePharmacy(id, data);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (updatedPharmacy) async {
        state = const AsyncValue.data(null);
        // Refresh Auth State to reflect changes everywhere
        await _ref.read(authProvider.notifier).checkAuthStatus();
      },
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    
    final result = await _repository.updateProfile(data);
    
    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        throw Exception(failure.message); // Re-throw to be caught by UI
      },
      (_) async {
        state = const AsyncValue.data(null);
        await _ref.read(authProvider.notifier).checkAuthStatus();
      },
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository, ref);
});
