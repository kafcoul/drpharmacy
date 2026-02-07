import 'package:equatable/equatable.dart';

class DeliveryAddressEntity extends Equatable {
  final String address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;

  const DeliveryAddressEntity({
    required this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
  });

  @override
  List<Object?> get props => [address, city, latitude, longitude, phone];

  String get fullAddress {
    if (city != null) {
      return '$address, $city';
    }
    return address;
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}
