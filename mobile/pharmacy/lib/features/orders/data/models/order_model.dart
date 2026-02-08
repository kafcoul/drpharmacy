import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

/// Convertit une valeur dynamique (String ou num) en double
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Convertit une valeur dynamique nullable en double nullable
double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Convertit une valeur dynamique en int
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Convertit une valeur dynamique nullable en int nullable
int? _toIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable()
class OrderModel {
  final int id;
  final String reference;
  final String status;
  @JsonKey(name: 'payment_mode')
  final String paymentMode;
  @JsonKey(name: 'total_amount', fromJson: _toDouble)
  final double totalAmount;
  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;
  @JsonKey(name: 'customer_notes')
  final String? customerNotes;
  @JsonKey(name: 'pharmacy_notes')
  final String? pharmacyNotes;
  @JsonKey(name: 'prescription_image')
  final String? prescriptionImage;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final Map<String, dynamic> customer;
  @JsonKey(name: 'items_count', fromJson: _toIntNullable)
  final int? itemsCount;
  final List<OrderItemModel>? items;
  @JsonKey(name: 'delivery_fee', fromJson: _toDoubleNullable)
  final double? deliveryFee;
  @JsonKey(fromJson: _toDoubleNullable)
  final double? subtotal;

  const OrderModel({
    required this.id,
    required this.reference,
    required this.status,
    required this.paymentMode,
    required this.totalAmount,
    required this.createdAt,
    required this.customer,
    this.deliveryAddress,
    this.customerNotes,
    this.pharmacyNotes,
    this.prescriptionImage,
    this.itemsCount,
    this.items,
    this.deliveryFee,
    this.subtotal,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      reference: reference,
      status: status,
      paymentMode: paymentMode,
      totalAmount: totalAmount,
      createdAt: DateTime.parse(createdAt),
      customerName: customer['name'] ?? 'Inconnu',
      customerPhone: customer['phone'] ?? '',
      deliveryAddress: deliveryAddress,
      customerNotes: customerNotes,
      pharmacyNotes: pharmacyNotes,
      prescriptionImage: prescriptionImage,
      itemsCount: itemsCount,
      items: items?.map((e) => e.toEntity()).toList(),
      deliveryFee: deliveryFee,
      subtotal: subtotal,
    );
  }
}

@JsonSerializable()
class OrderItemModel {
  final String name;
  @JsonKey(fromJson: _toInt)
  final int quantity;
  @JsonKey(name: 'unit_price', fromJson: _toDouble)
  final double unitPrice;
  @JsonKey(name: 'total_price', fromJson: _toDouble)
  final double totalPrice;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}
