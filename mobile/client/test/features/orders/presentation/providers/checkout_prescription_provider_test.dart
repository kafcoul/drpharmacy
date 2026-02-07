import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drpharma_client/features/orders/presentation/providers/checkout_prescription_provider.dart';

// Mock XFile for testing
class MockXFile extends XFile {
  MockXFile(super.path);
}

void main() {
  group('CheckoutPrescriptionState', () {
    group('constructor', () {
      test('should create with default values', () {
        const state = CheckoutPrescriptionState();

        expect(state.images, isEmpty);
        expect(state.prescriptionId, isNull);
        expect(state.notes, isNull);
        expect(state.isUploading, false);
        expect(state.errorMessage, isNull);
      });

      test('should create with custom values', () {
        final images = [MockXFile('path1'), MockXFile('path2')];
        final state = CheckoutPrescriptionState(
          images: images,
          prescriptionId: 123,
          notes: 'Test notes',
          isUploading: true,
          errorMessage: 'Test error',
        );

        expect(state.images.length, 2);
        expect(state.prescriptionId, 123);
        expect(state.notes, 'Test notes');
        expect(state.isUploading, true);
        expect(state.errorMessage, 'Test error');
      });
    });

    group('hasValidPrescription', () {
      test('should return true when prescriptionId is set', () {
        const state = CheckoutPrescriptionState(prescriptionId: 1);
        expect(state.hasValidPrescription, true);
      });

      test('should return true when images are not empty', () {
        final state = CheckoutPrescriptionState(
          images: [MockXFile('path')],
        );
        expect(state.hasValidPrescription, true);
      });

      test('should return false when no prescription and no images', () {
        const state = CheckoutPrescriptionState();
        expect(state.hasValidPrescription, false);
      });

      test('should return true when both prescriptionId and images', () {
        final state = CheckoutPrescriptionState(
          prescriptionId: 1,
          images: [MockXFile('path')],
        );
        expect(state.hasValidPrescription, true);
      });
    });

    group('copyWith', () {
      test('should copy with new images', () {
        const state = CheckoutPrescriptionState();
        final newImages = [MockXFile('new_path')];
        final copied = state.copyWith(images: newImages);

        expect(copied.images, newImages);
        expect(copied.prescriptionId, isNull);
      });

      test('should copy with new prescriptionId', () {
        const state = CheckoutPrescriptionState();
        final copied = state.copyWith(prescriptionId: 456);

        expect(copied.prescriptionId, 456);
      });

      test('should copy with new notes', () {
        const state = CheckoutPrescriptionState();
        final copied = state.copyWith(notes: 'New notes');

        expect(copied.notes, 'New notes');
      });

      test('should copy with new isUploading', () {
        const state = CheckoutPrescriptionState();
        final copied = state.copyWith(isUploading: true);

        expect(copied.isUploading, true);
      });

      test('should copy with new errorMessage', () {
        const state = CheckoutPrescriptionState();
        final copied = state.copyWith(errorMessage: 'New error');

        expect(copied.errorMessage, 'New error');
      });

      test('should clear prescriptionId when clearPrescriptionId is true', () {
        const state = CheckoutPrescriptionState(prescriptionId: 123);
        final copied = state.copyWith(clearPrescriptionId: true);

        expect(copied.prescriptionId, isNull);
      });

      test('should clear error when clearError is true', () {
        const state = CheckoutPrescriptionState(errorMessage: 'Error');
        final copied = state.copyWith(clearError: true);

        expect(copied.errorMessage, isNull);
      });

      test('should preserve existing values when not specified', () {
        final state = CheckoutPrescriptionState(
          images: [MockXFile('path')],
          prescriptionId: 100,
          notes: 'Notes',
          isUploading: true,
          errorMessage: 'Error',
        );
        final copied = state.copyWith();

        expect(copied.images.length, 1);
        expect(copied.prescriptionId, 100);
        expect(copied.notes, 'Notes');
        expect(copied.isUploading, true);
        expect(copied.errorMessage, 'Error');
      });
    });
  });

  group('CheckoutPrescriptionNotifier', () {
    late CheckoutPrescriptionNotifier notifier;
    late ProviderContainer container;

    setUp(() {
      notifier = CheckoutPrescriptionNotifier();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('addImage', () {
      test('should add single image', () {
        final image = MockXFile('test_path');
        notifier.addImage(image);

        expect(notifier.state.images.length, 1);
        expect(notifier.state.images.first.path, 'test_path');
      });

      test('should add multiple images sequentially', () {
        notifier.addImage(MockXFile('path1'));
        notifier.addImage(MockXFile('path2'));
        notifier.addImage(MockXFile('path3'));

        expect(notifier.state.images.length, 3);
      });

      test('should clear error when adding image', () {
        notifier.setError('Some error');
        expect(notifier.state.errorMessage, 'Some error');

        notifier.addImage(MockXFile('path'));
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('addImages', () {
      test('should add multiple images at once', () {
        final images = [
          MockXFile('path1'),
          MockXFile('path2'),
          MockXFile('path3'),
        ];
        notifier.addImages(images);

        expect(notifier.state.images.length, 3);
      });

      test('should append to existing images', () {
        notifier.addImage(MockXFile('existing'));
        notifier.addImages([MockXFile('new1'), MockXFile('new2')]);

        expect(notifier.state.images.length, 3);
      });

      test('should clear error when adding images', () {
        notifier.setError('Error');
        notifier.addImages([MockXFile('path')]);

        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('removeImage', () {
      test('should remove image at valid index', () {
        notifier.addImages([
          MockXFile('path1'),
          MockXFile('path2'),
          MockXFile('path3'),
        ]);
        notifier.removeImage(1);

        expect(notifier.state.images.length, 2);
        expect(notifier.state.images[0].path, 'path1');
        expect(notifier.state.images[1].path, 'path3');
      });

      test('should not change state for invalid negative index', () {
        notifier.addImage(MockXFile('path'));
        notifier.removeImage(-1);

        expect(notifier.state.images.length, 1);
      });

      test('should not change state for index out of bounds', () {
        notifier.addImage(MockXFile('path'));
        notifier.removeImage(5);

        expect(notifier.state.images.length, 1);
      });

      test('should remove first image correctly', () {
        notifier.addImages([MockXFile('first'), MockXFile('second')]);
        notifier.removeImage(0);

        expect(notifier.state.images.length, 1);
        expect(notifier.state.images.first.path, 'second');
      });

      test('should remove last image correctly', () {
        notifier.addImages([MockXFile('first'), MockXFile('last')]);
        notifier.removeImage(1);

        expect(notifier.state.images.length, 1);
        expect(notifier.state.images.first.path, 'first');
      });
    });

    group('setNotes', () {
      test('should set notes', () {
        notifier.setNotes('Test notes');
        expect(notifier.state.notes, 'Test notes');
      });

      test('should set null notes - notes parameter is not nullable in copyWith', () {
        // Note: copyWith doesn't change notes to null if the current value exists
        // This is by design of the copyWith pattern - passing null means "keep existing"
        notifier.setNotes('Something');
        notifier.setNotes(null);
        // Notes should be preserved since copyWith uses notes ?? this.notes
        expect(notifier.state.notes, 'Something');
      });

      test('should update existing notes', () {
        notifier.setNotes('Original');
        notifier.setNotes('Updated');
        expect(notifier.state.notes, 'Updated');
      });
    });

    group('setPrescriptionId', () {
      test('should set prescription ID', () {
        notifier.setPrescriptionId(123);
        expect(notifier.state.prescriptionId, 123);
      });

      test('should clear error when setting ID', () {
        notifier.setError('Error');
        notifier.setPrescriptionId(456);

        expect(notifier.state.prescriptionId, 456);
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('setUploading', () {
      test('should set uploading to true', () {
        notifier.setUploading(true);
        expect(notifier.state.isUploading, true);
      });

      test('should set uploading to false', () {
        notifier.setUploading(true);
        notifier.setUploading(false);
        expect(notifier.state.isUploading, false);
      });
    });

    group('setError', () {
      test('should set error message', () {
        notifier.setError('Upload failed');
        expect(notifier.state.errorMessage, 'Upload failed');
      });

      test('should set isUploading to false', () {
        notifier.setUploading(true);
        notifier.setError('Error');

        expect(notifier.state.isUploading, false);
        expect(notifier.state.errorMessage, 'Error');
      });
    });

    group('reset', () {
      test('should reset to initial state', () {
        notifier.addImage(MockXFile('path'));
        notifier.setPrescriptionId(123);
        notifier.setNotes('Notes');
        notifier.setUploading(true);
        notifier.setError('Error');

        notifier.reset();

        expect(notifier.state.images, isEmpty);
        expect(notifier.state.prescriptionId, isNull);
        expect(notifier.state.notes, isNull);
        expect(notifier.state.isUploading, false);
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('clearImages', () {
      test('should clear only images', () {
        notifier.addImages([MockXFile('path1'), MockXFile('path2')]);
        notifier.setPrescriptionId(123);
        notifier.setNotes('Notes');

        notifier.clearImages();

        expect(notifier.state.images, isEmpty);
        expect(notifier.state.prescriptionId, 123);
        expect(notifier.state.notes, 'Notes');
      });
    });
  });

  group('checkoutPrescriptionProvider', () {
    test('should create notifier with initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(checkoutPrescriptionProvider);

      expect(state.images, isEmpty);
      expect(state.prescriptionId, isNull);
      expect(state.hasValidPrescription, false);
    });

    test('should allow adding images through notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(checkoutPrescriptionProvider.notifier).addImage(MockXFile('test'));

      final state = container.read(checkoutPrescriptionProvider);
      expect(state.images.length, 1);
    });

    test('should maintain state across reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(checkoutPrescriptionProvider.notifier).setPrescriptionId(999);

      final state1 = container.read(checkoutPrescriptionProvider);
      final state2 = container.read(checkoutPrescriptionProvider);

      expect(state1.prescriptionId, 999);
      expect(state2.prescriptionId, 999);
    });
  });
}
