import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/presentation/providers/delivery_fee_provider.dart';

void main() {
  group('DeliveryFeeState', () {
    group('constructor', () {
      test('should create with default values', () {
        const state = DeliveryFeeState();
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, isNull);
        expect(state.distanceKm, isNull);
        expect(state.error, isNull);
      });

      test('should create with custom values', () {
        const state = DeliveryFeeState(
          isLoading: true,
          estimatedFee: 2500.0,
          distanceKm: 5.5,
          error: 'Some error',
        );
        
        expect(state.isLoading, true);
        expect(state.estimatedFee, 2500.0);
        expect(state.distanceKm, 5.5);
        expect(state.error, 'Some error');
      });

      test('should handle only isLoading', () {
        const state = DeliveryFeeState(isLoading: true);
        
        expect(state.isLoading, true);
        expect(state.estimatedFee, isNull);
        expect(state.distanceKm, isNull);
        expect(state.error, isNull);
      });

      test('should handle only estimatedFee', () {
        const state = DeliveryFeeState(estimatedFee: 1000.0);
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, 1000.0);
        expect(state.distanceKm, isNull);
        expect(state.error, isNull);
      });

      test('should handle only distanceKm', () {
        const state = DeliveryFeeState(distanceKm: 10.0);
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, isNull);
        expect(state.distanceKm, 10.0);
        expect(state.error, isNull);
      });

      test('should handle only error', () {
        const state = DeliveryFeeState(error: 'Error message');
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, isNull);
        expect(state.distanceKm, isNull);
        expect(state.error, 'Error message');
      });
    });

    group('initial', () {
      test('should create initial state with all null/false values', () {
        const state = DeliveryFeeState.initial();
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, isNull);
        expect(state.distanceKm, isNull);
        expect(state.error, isNull);
      });
    });

    group('copyWith', () {
      test('should copy with no changes (except error which resets to null)', () {
        const original = DeliveryFeeState(
          isLoading: true,
          estimatedFee: 1500.0,
          distanceKm: 3.0,
          error: 'original error',
        );
        
        final copied = original.copyWith();
        
        expect(copied.isLoading, true);
        expect(copied.estimatedFee, 1500.0);
        expect(copied.distanceKm, 3.0);
        // Note: error is reset to null when not explicitly passed
        expect(copied.error, isNull);
      });

      test('should copy with isLoading change', () {
        const original = DeliveryFeeState(isLoading: false);
        final copied = original.copyWith(isLoading: true);
        
        expect(copied.isLoading, true);
      });

      test('should copy with estimatedFee change', () {
        const original = DeliveryFeeState(estimatedFee: 1000.0);
        final copied = original.copyWith(estimatedFee: 2000.0);
        
        expect(copied.estimatedFee, 2000.0);
      });

      test('should copy with distanceKm change', () {
        const original = DeliveryFeeState(distanceKm: 5.0);
        final copied = original.copyWith(distanceKm: 10.0);
        
        expect(copied.distanceKm, 10.0);
      });

      test('should copy with error change', () {
        const original = DeliveryFeeState(error: 'old error');
        final copied = original.copyWith(error: 'new error');
        
        expect(copied.error, 'new error');
      });

      test('should copy with clearEstimate true', () {
        const original = DeliveryFeeState(
          estimatedFee: 1500.0,
          distanceKm: 5.0,
        );
        final copied = original.copyWith(clearEstimate: true);
        
        expect(copied.estimatedFee, isNull);
        expect(copied.distanceKm, isNull);
      });

      test('should keep values when clearEstimate is false', () {
        const original = DeliveryFeeState(
          estimatedFee: 1500.0,
          distanceKm: 5.0,
        );
        final copied = original.copyWith(clearEstimate: false);
        
        expect(copied.estimatedFee, 1500.0);
        expect(copied.distanceKm, 5.0);
      });

      test('should clear error when setting new error to null', () {
        const original = DeliveryFeeState(error: 'some error');
        final copied = original.copyWith(error: null);
        
        expect(copied.error, isNull);
      });

      test('should handle all changes at once', () {
        const original = DeliveryFeeState.initial();
        final copied = original.copyWith(
          isLoading: true,
          estimatedFee: 3000.0,
          distanceKm: 7.5,
          error: 'test error',
        );
        
        expect(copied.isLoading, true);
        expect(copied.estimatedFee, 3000.0);
        expect(copied.distanceKm, 7.5);
        expect(copied.error, 'test error');
      });

      test('should preserve original state when copyWith called', () {
        const original = DeliveryFeeState(
          isLoading: false,
          estimatedFee: 1000.0,
          distanceKm: 2.0,
          error: null,
        );
        
        original.copyWith(isLoading: true);
        
        // Original should be unchanged
        expect(original.isLoading, false);
        expect(original.estimatedFee, 1000.0);
        expect(original.distanceKm, 2.0);
      });
    });

    group('edge cases', () {
      test('should handle zero estimated fee', () {
        const state = DeliveryFeeState(estimatedFee: 0.0);
        expect(state.estimatedFee, 0.0);
      });

      test('should handle zero distance', () {
        const state = DeliveryFeeState(distanceKm: 0.0);
        expect(state.distanceKm, 0.0);
      });

      test('should handle negative values (if API returns them)', () {
        const state = DeliveryFeeState(
          estimatedFee: -100.0,
          distanceKm: -1.0,
        );
        expect(state.estimatedFee, -100.0);
        expect(state.distanceKm, -1.0);
      });

      test('should handle very large numbers', () {
        const state = DeliveryFeeState(
          estimatedFee: 1000000.0,
          distanceKm: 999999.99,
        );
        expect(state.estimatedFee, 1000000.0);
        expect(state.distanceKm, 999999.99);
      });

      test('should handle empty error string', () {
        const state = DeliveryFeeState(error: '');
        expect(state.error, '');
      });

      test('should handle unicode in error message', () {
        const state = DeliveryFeeState(error: 'Erreur: Échec de connexion 🚫');
        expect(state.error, 'Erreur: Échec de connexion 🚫');
      });
    });

    group('use case scenarios', () {
      test('should represent loading state correctly', () {
        const state = DeliveryFeeState(isLoading: true);
        
        expect(state.isLoading, true);
        expect(state.estimatedFee, isNull);
        expect(state.error, isNull);
      });

      test('should represent success state correctly', () {
        const state = DeliveryFeeState(
          isLoading: false,
          estimatedFee: 2500.0,
          distanceKm: 5.0,
          error: null,
        );
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, isNotNull);
        expect(state.error, isNull);
      });

      test('should represent error state correctly', () {
        const state = DeliveryFeeState(
          isLoading: false,
          estimatedFee: null,
          distanceKm: null,
          error: 'Unable to calculate delivery fee',
        );
        
        expect(state.isLoading, false);
        expect(state.estimatedFee, isNull);
        expect(state.error, isNotNull);
      });

      test('should transition from loading to success', () {
        const loadingState = DeliveryFeeState(isLoading: true);
        final successState = loadingState.copyWith(
          isLoading: false,
          estimatedFee: 1500.0,
          distanceKm: 3.0,
        );
        
        expect(loadingState.isLoading, true);
        expect(successState.isLoading, false);
        expect(successState.estimatedFee, 1500.0);
      });

      test('should transition from loading to error', () {
        const loadingState = DeliveryFeeState(isLoading: true);
        final errorState = loadingState.copyWith(
          isLoading: false,
          error: 'Network error',
        );
        
        expect(loadingState.isLoading, true);
        expect(errorState.isLoading, false);
        expect(errorState.error, 'Network error');
      });
    });
  });
}
