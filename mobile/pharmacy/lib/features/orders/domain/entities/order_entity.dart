class OrderEntity {
  final int id;
  final String reference;
  final String status;
  final String paymentMode;
  final double totalAmount;
  final String? deliveryAddress;
  final String? customerNotes;
  final String? pharmacyNotes;
  final String? prescriptionImage;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final int? itemsCount;
  final List<OrderItemEntity>? items;
  final double? deliveryFee;
  final double? subtotal;

  const OrderEntity({
    required this.id,
    required this.reference,
    required this.status,
    required this.paymentMode,
    required this.totalAmount,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    this.deliveryAddress,
    this.customerNotes,
    this.pharmacyNotes,
    this.prescriptionImage,
    this.itemsCount,
    this.items,
    this.deliveryFee,
    this.subtotal,
  });

  OrderEntity copyWith({
    int? id,
    String? reference,
    String? status,
    String? paymentMode,
    double? totalAmount,
    String? deliveryAddress,
    String? customerNotes,
    String? pharmacyNotes,
    String? prescriptionImage,
    DateTime? createdAt,
    String? customerName,
    String? customerPhone,
    int? itemsCount,
    List<OrderItemEntity>? items,
    double? deliveryFee,
    double? subtotal,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      paymentMode: paymentMode ?? this.paymentMode,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerNotes: customerNotes ?? this.customerNotes,
      pharmacyNotes: pharmacyNotes ?? this.pharmacyNotes,
      prescriptionImage: prescriptionImage ?? this.prescriptionImage,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

class OrderItemEntity {
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemEntity({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
