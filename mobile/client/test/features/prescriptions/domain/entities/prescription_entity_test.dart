import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/prescriptions/domain/entities/prescription_entity.dart';

void main() {
  group('PrescriptionEntity', () {
    PrescriptionEntity createPrescription({
      int id = 1,
      String status = 'pending',
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
        id: id,
        status: status,
        notes: notes,
        imageUrls: imageUrls ?? ['https://example.com/image1.jpg'],
        rejectionReason: rejectionReason,
        quoteAmount: quoteAmount,
        pharmacyNotes: pharmacyNotes,
        createdAt: createdAt ?? DateTime(2024, 1, 1),
        validatedAt: validatedAt,
        orderId: orderId,
        orderReference: orderReference,
        source: source,
      );
    }

    group('constructor', () {
      test('should create with required parameters', () {
        final prescription = createPrescription();

        expect(prescription.id, 1);
        expect(prescription.status, 'pending');
        expect(prescription.imageUrls, isNotEmpty);
        expect(prescription.createdAt, DateTime(2024, 1, 1));
      });

      test('should create with all optional parameters', () {
        final prescription = createPrescription(
          notes: 'Test notes',
          rejectionReason: 'Invalid image',
          quoteAmount: 5000.0,
          pharmacyNotes: 'Pharmacy notes',
          validatedAt: DateTime(2024, 1, 2),
          orderId: 100,
          orderReference: 'ORD-100',
          source: 'checkout',
        );

        expect(prescription.notes, 'Test notes');
        expect(prescription.rejectionReason, 'Invalid image');
        expect(prescription.quoteAmount, 5000.0);
        expect(prescription.pharmacyNotes, 'Pharmacy notes');
        expect(prescription.validatedAt, DateTime(2024, 1, 2));
        expect(prescription.orderId, 100);
        expect(prescription.orderReference, 'ORD-100');
        expect(prescription.source, 'checkout');
      });
    });

    group('isLinkedToOrder', () {
      test('should return true when orderId is not null', () {
        final prescription = createPrescription(orderId: 100);
        expect(prescription.isLinkedToOrder, isTrue);
      });

      test('should return false when orderId is null', () {
        final prescription = createPrescription(orderId: null);
        expect(prescription.isLinkedToOrder, isFalse);
      });
    });

    group('isFromCheckout', () {
      test('should return true when source is checkout', () {
        final prescription = createPrescription(source: 'checkout');
        expect(prescription.isFromCheckout, isTrue);
      });

      test('should return false when source is direct', () {
        final prescription = createPrescription(source: 'direct');
        expect(prescription.isFromCheckout, isFalse);
      });

      test('should return false when source is null', () {
        final prescription = createPrescription(source: null);
        expect(prescription.isFromCheckout, isFalse);
      });
    });

    group('statusLabel', () {
      test('should return "En attente" for pending status', () {
        final prescription = createPrescription(status: 'pending');
        expect(prescription.statusLabel, 'En attente');
      });

      test('should return "En traitement" for processing status', () {
        final prescription = createPrescription(status: 'processing');
        expect(prescription.statusLabel, 'En traitement');
      });

      test('should return "Validée" for validated status', () {
        final prescription = createPrescription(status: 'validated');
        expect(prescription.statusLabel, 'Validée');
      });

      test('should return "Rejetée" for rejected status', () {
        final prescription = createPrescription(status: 'rejected');
        expect(prescription.statusLabel, 'Rejetée');
      });

      test('should return status as-is for unknown status', () {
        final prescription = createPrescription(status: 'unknown_status');
        expect(prescription.statusLabel, 'unknown_status');
      });
    });

    group('copyWith', () {
      test('should copy with new id', () {
        final prescription = createPrescription(id: 1);
        final copied = prescription.copyWith(id: 2);

        expect(copied.id, 2);
        expect(copied.status, prescription.status);
      });

      test('should copy with new status', () {
        final prescription = createPrescription(status: 'pending');
        final copied = prescription.copyWith(status: 'validated');

        expect(copied.status, 'validated');
        expect(copied.id, prescription.id);
      });

      test('should copy with new quoteAmount', () {
        final prescription = createPrescription(quoteAmount: 1000.0);
        final copied = prescription.copyWith(quoteAmount: 2000.0);

        expect(copied.quoteAmount, 2000.0);
      });

      test('should copy with new orderId', () {
        final prescription = createPrescription(orderId: null);
        final copied = prescription.copyWith(orderId: 100);

        expect(copied.orderId, 100);
        expect(copied.isLinkedToOrder, isTrue);
      });

      test('should keep original values when no parameters', () {
        final prescription = createPrescription(
          id: 5,
          status: 'validated',
          notes: 'Original notes',
        );
        final copied = prescription.copyWith();

        expect(copied.id, 5);
        expect(copied.status, 'validated');
        expect(copied.notes, 'Original notes');
      });

      test('should copy with new imageUrls', () {
        final prescription = createPrescription(
          imageUrls: ['https://example.com/old.jpg'],
        );
        final copied = prescription.copyWith(
          imageUrls: ['https://example.com/new.jpg'],
        );

        expect(copied.imageUrls, ['https://example.com/new.jpg']);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final prescription1 = PrescriptionEntity(
          id: 1,
          status: 'pending',
          imageUrls: const ['url1'],
          createdAt: DateTime(2024, 1, 1),
        );
        final prescription2 = PrescriptionEntity(
          id: 1,
          status: 'pending',
          imageUrls: const ['url1'],
          createdAt: DateTime(2024, 1, 1),
        );

        expect(prescription1, equals(prescription2));
      });

      test('should not be equal when id differs', () {
        final prescription1 = createPrescription(id: 1);
        final prescription2 = createPrescription(id: 2);

        expect(prescription1, isNot(equals(prescription2)));
      });

      test('should not be equal when status differs', () {
        final prescription1 = createPrescription(status: 'pending');
        final prescription2 = createPrescription(status: 'validated');

        expect(prescription1, isNot(equals(prescription2)));
      });
    });

    group('status states', () {
      test('should handle all valid status values', () {
        final statuses = ['pending', 'processing', 'validated', 'rejected'];

        for (final status in statuses) {
          final prescription = createPrescription(status: status);
          expect(prescription.status, status);
          expect(prescription.statusLabel, isNotEmpty);
        }
      });
    });

    group('imageUrls', () {
      test('should handle multiple image urls', () {
        final prescription = createPrescription(
          imageUrls: [
            'https://example.com/image1.jpg',
            'https://example.com/image2.jpg',
            'https://example.com/image3.jpg',
          ],
        );

        expect(prescription.imageUrls.length, 3);
      });

      test('should handle empty image urls', () {
        final prescription = createPrescription(imageUrls: []);
        expect(prescription.imageUrls, isEmpty);
      });
    });
  });
}
