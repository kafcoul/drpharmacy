import 'package:equatable/equatable.dart';

/// Entité représentant les données de mise à jour du profil
/// Note: La sérialisation est gérée par UpdateProfileModel dans le layer Data
class UpdateProfileEntity extends Equatable {
  final String? name;
  final String? email;
  final String? phone;
  final String? currentPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;

  const UpdateProfileEntity({
    this.name,
    this.email,
    this.phone,
    this.currentPassword,
    this.newPassword,
    this.newPasswordConfirmation,
  });

  bool get hasPasswordChange =>
      currentPassword != null && newPassword != null;

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      ];
}
