// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrescriptionModel _$PrescriptionModelFromJson(Map<String, dynamic> json) =>
    PrescriptionModel(
      id: (json['id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      adminNotes: json['admin_notes'] as String?,
      pharmacyNotes: json['pharmacy_notes'] as String?,
      quoteAmount: (json['quote_amount'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
      customer: json['customer'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PrescriptionModelToJson(PrescriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'status': instance.status,
      'notes': instance.notes,
      'images': instance.images,
      'admin_notes': instance.adminNotes,
      'pharmacy_notes': instance.pharmacyNotes,
      'quote_amount': instance.quoteAmount,
      'created_at': instance.createdAt,
      'customer': instance.customer,
    };
