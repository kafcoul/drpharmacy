import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'pharmacy_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? role;
  final String? avatar;
  final List<PharmacyModel>? pharmacies;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    this.avatar,
    this.pharmacies,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      avatar: avatar,
      pharmacies: pharmacies?.map((e) => e.toEntity()).toList() ?? [],
    );
  }
}
