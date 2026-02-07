import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/pharmacies/presentation/providers/pharmacies_async_provider.dart';
import 'package:drpharma_client/features/pharmacies/domain/entities/pharmacy_entity.dart';

// Helper to create test pharmacy
PharmacyEntity createTestPharmacy({
  int id = 1,
  String name = 'Test Pharmacy',
  String address = '123 Test St',
  bool isOpen = true,
  bool isOnDuty = false,
}) {
  return PharmacyEntity(
    id: id,
    name: name,
    address: address,
    status: 'active',
    isOpen: isOpen,
    isOnDuty: isOnDuty,
  );
}

void main() {
  group('PharmaciesAsyncProvider Tests', () {
    test('pharmaciesAsyncProvider should be defined', () {
      expect(pharmaciesAsyncProvider, isNotNull);
    });

    test('pharmaciesAsyncProvider should be an AsyncNotifierProvider', () {
      expect(pharmaciesAsyncProvider, isA<AsyncNotifierProvider>());
    });
  });

  group('PharmaciesAsyncState', () {
    test('should create with default values', () {
      // Act
      const state = PharmaciesAsyncState();

      // Assert
      expect(state.pharmacies, isEmpty);
      expect(state.nearbyPharmacies, isEmpty);
      expect(state.onDutyPharmacies, isEmpty);
      expect(state.featuredPharmacies, isEmpty);
      expect(state.selectedPharmacy, isNull);
      expect(state.hasReachedMax, false);
      expect(state.currentPage, 1);
    });

    test('should create with custom values', () {
      // Arrange
      final pharmacy = createTestPharmacy();

      // Act
      final state = PharmaciesAsyncState(
        pharmacies: [pharmacy],
        nearbyPharmacies: [pharmacy],
        onDutyPharmacies: [pharmacy],
        featuredPharmacies: [pharmacy],
        selectedPharmacy: pharmacy,
        hasReachedMax: true,
        currentPage: 5,
      );

      // Assert
      expect(state.pharmacies.length, 1);
      expect(state.nearbyPharmacies.length, 1);
      expect(state.onDutyPharmacies.length, 1);
      expect(state.featuredPharmacies.length, 1);
      expect(state.selectedPharmacy, pharmacy);
      expect(state.hasReachedMax, true);
      expect(state.currentPage, 5);
    });

    test('copyWith should update pharmacies', () {
      // Arrange
      const initialState = PharmaciesAsyncState();
      final pharmacy = createTestPharmacy();

      // Act
      final newState = initialState.copyWith(pharmacies: [pharmacy]);

      // Assert
      expect(newState.pharmacies.length, 1);
      expect(newState.nearbyPharmacies, isEmpty);
      expect(newState.hasReachedMax, false);
    });

    test('copyWith should update nearbyPharmacies', () {
      // Arrange
      const initialState = PharmaciesAsyncState();
      final pharmacy = createTestPharmacy(name: 'Nearby');

      // Act
      final newState = initialState.copyWith(nearbyPharmacies: [pharmacy]);

      // Assert
      expect(newState.nearbyPharmacies.length, 1);
      expect(newState.pharmacies, isEmpty);
    });

    test('copyWith should update onDutyPharmacies', () {
      // Arrange
      const initialState = PharmaciesAsyncState();
      final pharmacy = createTestPharmacy(isOnDuty: true);

      // Act
      final newState = initialState.copyWith(onDutyPharmacies: [pharmacy]);

      // Assert
      expect(newState.onDutyPharmacies.length, 1);
      expect(newState.onDutyPharmacies.first.isOnDuty, true);
    });

    test('copyWith should update featuredPharmacies', () {
      // Arrange
      const initialState = PharmaciesAsyncState();
      final pharmacy = createTestPharmacy(name: 'Featured');

      // Act
      final newState = initialState.copyWith(featuredPharmacies: [pharmacy]);

      // Assert
      expect(newState.featuredPharmacies.length, 1);
    });

    test('copyWith should update selectedPharmacy', () {
      // Arrange
      const initialState = PharmaciesAsyncState();
      final pharmacy = createTestPharmacy(id: 2, name: 'Selected');

      // Act
      final newState = initialState.copyWith(selectedPharmacy: pharmacy);

      // Assert
      expect(newState.selectedPharmacy, pharmacy);
      expect(newState.selectedPharmacy?.id, 2);
    });

    test('copyWith should update hasReachedMax', () {
      // Arrange
      const initialState = PharmaciesAsyncState();

      // Act
      final newState = initialState.copyWith(hasReachedMax: true);

      // Assert
      expect(newState.hasReachedMax, true);
    });

    test('copyWith should update currentPage', () {
      // Arrange
      const initialState = PharmaciesAsyncState();

      // Act
      final newState = initialState.copyWith(currentPage: 10);

      // Assert
      expect(newState.currentPage, 10);
    });

    test('copyWith should preserve unchanged values', () {
      // Arrange
      final pharmacy1 = createTestPharmacy(id: 1, name: 'P1');
      final pharmacy2 = createTestPharmacy(id: 2, name: 'P2', isOnDuty: true);

      final initialState = PharmaciesAsyncState(
        pharmacies: [pharmacy1],
        onDutyPharmacies: [pharmacy2],
        hasReachedMax: true,
        currentPage: 3,
      );

      // Act
      final newState = initialState.copyWith(currentPage: 4);

      // Assert
      expect(newState.pharmacies.length, 1);
      expect(newState.onDutyPharmacies.length, 1);
      expect(newState.hasReachedMax, true);
      expect(newState.currentPage, 4);
    });

    test('copyWith with no arguments should return equivalent state', () {
      // Arrange
      final pharmacy = createTestPharmacy();
      final initialState = PharmaciesAsyncState(
        pharmacies: [pharmacy],
        currentPage: 2,
        hasReachedMax: true,
      );

      // Act
      final newState = initialState.copyWith();

      // Assert
      expect(newState.pharmacies.length, initialState.pharmacies.length);
      expect(newState.currentPage, initialState.currentPage);
      expect(newState.hasReachedMax, initialState.hasReachedMax);
    });

    test('copyWith should allow updating multiple fields at once', () {
      // Arrange
      const initialState = PharmaciesAsyncState();
      final pharmacy = createTestPharmacy();

      // Act
      final newState = initialState.copyWith(
        pharmacies: [pharmacy],
        featuredPharmacies: [pharmacy],
        hasReachedMax: true,
        currentPage: 5,
      );

      // Assert
      expect(newState.pharmacies.length, 1);
      expect(newState.featuredPharmacies.length, 1);
      expect(newState.hasReachedMax, true);
      expect(newState.currentPage, 5);
      expect(newState.nearbyPharmacies, isEmpty);
      expect(newState.onDutyPharmacies, isEmpty);
    });
  });
}
