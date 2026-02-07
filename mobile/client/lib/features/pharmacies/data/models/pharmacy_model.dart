import '../../domain/entities/pharmacy_entity.dart';

class PharmacyModel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isOpen;
  final double? distance;
  final String? openingHours;
  final String? description;
  final bool isOnDuty;
  final String? dutyType;
  final String? dutyEndAt;

  PharmacyModel({
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

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    // Check if duty_info exists
    final dutyInfo = json['duty_info'] as Map<String, dynamic>?;

    return PharmacyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      status: json['status'] as String? ?? 'active',
      isOpen: json['is_open'] as bool? ?? false,
      distance: _parseDouble(json['distance']),
      openingHours: json['opening_hours'] as String?,
      description: json['description'] as String?,
      isOnDuty: json['is_on_duty'] as bool? ?? false,
      dutyType: dutyInfo?['type'] as String?,
      dutyEndAt: dutyInfo?['end_at'] as String?,
    );
  }

  /// Parse a value that could be a num, String, or null to double
  /// Handles various formats including:
  /// - null -> null
  /// - 5.32 (num) -> 5.32
  /// - "5.32" (String) -> 5.32
  /// - "5.3200000" (String with trailing zeros) -> 5.32
  /// - "" (empty string) -> null
  /// - "null" (string "null") -> null
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    
    if (value is num) {
      final doubleValue = value.toDouble();
      // Reject invalid coordinates (NaN, Infinity)
      if (doubleValue.isNaN || doubleValue.isInfinite) return null;
      return doubleValue;
    }
    
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
      final parsed = double.tryParse(trimmed);
      if (parsed != null && !parsed.isNaN && !parsed.isInfinite) {
        return parsed;
      }
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'is_open': isOpen,
      'distance': distance,
      'opening_hours': openingHours,
      'description': description,
      'is_on_duty': isOnDuty,
      'duty_info': isOnDuty
          ? {
              'type': dutyType,
              'end_at': dutyEndAt,
            }
          : null,
    };
  }

  PharmacyEntity toEntity() {
    return PharmacyEntity(
      id: id,
      name: name,
      address: address,
      phone: phone,
      email: email,
      latitude: latitude,
      longitude: longitude,
      status: status,
      isOpen: isOpen,
      distance: distance,
      openingHours: openingHours,
      description: description,
      isOnDuty: isOnDuty,
      dutyType: dutyType,
      dutyEndAt: dutyEndAt,
    );
  }

  factory PharmacyModel.fromEntity(PharmacyEntity entity) {
    return PharmacyModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      latitude: entity.latitude,
      longitude: entity.longitude,
      status: entity.status,
      isOpen: entity.isOpen,
      distance: entity.distance,
      openingHours: entity.openingHours,
      description: entity.description,
      isOnDuty: entity.isOnDuty,
      dutyType: entity.dutyType,
      dutyEndAt: entity.dutyEndAt,
    );
  }
}
