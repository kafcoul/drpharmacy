import 'package:equatable/equatable.dart';

class PharmacyEntity extends Equatable {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isOpen;
  final double? distance; // Distance in km (for nearby pharmacies)
  final String? openingHours;
  final String? description;
  final bool isOnDuty;
  final String? dutyType;
  final String? dutyEndAt;

  const PharmacyEntity({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    required this.status,
    required this.isOpen,
    this.distance,
    this.openingHours,
    this.description,
    this.isOnDuty = false,
    this.dutyType,
    this.dutyEndAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        email,
        latitude,
        longitude,
        status,
        isOpen,
        distance,
        openingHours,
        description,
        isOnDuty,
        dutyType,
        dutyEndAt,
      ];

  /// Helper getters
  String get initials {
    final words = name.split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspendue';
      default:
        return status;
    }
  }

  String get distanceLabel {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }
}
