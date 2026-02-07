import 'pharmacy_entity.dart';

class UserEntity {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? role;
  final String? avatar;
  final List<PharmacyEntity> pharmacies;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    this.avatar,
    this.pharmacies = const [],
  });
}
