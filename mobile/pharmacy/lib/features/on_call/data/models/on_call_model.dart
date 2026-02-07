class OnCallModel {
  final int id;
  final int pharmacyId;
  final int dutyZoneId;
  final DateTime startAt;
  final DateTime endAt;
  final String type;
  final bool isActive;

  OnCallModel({
    required this.id,
    required this.pharmacyId,
    required this.dutyZoneId,
    required this.startAt,
    required this.endAt,
    required this.type,
    required this.isActive,
  });

  factory OnCallModel.fromJson(Map<String, dynamic> json) {
    return OnCallModel(
      id: json['id'],
      pharmacyId: json['pharmacy_id'],
      dutyZoneId: json['duty_zone_id'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      type: json['type'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacy_id': pharmacyId,
      'duty_zone_id': dutyZoneId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'type': type,
      'is_active': isActive,
    };
  }
}
