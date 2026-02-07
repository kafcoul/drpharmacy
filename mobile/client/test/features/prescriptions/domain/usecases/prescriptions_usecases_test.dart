import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/get_prescriptions_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/get_prescription_details_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/pay_prescription_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/repositories/prescriptions_repository.dart';
import 'package:drpharma_client/features/prescriptions/domain/entities/prescription_entity.dart';

@GenerateMocks([PrescriptionsRepository])
import 'prescriptions_usecases_test.mocks.dart';

void main() {
  late MockPrescriptionsRepository mockRepository;

  setUp(() {
    mockRepository = MockPrescriptionsRepository();
  });

  // === Test data ===
  final testPrescription = PrescriptionEntity(
    id: 1,
    status: 'pending',
    notes: 'Médicaments urgents',
    imageUrls: ['https://example.com/image1.jpg'],
    createdAt: DateTime(2024, 1, 15),
  );

  final testPrescriptions = [
    testPrescription,
    PrescriptionEntity(
      id: 2,
      status: 'validated',
      notes: null,
      imageUrls: ['https://example.com/image2.jpg'],
      quoteAmount: 15000.0,
      pharmacyNotes: 'Stock disponible',
      createdAt: DateTime(2024, 1, 14),
      validatedAt: DateTime(2024, 1, 15),
    ),
    PrescriptionEntity(
      id: 3,
      status: 'rejected',
      notes: 'Pour ma grand-mère',
      imageUrls: ['https://example.com/image3.jpg'],
      rejectionReason: 'Ordonnance illisible',
      createdAt: DateTime(2024, 1, 13),
    ),
  ];

  group('GetPrescriptionsUseCase', () {
    late GetPrescriptionsUseCase useCase;

    setUp(() {
      useCase = GetPrescriptionsUseCase(mockRepository);
    });

    test('should get prescriptions successfully', () async {
      // Arrange
      when(mockRepository.getPrescriptions())
          .thenAnswer((_) async => Right(testPrescriptions));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (prescriptions) {
          expect(prescriptions.length, 3);
          expect(prescriptions[0].status, 'pending');
          expect(prescriptions[1].status, 'validated');
          expect(prescriptions[2].status, 'rejected');
        },
      );
      verify(mockRepository.getPrescriptions()).called(1);
    });

    test('should return empty list when no prescriptions', () async {
      // Arrange
      when(mockRepository.getPrescriptions())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (prescriptions) => expect(prescriptions, isEmpty),
      );
    });

    test('should return failure when not authenticated', () async {
      // Arrange
      when(mockRepository.getPrescriptions())
          .thenAnswer((_) async => const Left(UnauthorizedFailure()));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when server error', () async {
      // Arrange
      when(mockRepository.getPrescriptions())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('GetPrescriptionDetailsUseCase', () {
    late GetPrescriptionDetailsUseCase useCase;

    setUp(() {
      useCase = GetPrescriptionDetailsUseCase(mockRepository);
    });

    test('should get prescription details successfully', () async {
      // Arrange
      when(mockRepository.getPrescriptionDetails(1))
          .thenAnswer((_) async => Right(testPrescription));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (prescription) {
          expect(prescription.id, 1);
          expect(prescription.status, 'pending');
          expect(prescription.notes, 'Médicaments urgents');
        },
      );
      verify(mockRepository.getPrescriptionDetails(1)).called(1);
    });

    test('should return validation failure for invalid id (0)', () async {
      // Act
      final result = await useCase.call(0);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['id'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for negative id', () async {
      // Act
      final result = await useCase.call(-5);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when prescription not found', () async {
      // Arrange
      when(mockRepository.getPrescriptionDetails(999))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Not found')));

      // Act
      final result = await useCase.call(999);

      // Assert
      expect(result.isLeft(), isTrue);
      verify(mockRepository.getPrescriptionDetails(999)).called(1);
    });
  });

  group('PayPrescriptionUseCase', () {
    late PayPrescriptionUseCase useCase;

    setUp(() {
      useCase = PayPrescriptionUseCase(mockRepository);
    });

    final paymentResult = {
      'success': true,
      'payment_url': 'https://payment.example.com/pay/123',
      'transaction_id': 'TXN-001',
    };

    test('should pay prescription with mobile_money successfully', () async {
      // Arrange
      when(mockRepository.payPrescription(
        prescriptionId: 1,
        paymentMethod: 'mobile_money',
      )).thenAnswer((_) async => Right(paymentResult));

      // Act
      final result = await useCase.call(
        prescriptionId: 1,
        paymentMethod: 'mobile_money',
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (data) {
          expect(data['success'], isTrue);
          expect(data['payment_url'], isNotEmpty);
        },
      );
    });

    test('should pay prescription with card successfully', () async {
      // Arrange
      when(mockRepository.payPrescription(
        prescriptionId: 1,
        paymentMethod: 'card',
      )).thenAnswer((_) async => Right(paymentResult));

      // Act
      final result = await useCase.call(
        prescriptionId: 1,
        paymentMethod: 'card',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should pay prescription with on_delivery successfully', () async {
      // Arrange
      when(mockRepository.payPrescription(
        prescriptionId: 1,
        paymentMethod: 'on_delivery',
      )).thenAnswer((_) async => Right({'success': true}));

      // Act
      final result = await useCase.call(
        prescriptionId: 1,
        paymentMethod: 'on_delivery',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return validation failure for invalid prescription id (0)', () async {
      // Act
      final result = await useCase.call(
        prescriptionId: 0,
        paymentMethod: 'mobile_money',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['prescriptionId'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for negative prescription id', () async {
      // Act
      final result = await useCase.call(
        prescriptionId: -1,
        paymentMethod: 'card',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for invalid payment method', () async {
      // Act
      final result = await useCase.call(
        prescriptionId: 1,
        paymentMethod: 'bitcoin', // Invalid
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['paymentMethod'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for empty payment method', () async {
      // Act
      final result = await useCase.call(
        prescriptionId: 1,
        paymentMethod: '',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when payment fails', () async {
      // Arrange
      when(mockRepository.payPrescription(
        prescriptionId: 1,
        paymentMethod: 'mobile_money',
      )).thenAnswer((_) async => const Left(ServerFailure(message: 'Payment failed')));

      // Act
      final result = await useCase.call(
        prescriptionId: 1,
        paymentMethod: 'mobile_money',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('PrescriptionEntity', () {
    test('should create entity with required fields', () {
      // Arrange & Act
      final prescription = PrescriptionEntity(
        id: 1,
        status: 'pending',
        imageUrls: ['image1.jpg'],
        createdAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(prescription.id, 1);
      expect(prescription.status, 'pending');
      expect(prescription.imageUrls.length, 1);
      expect(prescription.notes, isNull);
      expect(prescription.quoteAmount, isNull);
    });

    test('should create validated prescription with quote', () {
      // Arrange & Act
      final prescription = PrescriptionEntity(
        id: 2,
        status: 'validated',
        imageUrls: ['image1.jpg', 'image2.jpg'],
        quoteAmount: 25000.0,
        pharmacyNotes: 'Médicaments disponibles',
        createdAt: DateTime(2024, 1, 15),
        validatedAt: DateTime(2024, 1, 16),
      );

      // Assert
      expect(prescription.status, 'validated');
      expect(prescription.quoteAmount, 25000.0);
      expect(prescription.validatedAt, isNotNull);
    });

    test('should create rejected prescription with reason', () {
      // Arrange & Act
      final prescription = PrescriptionEntity(
        id: 3,
        status: 'rejected',
        imageUrls: ['image1.jpg'],
        rejectionReason: 'Image floue',
        createdAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(prescription.status, 'rejected');
      expect(prescription.rejectionReason, 'Image floue');
    });

    test('should return correct status labels', () {
      expect(
        PrescriptionEntity(
          id: 1,
          status: 'pending',
          imageUrls: [],
          createdAt: DateTime.now(),
        ).statusLabel,
        'En attente',
      );
      
      expect(
        PrescriptionEntity(
          id: 1,
          status: 'processing',
          imageUrls: [],
          createdAt: DateTime.now(),
        ).statusLabel,
        'En traitement',
      );
      
      expect(
        PrescriptionEntity(
          id: 1,
          status: 'validated',
          imageUrls: [],
          createdAt: DateTime.now(),
        ).statusLabel,
        'Validée',
      );
      
      expect(
        PrescriptionEntity(
          id: 1,
          status: 'rejected',
          imageUrls: [],
          createdAt: DateTime.now(),
        ).statusLabel,
        'Rejetée',
      );
    });

    test('should return unknown status as is', () {
      expect(
        PrescriptionEntity(
          id: 1,
          status: 'unknown_status',
          imageUrls: [],
          createdAt: DateTime.now(),
        ).statusLabel,
        'unknown_status',
      );
    });

    test('should detect linked order', () {
      final withOrder = PrescriptionEntity(
        id: 1,
        status: 'validated',
        imageUrls: [],
        createdAt: DateTime.now(),
        orderId: 123,
      );
      
      final withoutOrder = PrescriptionEntity(
        id: 2,
        status: 'pending',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      expect(withOrder.isLinkedToOrder, isTrue);
      expect(withoutOrder.isLinkedToOrder, isFalse);
    });

    test('should detect checkout source', () {
      final fromCheckout = PrescriptionEntity(
        id: 1,
        status: 'pending',
        imageUrls: [],
        createdAt: DateTime.now(),
        source: 'checkout',
      );
      
      final direct = PrescriptionEntity(
        id: 2,
        status: 'pending',
        imageUrls: [],
        createdAt: DateTime.now(),
        source: 'direct',
      );

      final noSource = PrescriptionEntity(
        id: 3,
        status: 'pending',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      expect(fromCheckout.isFromCheckout, isTrue);
      expect(direct.isFromCheckout, isFalse);
      expect(noSource.isFromCheckout, isFalse);
    });

    test('should support equality', () {
      final p1 = PrescriptionEntity(
        id: 1,
        status: 'pending',
        imageUrls: ['img.jpg'],
        createdAt: DateTime(2024, 1, 15),
      );
      
      final p2 = PrescriptionEntity(
        id: 1,
        status: 'pending',
        imageUrls: ['img.jpg'],
        createdAt: DateTime(2024, 1, 15),
      );
      
      final p3 = PrescriptionEntity(
        id: 2,
        status: 'pending',
        imageUrls: ['img.jpg'],
        createdAt: DateTime(2024, 1, 15),
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });

    test('should copyWith correctly', () {
      final original = PrescriptionEntity(
        id: 1,
        status: 'pending',
        imageUrls: ['img.jpg'],
        createdAt: DateTime(2024, 1, 15),
      );
      
      final updated = original.copyWith(
        status: 'validated',
        quoteAmount: 15000.0,
      );

      expect(updated.id, 1); // unchanged
      expect(updated.status, 'validated'); // changed
      expect(updated.quoteAmount, 15000.0); // added
      expect(updated.imageUrls, ['img.jpg']); // unchanged
    });

    test('should copyWith all fields', () {
      final original = PrescriptionEntity(
        id: 1,
        status: 'pending',
        imageUrls: ['img.jpg'],
        createdAt: DateTime(2024, 1, 15),
      );
      
      final updated = original.copyWith(
        id: 2,
        status: 'rejected',
        notes: 'Note',
        imageUrls: ['new.jpg'],
        rejectionReason: 'Raison',
        pharmacyNotes: 'Pharmacy note',
        validatedAt: DateTime(2024, 1, 20),
        orderId: 100,
        orderReference: 'REF-100',
        source: 'checkout',
      );

      expect(updated.id, 2);
      expect(updated.status, 'rejected');
      expect(updated.notes, 'Note');
      expect(updated.rejectionReason, 'Raison');
      expect(updated.orderId, 100);
      expect(updated.source, 'checkout');
    });
  });
}
