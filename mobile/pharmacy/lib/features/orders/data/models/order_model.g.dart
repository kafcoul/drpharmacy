// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num).toInt(),
  reference: json['reference'] as String,
  status: json['status'] as String,
  paymentMode: json['payment_mode'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  createdAt: json['created_at'] as String,
  customer: json['customer'] as Map<String, dynamic>,
  deliveryAddress: json['delivery_address'] as String?,
  customerNotes: json['customer_notes'] as String?,
  pharmacyNotes: json['pharmacy_notes'] as String?,
  prescriptionImage: json['prescription_image'] as String?,
  itemsCount: (json['items_count'] as num?)?.toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
  subtotal: (json['subtotal'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'status': instance.status,
      'payment_mode': instance.paymentMode,
      'total_amount': instance.totalAmount,
      'delivery_address': instance.deliveryAddress,
      'customer_notes': instance.customerNotes,
      'pharmacy_notes': instance.pharmacyNotes,
      'prescription_image': instance.prescriptionImage,
      'created_at': instance.createdAt,
      'customer': instance.customer,
      'items_count': instance.itemsCount,
      'items': instance.items,
      'delivery_fee': instance.deliveryFee,
      'subtotal': instance.subtotal,
    };

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
    };
