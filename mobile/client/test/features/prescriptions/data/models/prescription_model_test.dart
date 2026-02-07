import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/prescriptions/data/models/prescription_model.dart';
import 'package:drpharma_client/features/prescriptions/domain/entities/prescription_entity.dart';

void main() {
  group('PrescriptionModel', () {
    const testJsonPending = {
      'id': 1,
      'status': 'pending',
      'notes': 'Médicaments urgents',
      'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
      'rejection_reason': null,
      'quote_amount': null,
      'pharmacy_notes': null,
      'created_at': '2024-01-15T10:30:00.000Z',
      'validated_at': null,
      'order_id': null,
      'order_reference': null,
      'source': 'direct',
    };

    const testJsonValidated = {
      'id': 2,
      'status': 'validated',
      'notes': null,
      'images': ['https://example.com/img1.jpg'],
      'rejection_reason': null,
      'quote_amount': 15000.0,
      'pharmacy_notes': 'Médicaments en stock',
      'created_at': '2024-01-14T08:00:00.000Z',
      'validated_at': '2024-01-15T14:00:00.000Z',
      'order_id': 123,
      'order_reference': 'ORD-123',
      'source': 'checkout',
    };

    const testJsonRejected = {
      'id': 3,
      'status': 'rejected',
      'notes': 'Pour ma grand-mère',
      'images': ['https://example.com/img1.jpg'],
      'rejection_reason': 'Ordonnance illisible',
      'quote_amount': null,
      'pharmacy_notes': null,
      'created_at': '2024-01-13T09:00:00.000Z',
      'validated_at': null,
      'order_id': null,
      'order_reference': null,
      'source': null,
    };

    group('fromJson', () {
      test('should create model from pending prescription JSON', () {
        // Act
        final model = PrescriptionModel.fromJson(testJsonPending);

        // Assert
        expect(model.id, 1);
        expect(model.status, 'pending');
        expect(model.notes, 'Médicaments urgents');
        expect(model.images.length, 2);
        expect(model.rejectionReason, isNull);
        expect(model.quoteAmount, isNull);
        expect(model.source, 'direct');
      });

      test('should create model from validated prescription JSON', () {
        // Act
        final model = PrescriptionModel.fromJson(testJsonValidated);

        // Assert
        expect(model.id, 2);
        expect(model.status, 'validated');
        expect(model.quoteAmount, 15000.0);
        expect(model.pharmacyNotes, 'Médicaments en stock');
        expect(model.validatedAt, isNotNull);
        expect(model.orderId, 123);
        expect(model.orderReference, 'ORD-123');
        expect(model.source, 'checkout');
      });

      test('should create model from rejected prescription JSON', () {
        // Act
        final model = PrescriptionModel.fromJson(testJsonRejected);

        // Assert
        expect(model.id, 3);
        expect(model.status, 'rejected');
        expect(model.rejectionReason, 'Ordonnance illisible');
      });

      test('should handle images as list of strings', () {
        final json = {
          ...testJsonPending,
          'images': ['img1.jpg', 'img2.jpg', 'img3.jpg'],
        };

        final model = PrescriptionModel.fromJson(json);
        expect(model.images.length, 3);
        expect(model.images[0], 'img1.jpg');
      });

      test('should handle images as list of maps with url', () {
        final json = {
          ...testJsonPending,
          'images': [
            {'id': 1, 'url': 'https://example.com/1.jpg'},
            {'id': 2, 'url': 'https://example.com/2.jpg'},
          ],
        };

        final model = PrescriptionModel.fromJson(json);
        expect(model.images.length, 2);
        expect(model.images[0], 'https://example.com/1.jpg');
      });

      test('should handle empty images list', () {
        final json = {...testJsonPending, 'images': []};

        final model = PrescriptionModel.fromJson(json);
        expect(model.images, isEmpty);
      });

      test('should parse quote_amount as string', () {
        final json = {...testJsonValidated, 'quote_amount': '25000.50'};

        final model = PrescriptionModel.fromJson(json);
        expect(model.quoteAmount, 25000.50);
      });

      test('should parse quote_amount as int', () {
        final json = {...testJsonValidated, 'quote_amount': 25000};

        final model = PrescriptionModel.fromJson(json);
        expect(model.quoteAmount, 25000.0);
      });

      test('should default status to pending if null', () {
        final json = {...testJsonPending, 'status': null};

        final model = PrescriptionModel.fromJson(json);
        expect(model.status, 'pending');
      });
    });

    group('toJson', () {
      test('should convert pending model to JSON correctly', () {
        // Arrange
        const model = PrescriptionModel(
          id: 1,
          status: 'pending',
          notes: 'Test notes',
          images: ['img1.jpg', 'img2.jpg'],
          createdAt: '2024-01-15T10:00:00.000Z',
          source: 'direct',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['status'], 'pending');
        expect(json['notes'], 'Test notes');
        expect(json['images'], ['img1.jpg', 'img2.jpg']);
        expect(json['rejection_reason'], isNull);
        expect(json['source'], 'direct');
      });

      test('should convert validated model to JSON correctly', () {
        // Arrange
        const model = PrescriptionModel(
          id: 2,
          status: 'validated',
          images: ['img.jpg'],
          quoteAmount: 15000.0,
          pharmacyNotes: 'En stock',
          createdAt: '2024-01-14T08:00:00.000Z',
          validatedAt: '2024-01-15T14:00:00.000Z',
          orderId: 100,
          orderReference: 'ORD-100',
          source: 'checkout',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['quote_amount'], 15000.0);
        expect(json['pharmacy_notes'], 'En stock');
        expect(json['validated_at'], '2024-01-15T14:00:00.000Z');
        expect(json['order_id'], 100);
        expect(json['order_reference'], 'ORD-100');
      });
    });

    group('toEntity', () {
      test('should convert pending model to entity', () {
        // Arrange
        final model = PrescriptionModel.fromJson(testJsonPending);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<PrescriptionEntity>());
        expect(entity.id, 1);
        expect(entity.status, 'pending');
        expect(entity.notes, 'Médicaments urgents');
        expect(entity.imageUrls.length, 2);
        expect(entity.isLinkedToOrder, isFalse);
        expect(entity.isFromCheckout, isFalse);
        expect(entity.statusLabel, 'En attente');
      });

      test('should convert validated model to entity', () {
        // Arrange
        final model = PrescriptionModel.fromJson(testJsonValidated);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 2);
        expect(entity.status, 'validated');
        expect(entity.quoteAmount, 15000.0);
        expect(entity.validatedAt, isNotNull);
        expect(entity.validatedAt!.year, 2024);
        expect(entity.validatedAt!.month, 1);
        expect(entity.validatedAt!.day, 15);
        expect(entity.isLinkedToOrder, isTrue);
        expect(entity.isFromCheckout, isTrue);
        expect(entity.statusLabel, 'Validée');
      });

      test('should convert rejected model to entity', () {
        // Arrange
        final model = PrescriptionModel.fromJson(testJsonRejected);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.status, 'rejected');
        expect(entity.rejectionReason, 'Ordonnance illisible');
        expect(entity.statusLabel, 'Rejetée');
      });

      test('should parse createdAt correctly', () {
        // Arrange
        final model = PrescriptionModel.fromJson(testJsonPending);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.createdAt.year, 2024);
        expect(entity.createdAt.month, 1);
        expect(entity.createdAt.day, 15);
        expect(entity.createdAt.hour, 10);
        expect(entity.createdAt.minute, 30);
      });

      test('should handle null validatedAt', () {
        // Arrange
        final model = PrescriptionModel.fromJson(testJsonPending);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.validatedAt, isNull);
      });
    });

    group('constructor', () {
      test('should create model with required fields only', () {
        const model = PrescriptionModel(
          id: 1,
          status: 'pending',
          images: [],
          createdAt: '2024-01-15T10:00:00.000Z',
        );

        expect(model.id, 1);
        expect(model.notes, isNull);
        expect(model.rejectionReason, isNull);
        expect(model.quoteAmount, isNull);
        expect(model.orderId, isNull);
      });

      test('should create model with all fields', () {
        const model = PrescriptionModel(
          id: 1,
          status: 'validated',
          notes: 'Notes',
          images: ['img.jpg'],
          rejectionReason: null,
          quoteAmount: 20000.0,
          pharmacyNotes: 'Ready',
          createdAt: '2024-01-15T10:00:00.000Z',
          validatedAt: '2024-01-16T10:00:00.000Z',
          orderId: 50,
          orderReference: 'ORD-50',
          source: 'checkout',
        );

        expect(model.quoteAmount, 20000.0);
        expect(model.orderId, 50);
        expect(model.source, 'checkout');
      });
    });
  });
}
