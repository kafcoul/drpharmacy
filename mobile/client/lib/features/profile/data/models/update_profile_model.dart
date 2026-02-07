import '../../domain/entities/update_profile_entity.dart';

/// Model pour la sérialisation des données de mise à jour du profil
class UpdateProfileModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? currentPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;

  const UpdateProfileModel({
    this.name,
    this.email,
    this.phone,
    this.currentPassword,
    this.newPassword,
    this.newPasswordConfirmation,
  });

  /// Crée un model depuis une entité
  factory UpdateProfileModel.fromEntity(UpdateProfileEntity entity) {
    return UpdateProfileModel(
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      currentPassword: entity.currentPassword,
      newPassword: entity.newPassword,
      newPasswordConfirmation: entity.newPasswordConfirmation,
    );
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (name != null) json['name'] = name;
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (currentPassword != null) json['current_password'] = currentPassword;
    if (newPassword != null) json['password'] = newPassword;
    if (newPasswordConfirmation != null) {
      json['password_confirmation'] = newPasswordConfirmation;
    }

    return json;
  }
}
