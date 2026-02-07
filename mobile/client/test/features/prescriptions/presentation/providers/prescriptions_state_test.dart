import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/prescriptions/presentation/providers/prescriptions_state.dart';
import 'package:drpharma_client/features/prescriptions/domain/entities/prescription_entity.dart';

void main() {
  group('PrescriptionsState', () {
    final testDate = DateTime(2024, 1, 1);

    PrescriptionEntity createPrescription({
      int id = 1,
      String status = 'pending',
      List<String> imageUrls = const ['https://example.com/image.jpg'],
    }) {
      return PrescriptionEntity(
        id: id,
        status: status,
        imageUrls: imageUrls,
        createdAt: testDate,
      );
    }

    group('construction', () {
      test('should create with required fields', () {
        final prescriptions = [createPrescription()];
        final state = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: prescriptions,
        );

        expect(state.status, equals(PrescriptionsStatus.loaded));
        expect(state.prescriptions, equals(prescriptions));
        expect(state.uploadedPrescription, isNull);
        expect(state.errorMessage, isNull);
      });

      test('should create with all fields', () {
        final prescriptions = [createPrescription(id: 1)];
        final uploaded = createPrescription(id: 2);
        final state = PrescriptionsState(
          status: PrescriptionsStatus.uploaded,
          prescriptions: prescriptions,
          uploadedPrescription: uploaded,
          errorMessage: null,
        );

        expect(state.uploadedPrescription, equals(uploaded));
      });
    });

    group('initial constructor', () {
      test('should set initial state correctly', () {
        const state = PrescriptionsState.initial();

        expect(state.status, equals(PrescriptionsStatus.initial));
        expect(state.prescriptions, isEmpty);
        expect(state.uploadedPrescription, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: [createPrescription()],
        );

        final copy = original.copyWith();

        expect(copy.status, equals(original.status));
        expect(copy.prescriptions, equals(original.prescriptions));
      });

      test('should copy with new status', () {
        const original = PrescriptionsState.initial();

        final copy = original.copyWith(status: PrescriptionsStatus.loading);

        expect(copy.status, equals(PrescriptionsStatus.loading));
      });

      test('should copy with new prescriptions', () {
        const original = PrescriptionsState.initial();
        final newPrescriptions = [
          createPrescription(id: 1),
          createPrescription(id: 2),
        ];

        final copy = original.copyWith(prescriptions: newPrescriptions);

        expect(copy.prescriptions.length, equals(2));
      });

      test('should copy with new uploadedPrescription', () {
        const original = PrescriptionsState.initial();
        final uploaded = createPrescription(id: 99);

        final copy = original.copyWith(uploadedPrescription: uploaded);

        expect(copy.uploadedPrescription, equals(uploaded));
      });

      test('should copy with new errorMessage', () {
        const original = PrescriptionsState.initial();

        final copy = original.copyWith(errorMessage: 'Upload failed');

        expect(copy.errorMessage, equals('Upload failed'));
      });

      test('should clear errorMessage when copying', () {
        final original = PrescriptionsState(
          status: PrescriptionsStatus.error,
          prescriptions: const [],
          errorMessage: 'Old error',
        );

        final copy = original.copyWith(
          status: PrescriptionsStatus.loaded,
        );

        expect(copy.errorMessage, isNull);
      });
    });

    group('equality', () {
      test('two states with same props should be equal', () {
        final prescriptions = [createPrescription()];
        final state1 = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: prescriptions,
        );
        final state2 = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: prescriptions,
        );

        expect(state1, equals(state2));
      });

      test('two states with different statuses should not be equal', () {
        const state1 = PrescriptionsState(
          status: PrescriptionsStatus.loading,
          prescriptions: [],
        );
        const state2 = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: [],
        );

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different prescriptions should not be equal', () {
        final state1 = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: [createPrescription(id: 1)],
        );
        final state2 = PrescriptionsState(
          status: PrescriptionsStatus.loaded,
          prescriptions: [createPrescription(id: 2)],
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final prescriptions = [createPrescription()];
        final uploaded = createPrescription(id: 2);
        final state = PrescriptionsState(
          status: PrescriptionsStatus.uploaded,
          prescriptions: prescriptions,
          uploadedPrescription: uploaded,
          errorMessage: 'test',
        );

        expect(state.props.length, equals(4));
        expect(state.props[0], equals(PrescriptionsStatus.uploaded));
        expect(state.props[1], equals(prescriptions));
        expect(state.props[2], equals(uploaded));
        expect(state.props[3], equals('test'));
      });
    });
  });

  group('PrescriptionsStatus', () {
    test('should have all expected values', () {
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.initial));
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.loading));
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.loaded));
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.uploading));
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.uploaded));
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.error));
      expect(PrescriptionsStatus.values, contains(PrescriptionsStatus.unauthorized));
    });

    test('should have 7 values', () {
      expect(PrescriptionsStatus.values.length, equals(7));
    });
  });

  group('PrescriptionsStatusExtension', () {
    test('isLoading should return true only for loading', () {
      expect(PrescriptionsStatus.loading.isLoading, isTrue);
      expect(PrescriptionsStatus.initial.isLoading, isFalse);
      expect(PrescriptionsStatus.loaded.isLoading, isFalse);
    });

    test('isLoaded should return true only for loaded', () {
      expect(PrescriptionsStatus.loaded.isLoaded, isTrue);
      expect(PrescriptionsStatus.loading.isLoaded, isFalse);
      expect(PrescriptionsStatus.initial.isLoaded, isFalse);
    });

    test('isUploading should return true only for uploading', () {
      expect(PrescriptionsStatus.uploading.isUploading, isTrue);
      expect(PrescriptionsStatus.loading.isUploading, isFalse);
    });

    test('isUploaded should return true only for uploaded', () {
      expect(PrescriptionsStatus.uploaded.isUploaded, isTrue);
      expect(PrescriptionsStatus.uploading.isUploaded, isFalse);
    });

    test('isError should return true only for error', () {
      expect(PrescriptionsStatus.error.isError, isTrue);
      expect(PrescriptionsStatus.loaded.isError, isFalse);
    });

    test('isUnauthorized should return true only for unauthorized', () {
      expect(PrescriptionsStatus.unauthorized.isUnauthorized, isTrue);
      expect(PrescriptionsStatus.error.isUnauthorized, isFalse);
    });
  });
}
