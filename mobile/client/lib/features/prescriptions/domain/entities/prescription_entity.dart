import 'package:equatable/equatable.dart';

class PrescriptionEntity extends Equatable {
  final int id;
  final String status; // pending, processing, validated, rejected
  final String? notes;
  final List<String> imageUrls;
  final String? rejectionReason;
  final double? quoteAmount;
  final String? pharmacyNotes;
  final DateTime createdAt;
  final DateTime? validatedAt;
  final int? orderId;
  final String? orderReference;
  final String? source; // 'checkout' ou 'direct'

  const PrescriptionEntity({
    required this.id,
    required this.status,
    this.notes,
    required this.imageUrls,
    this.rejectionReason,
    this.quoteAmount,
    this.pharmacyNotes,
    required this.createdAt,
    this.validatedAt,
    this.orderId,
    this.orderReference,
    this.source,
  });

  /// Vérifie si cette prescription est liée à une commande
  bool get isLinkedToOrder => orderId != null;

  /// Vérifie si cette prescription vient du checkout
  bool get isFromCheckout => source == 'checkout';

  /// Retourne un label de statut plus convivial
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En traitement';
      case 'validated':
        return 'Validée';
      case 'rejected':
        return 'Rejetée';
      default:
        return status;
    }
  }

  PrescriptionEntity copyWith({
    int? id,
    String? status,
    String? notes,
    List<String>? imageUrls,
    String? rejectionReason,
    double? quoteAmount,
    String? pharmacyNotes,
    DateTime? createdAt,
    DateTime? validatedAt,
    int? orderId,
    String? orderReference,
    String? source,
  }) {
    return PrescriptionEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      quoteAmount: quoteAmount ?? this.quoteAmount,
      pharmacyNotes: pharmacyNotes ?? this.pharmacyNotes,
      createdAt: createdAt ?? this.createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
      orderId: orderId ?? this.orderId,
      orderReference: orderReference ?? this.orderReference,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        notes,
        imageUrls,
        rejectionReason,
        quoteAmount,
        pharmacyNotes,
        createdAt,
        validatedAt,
        orderId,
        orderReference,
        source,
      ];
}
