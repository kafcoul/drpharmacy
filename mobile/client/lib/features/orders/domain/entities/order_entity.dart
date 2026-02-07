import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';
import 'delivery_address_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  ready,
  delivering,
  delivered,
  cancelled,
  failed;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.delivering:
        return 'En livraison';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.failed:
        return 'Échouée';
    }
  }
}

enum PaymentMode {
  platform,
  onDelivery;

  String get displayName {
    switch (this) {
      case PaymentMode.platform:
        return 'Paiement en ligne';
      case PaymentMode.onDelivery:
        return 'Paiement à la livraison';
    }
  }
}

class OrderEntity extends Equatable {
  final int id;
  final String reference;
  final String? deliveryCode;
  final OrderStatus status;
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final PaymentMode paymentMode;
  final int pharmacyId;
  final String pharmacyName;
  final String? pharmacyPhone;
  final String? pharmacyAddress;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String currency;
  final DeliveryAddressEntity deliveryAddress;
  final String? customerNotes;
  final String? prescriptionImage;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? paidAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const OrderEntity({
    required this.id,
    required this.reference,
    this.deliveryCode,
    required this.status,
    this.paymentStatus = 'pending',
    required this.paymentMode,
    required this.pharmacyId,
    required this.pharmacyName,
    this.pharmacyPhone,
    this.pharmacyAddress,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.currency = 'XOF',
    required this.deliveryAddress,
    this.customerNotes,
    this.prescriptionImage,
    required this.createdAt,
    this.confirmedAt,
    this.paidAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  @override
  List<Object?> get props => [
    id,
    reference,
    status,
    paymentStatus,
    paymentMode,
    pharmacyId,
    items,
    totalAmount,
    createdAt,
  ];

  // Helper methods
  bool get isPaid => paymentStatus == 'paid' || paidAt != null;
  bool get isDelivered => deliveredAt != null;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get canBeCancelled =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get needsPayment =>
      paymentMode == PaymentMode.platform && !isPaid && !isCancelled;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return 'warning';
      case OrderStatus.confirmed:
      case OrderStatus.ready:
        return 'info';
      case OrderStatus.delivering:
        return 'primary';
      case OrderStatus.delivered:
        return 'success';
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return 'error';
    }
  }
}
