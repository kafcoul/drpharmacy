class DutyZoneModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  DutyZoneModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory DutyZoneModel.fromJson(Map<String, dynamic> json) {
    return DutyZoneModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
