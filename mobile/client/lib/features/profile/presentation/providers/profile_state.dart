import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  uploadingAvatar,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoaded => status == ProfileStatus.loaded;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get isUploadingAvatar => status == ProfileStatus.uploadingAvatar;
  bool get hasError => status == ProfileStatus.error;
  bool get hasProfile => profile != null;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  ProfileState clearError() {
    return copyWith(
      status: ProfileStatus.loaded,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
