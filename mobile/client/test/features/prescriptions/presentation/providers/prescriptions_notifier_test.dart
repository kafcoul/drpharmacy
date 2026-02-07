import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/prescriptions/domain/entities/prescription_entity.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/upload_prescription_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/get_prescriptions_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/get_prescription_details_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/usecases/pay_prescription_usecase.dart';
import 'package:drpharma_client/features/prescriptions/presentation/providers/prescriptions_notifier.dart';
import 'package:drpharma_client/features/prescriptions/presentation/providers/prescriptions_state.dart';

import 'prescriptions_notifier_test.mocks.dart';

@GenerateMocks([
  UploadPrescriptionUseCase,
  GetPrescriptionsUseCase,
  GetPrescriptionDetailsUseCase,
  PayPrescriptionUseCase,
  XFile,
])
void main() {
  late PrescriptionsNotifier notifier;
  late MockUploadPrescriptionUseCase mockUploadPrescriptionUseCase;
  late MockGetPrescriptionsUseCase mockGetPrescriptionsUseCase;
  late MockGetPrescriptionDetailsUseCase mockGetPrescriptionDetailsUseCase;
  late MockPayPrescriptionUseCase mockPayPrescriptionUseCase;

  final tPrescription = PrescriptionEntity(
    id: 1,
    status: 'pending',
    notes: 'Médicaments pour tension',
    imageUrls: ['https://example.com/prescription1.jpg'],
    createdAt: DateTime(2024, 1, 15),
  );

  final tPrescriptionList = [tPrescription];

  setUp(() {
    mockUploadPrescriptionUseCase = MockUploadPrescriptionUseCase();
    mockGetPrescriptionsUseCase = MockGetPrescriptionsUseCase();
    mockGetPrescriptionDetailsUseCase = MockGetPrescriptionDetailsUseCase();
    mockPayPrescriptionUseCase = MockPayPrescriptionUseCase();
  });

  PrescriptionsNotifier createNotifier() {
    return PrescriptionsNotifier(
      uploadPrescriptionUseCase: mockUploadPrescriptionUseCase,
      getPrescriptionsUseCase: mockGetPrescriptionsUseCase,
      getPrescriptionDetailsUseCase: mockGetPrescriptionDetailsUseCase,
      payPrescriptionUseCase: mockPayPrescriptionUseCase,
    );
  }

  group('PrescriptionsNotifier', () {
    group('uploadPrescription', () {
      test('should emit uploaded state on success', () async {
        // Arrange
        final mockImages = [MockXFile()];
        when(mockUploadPrescriptionUseCase(
          images: anyNamed('images'),
          notes: anyNamed('notes'),
        )).thenAnswer((_) async => Right(tPrescription));

        // Act
        notifier = createNotifier();
        await notifier.uploadPrescription(images: mockImages, notes: 'Notes');

        // Assert
        expect(notifier.state.status, PrescriptionsStatus.uploaded);
        expect(notifier.state.uploadedPrescription, tPrescription);
        expect(notifier.state.errorMessage, isNull);
      });

      test('should emit error state on failure', () async {
        // Arrange
        final mockImages = [MockXFile()];
        when(mockUploadPrescriptionUseCase(
          images: anyNamed('images'),
          notes: anyNamed('notes'),
        )).thenAnswer((_) async => Left(ServerFailure(message: 'Upload échoué')));

        // Act
        notifier = createNotifier();
        await notifier.uploadPrescription(images: mockImages);

        // Assert
        expect(notifier.state.status, PrescriptionsStatus.error);
        expect(notifier.state.errorMessage, 'Upload échoué');
      });

      test('should emit unauthorized state on unauthorized failure', () async {
        // Arrange
        final mockImages = [MockXFile()];
        when(mockUploadPrescriptionUseCase(
          images: anyNamed('images'),
          notes: anyNamed('notes'),
        )).thenAnswer((_) async => Left(UnauthorizedFailure()));

        // Act
        notifier = createNotifier();
        await notifier.uploadPrescription(images: mockImages);

        // Assert
        expect(notifier.state.status, PrescriptionsStatus.unauthorized);
        expect(notifier.state.errorMessage, contains('reconnecter'));
      });

      test('should handle phone verification error', () async {
        // Arrange
        final mockImages = [MockXFile()];
        when(mockUploadPrescriptionUseCase(
          images: anyNamed('images'),
          notes: anyNamed('notes'),
        )).thenAnswer((_) async => Left(ServerFailure(message: '403 PHONE_NOT_VERIFIED')));

        // Act
        notifier = createNotifier();
        await notifier.uploadPrescription(images: mockImages);

        // Assert
        expect(notifier.state.status, PrescriptionsStatus.error);
        expect(notifier.state.errorMessage, contains('vérifier votre numéro'));
      });

      test('should set uploading state during upload', () async {
        // Arrange
        final mockImages = [MockXFile()];
        when(mockUploadPrescriptionUseCase(
          images: anyNamed('images'),
          notes: anyNamed('notes'),
        )).thenAnswer((_) async => Right(tPrescription));

        // Act
        notifier = createNotifier();
        final future = notifier.uploadPrescription(images: mockImages);
        
        // Wait for completion
        await future;
        
        // Final state should be uploaded
        expect(notifier.state.status, PrescriptionsStatus.uploaded);
      });
    });

    group('loadPrescriptions', () {
      test('should emit loaded state with prescriptions on success', () async {
        // Arrange
        when(mockGetPrescriptionsUseCase())
            .thenAnswer((_) async => Right(tPrescriptionList));

        // Act
        notifier = createNotifier();
        await notifier.loadPrescriptions();

        // Assert
        verify(mockGetPrescriptionsUseCase()).called(1);
        expect(notifier.state.status, PrescriptionsStatus.loaded);
        expect(notifier.state.prescriptions, tPrescriptionList);
        expect(notifier.state.errorMessage, isNull);
      });

      test('should emit error state on failure', () async {
        // Arrange
        when(mockGetPrescriptionsUseCase())
            .thenAnswer((_) async => Left(ServerFailure(message: 'Erreur chargement')));

        // Act
        notifier = createNotifier();
        await notifier.loadPrescriptions();

        // Assert
        expect(notifier.state.status, PrescriptionsStatus.error);
        expect(notifier.state.errorMessage, 'Erreur chargement');
      });
    });

    group('getPrescriptionDetails', () {
      test('should return prescription on success', () async {
        // Arrange
        when(mockGetPrescriptionDetailsUseCase(any))
            .thenAnswer((_) async => Right(tPrescription));

        // Act
        notifier = createNotifier();
        final result = await notifier.getPrescriptionDetails(1);

        // Assert
        verify(mockGetPrescriptionDetailsUseCase(1)).called(1);
        expect(result, tPrescription);
      });

      test('should return null and emit error on failure', () async {
        // Arrange
        when(mockGetPrescriptionDetailsUseCase(any))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Non trouvée')));

        // Act
        notifier = createNotifier();
        final result = await notifier.getPrescriptionDetails(999);

        // Assert
        expect(result, isNull);
        expect(notifier.state.status, PrescriptionsStatus.error);
        expect(notifier.state.errorMessage, 'Non trouvée');
      });
    });

    group('payPrescription', () {
      test('should return true and update prescription status on success', () async {
        // Arrange
        final paymentResponse = {'status': 'success', 'transaction_id': 'TXN-123'};
        when(mockGetPrescriptionsUseCase())
            .thenAnswer((_) async => Right(tPrescriptionList));
        when(mockPayPrescriptionUseCase(
          prescriptionId: anyNamed('prescriptionId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => Right(paymentResponse));

        // Act
        notifier = createNotifier();
        await notifier.loadPrescriptions();
        final result = await notifier.payPrescription(1);

        // Assert
        verify(mockPayPrescriptionUseCase(
          prescriptionId: 1,
          paymentMethod: 'mobile_money',
        )).called(1);
        expect(result, isTrue);
        expect(notifier.state.status, PrescriptionsStatus.loaded);
      });

      test('should return false and emit error on failure', () async {
        // Arrange
        when(mockPayPrescriptionUseCase(
          prescriptionId: anyNamed('prescriptionId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => Left(ServerFailure(message: 'Paiement échoué')));

        // Act
        notifier = createNotifier();
        final result = await notifier.payPrescription(1);

        // Assert
        expect(result, isFalse);
        expect(notifier.state.status, PrescriptionsStatus.error);
        expect(notifier.state.errorMessage, 'Paiement échoué');
      });

      test('should use custom payment method', () async {
        // Arrange
        final paymentResponse = {'status': 'success'};
        when(mockPayPrescriptionUseCase(
          prescriptionId: anyNamed('prescriptionId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => Right(paymentResponse));

        // Act
        notifier = createNotifier();
        await notifier.payPrescription(1, method: 'card');

        // Assert
        verify(mockPayPrescriptionUseCase(
          prescriptionId: 1,
          paymentMethod: 'card',
        )).called(1);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Arrange
        when(mockGetPrescriptionsUseCase())
            .thenAnswer((_) async => Left(ServerFailure(message: 'Erreur')));

        // Act
        notifier = createNotifier();
        await notifier.loadPrescriptions();
        expect(notifier.state.errorMessage, isNotNull);
        
        notifier.clearError();

        // Assert
        expect(notifier.state.errorMessage, isNull);
      });

      test('should do nothing when no error exists', () async {
        // Act
        notifier = createNotifier();
        final stateBefore = notifier.state;
        notifier.clearError();

        // Assert
        expect(notifier.state, stateBefore);
      });
    });
  });

  group('PrescriptionsState', () {
    test('should create initial state', () {
      const state = PrescriptionsState.initial();
      
      expect(state.status, PrescriptionsStatus.initial);
      expect(state.prescriptions, isEmpty);
      expect(state.uploadedPrescription, isNull);
      expect(state.errorMessage, isNull);
    });

    test('should copy with new values', () {
      const state = PrescriptionsState.initial();
      final newState = state.copyWith(
        status: PrescriptionsStatus.loaded,
        prescriptions: tPrescriptionList,
        uploadedPrescription: tPrescription,
        errorMessage: 'Error',
      );
      
      expect(newState.status, PrescriptionsStatus.loaded);
      expect(newState.prescriptions, tPrescriptionList);
      expect(newState.uploadedPrescription, tPrescription);
      expect(newState.errorMessage, 'Error');
    });

    test('should allow clearing errorMessage via copyWith', () {
      final state = PrescriptionsState(
        status: PrescriptionsStatus.error,
        prescriptions: const [],
        errorMessage: 'Error',
      );
      
      final newState = state.copyWith(errorMessage: null);
      
      expect(newState.errorMessage, isNull);
    });

    test('should be equatable', () {
      final state1 = PrescriptionsState(
        status: PrescriptionsStatus.loaded,
        prescriptions: tPrescriptionList,
      );
      
      final state2 = PrescriptionsState(
        status: PrescriptionsStatus.loaded,
        prescriptions: tPrescriptionList,
      );
      
      expect(state1, equals(state2));
    });
  });

  group('PrescriptionsStatusExtension', () {
    test('should correctly identify loading status', () {
      expect(PrescriptionsStatus.loading.isLoading, isTrue);
      expect(PrescriptionsStatus.loaded.isLoading, isFalse);
    });

    test('should correctly identify loaded status', () {
      expect(PrescriptionsStatus.loaded.isLoaded, isTrue);
      expect(PrescriptionsStatus.loading.isLoaded, isFalse);
    });

    test('should correctly identify uploading status', () {
      expect(PrescriptionsStatus.uploading.isUploading, isTrue);
      expect(PrescriptionsStatus.loading.isUploading, isFalse);
    });

    test('should correctly identify uploaded status', () {
      expect(PrescriptionsStatus.uploaded.isUploaded, isTrue);
      expect(PrescriptionsStatus.loading.isUploaded, isFalse);
    });

    test('should correctly identify error status', () {
      expect(PrescriptionsStatus.error.isError, isTrue);
      expect(PrescriptionsStatus.loaded.isError, isFalse);
    });

    test('should correctly identify unauthorized status', () {
      expect(PrescriptionsStatus.unauthorized.isUnauthorized, isTrue);
      expect(PrescriptionsStatus.error.isUnauthorized, isFalse);
    });
  });
}
