import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/pharmacies/presentation/providers/pharmacies_state.dart';
import 'package:drpharma_client/features/pharmacies/domain/entities/pharmacy_entity.dart';

void main() {
  group('PharmaciesStatus', () {
    test('should have all expected values', () {
      expect(PharmaciesStatus.values, [
        PharmaciesStatus.initial,
        PharmaciesStatus.loading,
        PharmaciesStatus.success,
        PharmaciesStatus.error,
      ]);
    });

    test('should have correct number of values', () {
      expect(PharmaciesStatus.values.length, 4);
    });
  });

  group('PharmaciesState', () {
    const tPharmacy = PharmacyEntity(
      id: 1,
      name: 'Pharmacie du Centre',
      address: '123 Rue Principale',
      phone: '+241 01 23 45 67',
      status: 'active',
      isOpen: true,
    );

    const tPharmacy2 = PharmacyEntity(
      id: 2,
      name: 'Pharmacie de la Gare',
      address: '456 Avenue de la Gare',
      phone: '+241 01 78 90 12',
      status: 'active',
      isOpen: false,
    );

    const tOnDutyPharmacy = PharmacyEntity(
      id: 3,
      name: 'Pharmacie de Garde',
      address: '789 Boulevard Central',
      phone: '+241 01 34 56 78',
      status: 'active',
      isOpen: true,
      isOnDuty: true,
      dutyType: 'night',
    );

    group('Constructor', () {
      test('should create state with default values', () {
        const state = PharmaciesState();

        expect(state.status, PharmaciesStatus.initial);
        expect(state.pharmacies, isEmpty);
        expect(state.nearbyPharmacies, isEmpty);
        expect(state.onDutyPharmacies, isEmpty);
        expect(state.featuredPharmacies, isEmpty);
        expect(state.selectedPharmacy, isNull);
        expect(state.errorMessage, isNull);
        expect(state.hasReachedMax, false);
        expect(state.currentPage, 1);
        expect(state.isFeaturedLoading, false);
        expect(state.isFeaturedLoaded, false);
      });

      test('should create state with all provided values', () {
        final state = PharmaciesState(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy],
          nearbyPharmacies: [tPharmacy2],
          onDutyPharmacies: [tOnDutyPharmacy],
          featuredPharmacies: [tPharmacy],
          selectedPharmacy: tPharmacy,
          errorMessage: 'Error',
          hasReachedMax: true,
          currentPage: 3,
          isFeaturedLoading: true,
          isFeaturedLoaded: true,
        );

        expect(state.status, PharmaciesStatus.success);
        expect(state.pharmacies, [tPharmacy]);
        expect(state.nearbyPharmacies, [tPharmacy2]);
        expect(state.onDutyPharmacies, [tOnDutyPharmacy]);
        expect(state.featuredPharmacies, [tPharmacy]);
        expect(state.selectedPharmacy, tPharmacy);
        expect(state.errorMessage, 'Error');
        expect(state.hasReachedMax, true);
        expect(state.currentPage, 3);
        expect(state.isFeaturedLoading, true);
        expect(state.isFeaturedLoaded, true);
      });
    });

    group('copyWith', () {
      test('should copy state with new status', () {
        const original = PharmaciesState();
        final copied = original.copyWith(status: PharmaciesStatus.loading);

        expect(copied.status, PharmaciesStatus.loading);
        expect(copied.pharmacies, original.pharmacies);
      });

      test('should copy state with new pharmacies', () {
        const original = PharmaciesState();
        final copied = original.copyWith(pharmacies: [tPharmacy]);

        expect(copied.pharmacies, [tPharmacy]);
        expect(copied.status, original.status);
      });

      test('should copy state with new nearbyPharmacies', () {
        const original = PharmaciesState();
        final copied = original.copyWith(nearbyPharmacies: [tPharmacy2]);

        expect(copied.nearbyPharmacies, [tPharmacy2]);
      });

      test('should copy state with new onDutyPharmacies', () {
        const original = PharmaciesState();
        final copied = original.copyWith(onDutyPharmacies: [tOnDutyPharmacy]);

        expect(copied.onDutyPharmacies, [tOnDutyPharmacy]);
      });

      test('should copy state with new featuredPharmacies', () {
        const original = PharmaciesState();
        final copied = original.copyWith(featuredPharmacies: [tPharmacy]);

        expect(copied.featuredPharmacies, [tPharmacy]);
      });

      test('should copy state with new selectedPharmacy', () {
        const original = PharmaciesState();
        final copied = original.copyWith(selectedPharmacy: tPharmacy);

        expect(copied.selectedPharmacy, tPharmacy);
      });

      test('should copy state with new errorMessage', () {
        const original = PharmaciesState();
        final copied = original.copyWith(errorMessage: 'Network error');

        expect(copied.errorMessage, 'Network error');
      });

      test('should copy state with new hasReachedMax', () {
        const original = PharmaciesState();
        final copied = original.copyWith(hasReachedMax: true);

        expect(copied.hasReachedMax, true);
      });

      test('should copy state with new currentPage', () {
        const original = PharmaciesState();
        final copied = original.copyWith(currentPage: 5);

        expect(copied.currentPage, 5);
      });

      test('should copy state with new isFeaturedLoading', () {
        const original = PharmaciesState();
        final copied = original.copyWith(isFeaturedLoading: true);

        expect(copied.isFeaturedLoading, true);
      });

      test('should copy state with new isFeaturedLoaded', () {
        const original = PharmaciesState();
        final copied = original.copyWith(isFeaturedLoaded: true);

        expect(copied.isFeaturedLoaded, true);
      });

      test('should copy with multiple new values', () {
        const original = PharmaciesState();
        final copied = original.copyWith(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy, tPharmacy2],
          currentPage: 2,
          hasReachedMax: false,
          isFeaturedLoaded: true,
        );

        expect(copied.status, PharmaciesStatus.success);
        expect(copied.pharmacies.length, 2);
        expect(copied.currentPage, 2);
        expect(copied.hasReachedMax, false);
        expect(copied.isFeaturedLoaded, true);
      });

      test('should keep original values when not specified', () {
        final original = PharmaciesState(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy],
          currentPage: 3,
          isFeaturedLoaded: true,
        );

        final copied = original.copyWith(status: PharmaciesStatus.loading);

        expect(copied.status, PharmaciesStatus.loading);
        expect(copied.pharmacies, original.pharmacies);
        expect(copied.currentPage, original.currentPage);
        expect(copied.isFeaturedLoaded, original.isFeaturedLoaded);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal states', () {
        const state1 = PharmaciesState();
        const state2 = PharmaciesState();

        expect(state1, state2);
      });

      test('should return false when statuses are different', () {
        const state1 = PharmaciesState(status: PharmaciesStatus.initial);
        const state2 = PharmaciesState(status: PharmaciesStatus.loading);

        expect(state1, isNot(state2));
      });

      test('should return false when pharmacies are different', () {
        const state1 = PharmaciesState(pharmacies: [tPharmacy]);
        const state2 = PharmaciesState(pharmacies: [tPharmacy2]);

        expect(state1, isNot(state2));
      });

      test('should return false when currentPage is different', () {
        const state1 = PharmaciesState(currentPage: 1);
        const state2 = PharmaciesState(currentPage: 2);

        expect(state1, isNot(state2));
      });

      test('should return false when hasReachedMax is different', () {
        const state1 = PharmaciesState(hasReachedMax: false);
        const state2 = PharmaciesState(hasReachedMax: true);

        expect(state1, isNot(state2));
      });

      test('should have same hashCode for equal states', () {
        const state1 = PharmaciesState();
        const state2 = PharmaciesState();

        expect(state1.hashCode, state2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields', () {
        final state = PharmaciesState(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy],
          nearbyPharmacies: [tPharmacy2],
          onDutyPharmacies: [tOnDutyPharmacy],
          featuredPharmacies: [tPharmacy],
          selectedPharmacy: tPharmacy,
          errorMessage: 'Error',
          hasReachedMax: true,
          currentPage: 3,
          isFeaturedLoading: true,
          isFeaturedLoaded: true,
        );

        expect(state.props.length, 11);
        expect(state.props[0], PharmaciesStatus.success);
        expect(state.props[1], [tPharmacy]);
        expect(state.props[2], [tPharmacy2]);
        expect(state.props[3], [tOnDutyPharmacy]);
        expect(state.props[4], [tPharmacy]);
        expect(state.props[5], tPharmacy);
        expect(state.props[6], 'Error');
        expect(state.props[7], true);
        expect(state.props[8], 3);
        expect(state.props[9], true);
        expect(state.props[10], true);
      });

      test('should include null values in props', () {
        const state = PharmaciesState();

        expect(state.props.contains(null), true);
      });
    });

    group('Use cases', () {
      test('should represent initial state', () {
        const state = PharmaciesState();

        expect(state.status, PharmaciesStatus.initial);
        expect(state.pharmacies, isEmpty);
      });

      test('should represent loading state', () {
        const state = PharmaciesState(status: PharmaciesStatus.loading);

        expect(state.status, PharmaciesStatus.loading);
      });

      test('should represent success state with pharmacies', () {
        final state = PharmaciesState(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy, tPharmacy2],
          hasReachedMax: false,
        );

        expect(state.status, PharmaciesStatus.success);
        expect(state.pharmacies.length, 2);
        expect(state.hasReachedMax, false);
      });

      test('should represent error state', () {
        const state = PharmaciesState(
          status: PharmaciesStatus.error,
          errorMessage: 'Network error',
        );

        expect(state.status, PharmaciesStatus.error);
        expect(state.errorMessage, 'Network error');
      });

      test('should handle pagination state', () {
        final state = PharmaciesState(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy, tPharmacy2],
          currentPage: 3,
          hasReachedMax: false,
        );

        expect(state.currentPage, 3);
        expect(state.hasReachedMax, false);
      });

      test('should handle last page state', () {
        final state = PharmaciesState(
          status: PharmaciesStatus.success,
          pharmacies: [tPharmacy],
          currentPage: 5,
          hasReachedMax: true,
        );

        expect(state.hasReachedMax, true);
      });

      test('should handle on-duty pharmacies', () {
        final state = PharmaciesState(
          status: PharmaciesStatus.success,
          onDutyPharmacies: [tOnDutyPharmacy],
        );

        expect(state.onDutyPharmacies.length, 1);
        expect(state.onDutyPharmacies.first.isOnDuty, true);
      });

      test('should handle featured pharmacies loading', () {
        const state = PharmaciesState(
          isFeaturedLoading: true,
          isFeaturedLoaded: false,
        );

        expect(state.isFeaturedLoading, true);
        expect(state.isFeaturedLoaded, false);
      });

      test('should handle featured pharmacies loaded', () {
        final state = PharmaciesState(
          featuredPharmacies: [tPharmacy],
          isFeaturedLoading: false,
          isFeaturedLoaded: true,
        );

        expect(state.featuredPharmacies.length, 1);
        expect(state.isFeaturedLoading, false);
        expect(state.isFeaturedLoaded, true);
      });

      test('should handle selected pharmacy', () {
        const state = PharmaciesState(
          selectedPharmacy: tPharmacy,
        );

        expect(state.selectedPharmacy, tPharmacy);
        expect(state.selectedPharmacy!.id, 1);
      });
    });

    group('Edge cases', () {
      test('should handle empty lists for all pharmacy types', () {
        const state = PharmaciesState(
          pharmacies: [],
          nearbyPharmacies: [],
          onDutyPharmacies: [],
          featuredPharmacies: [],
        );

        expect(state.pharmacies, isEmpty);
        expect(state.nearbyPharmacies, isEmpty);
        expect(state.onDutyPharmacies, isEmpty);
        expect(state.featuredPharmacies, isEmpty);
      });

      test('should handle many pharmacies', () {
        final manyPharmacies = List<PharmacyEntity>.generate(
          100,
          (i) => PharmacyEntity(
            id: i,
            name: 'Pharmacy $i',
            address: 'Address $i',
            phone: '+241 01 00 00 $i',
            status: 'active',
            isOpen: i % 2 == 0,
          ),
        );

        final state = PharmaciesState(pharmacies: manyPharmacies);

        expect(state.pharmacies.length, 100);
      });

      test('should handle high page number', () {
        const state = PharmaciesState(currentPage: 999);

        expect(state.currentPage, 999);
      });

      test('should handle long error message', () {
        const longError = 'This is a very long error message that describes '
            'in detail what went wrong during the API call to fetch pharmacies '
            'including network timeouts, server errors, and retry information.';

        const state = PharmaciesState(errorMessage: longError);

        expect(state.errorMessage, longError);
        expect(state.errorMessage!.length, greaterThan(100));
      });
    });
  });
}
