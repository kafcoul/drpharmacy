import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import 'profile_notifier.dart';
import 'profile_state.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    uploadAvatarUseCase: ref.watch(uploadAvatarUseCaseProvider),
    deleteAvatarUseCase: ref.watch(deleteAvatarUseCaseProvider),
  );
});
