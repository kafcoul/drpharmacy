import 'package:json_annotation/json_annotation.dart';

part 'prescription_model.g.dart';

@JsonSerializable()
class PrescriptionModel {
  final int id;
  @JsonKey(name: 'customer_id')
  final int customerId;
  final String status;
  final String? notes;
  final List<String>? images;
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'pharmacy_notes')
  final String? pharmacyNotes;
  @JsonKey(name: 'quote_amount')
  final double? quoteAmount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final Map<String, dynamic>? customer;

  PrescriptionModel({
    required this.id,
    required this.customerId,
    required this.status,
    this.notes,
    this.images,
    this.adminNotes,
    this.pharmacyNotes,
    this.quoteAmount,
    required this.createdAt,
    this.customer,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionModelToJson(this);
}
