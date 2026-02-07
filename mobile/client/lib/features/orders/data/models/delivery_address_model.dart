import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/delivery_address_entity.dart';

part 'delivery_address_model.g.dart';

@JsonSerializable()
class DeliveryAddressModel {
  final String address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;

  const DeliveryAddressModel({
    required this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryAddressModelToJson(this);

  DeliveryAddressEntity toEntity() {
    return DeliveryAddressEntity(
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
    );
  }

  factory DeliveryAddressModel.fromEntity(DeliveryAddressEntity entity) {
    return DeliveryAddressModel(
      address: entity.address,
      city: entity.city,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phone: entity.phone,
    );
  }
}
