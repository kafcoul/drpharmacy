import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/addresses/presentation/providers/addresses_provider.dart';
import 'package:drpharma_client/features/addresses/domain/entities/address_entity.dart';

void main() {
  group('AddressesState', () {
    final tAddress = AddressEntity(
      id: 1,
      label: 'Maison',
      address: '123 Rue Principale',
      city: 'Libreville',
      district: 'Centre',
      phone: '+241 01 23 45 67',
      instructions: 'Porte bleue',
      latitude: 0.3924,
      longitude: 9.4536,
      isDefault: true,
      fullAddress: '123 Rue Principale, Libreville',
      hasCoordinates: true,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    final tAddress2 = AddressEntity(
      id: 2,
      label: 'Bureau',
      address: '456 Avenue des Affaires',
      city: 'Libreville',
      isDefault: false,
      fullAddress: '456 Avenue des Affaires, Libreville',
      hasCoordinates: false,
      createdAt: DateTime(2024, 1, 16),
      updatedAt: DateTime(2024, 1, 16),
    );

    group('Constructor', () {
      test('should create state with default values', () {
        const state = AddressesState();

        expect(state.addresses, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
        expect(state.selectedAddress, isNull);
      });

      test('should create state with all provided values', () {
        final state = AddressesState(
          addresses: [tAddress],
          isLoading: true,
          error: 'Error occurred',
          selectedAddress: tAddress,
        );

        expect(state.addresses, [tAddress]);
        expect(state.isLoading, true);
        expect(state.error, 'Error occurred');
        expect(state.selectedAddress, tAddress);
      });
    });

    group('copyWith', () {
      test('should copy state with new addresses', () {
        const original = AddressesState();
        final copied = original.copyWith(addresses: [tAddress]);

        expect(copied.addresses, [tAddress]);
        expect(copied.isLoading, original.isLoading);
        expect(copied.error, original.error);
        expect(copied.selectedAddress, original.selectedAddress);
      });

      test('should copy state with new isLoading', () {
        const original = AddressesState();
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy state with new error', () {
        const original = AddressesState();
        final copied = original.copyWith(error: 'Error');

        expect(copied.error, 'Error');
      });

      test('should copy state with new selectedAddress', () {
        const original = AddressesState();
        final copied = original.copyWith(selectedAddress: tAddress);

        expect(copied.selectedAddress, tAddress);
      });

      test('should clear error when clearError is true', () {
        final original = AddressesState(error: 'Old error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should clear selectedAddress when clearSelected is true', () {
        final original = AddressesState(selectedAddress: tAddress);
        final copied = original.copyWith(clearSelected: true);

        expect(copied.selectedAddress, isNull);
      });

      test('should keep original values when not specified', () {
        final original = AddressesState(
          addresses: [tAddress],
          isLoading: true,
          error: 'Error',
          selectedAddress: tAddress,
        );

        final copied = original.copyWith();

        expect(copied.addresses, original.addresses);
        expect(copied.isLoading, original.isLoading);
        expect(copied.error, original.error);
        expect(copied.selectedAddress, original.selectedAddress);
      });

      test('should copy with multiple new values', () {
        const original = AddressesState();
        final copied = original.copyWith(
          addresses: [tAddress, tAddress2],
          isLoading: false,
          selectedAddress: tAddress,
        );

        expect(copied.addresses.length, 2);
        expect(copied.isLoading, false);
        expect(copied.selectedAddress, tAddress);
      });

      test('should not clear error when clearError is false', () {
        final original = AddressesState(error: 'Old error');
        final copied = original.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should prefer new error over old even with clearError false', () {
        final original = AddressesState(error: 'Old error');
        final copied = original.copyWith(error: 'New error', clearError: false);

        expect(copied.error, 'New error');
      });
    });

    group('defaultAddress', () {
      test('should return null when addresses list is empty', () {
        const state = AddressesState();

        expect(state.defaultAddress, isNull);
      });

      test('should return null when no address is default', () {
        final state = AddressesState(
          addresses: [tAddress2],
        );

        expect(state.defaultAddress, isNull);
      });

      test('should return the default address when one exists', () {
        final state = AddressesState(
          addresses: [tAddress2, tAddress],
        );

        expect(state.defaultAddress, tAddress);
        expect(state.defaultAddress!.isDefault, true);
      });

      test('should return first default address when multiple have isDefault true', () {
        final address1Default = AddressEntity(
          id: 1,
          label: 'First',
          address: 'Address 1',
          isDefault: true,
          fullAddress: 'Address 1',
          hasCoordinates: false,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );
        
        final address2Default = AddressEntity(
          id: 2,
          label: 'Second',
          address: 'Address 2',
          isDefault: true,
          fullAddress: 'Address 2',
          hasCoordinates: false,
          createdAt: DateTime(2024, 1, 16),
          updatedAt: DateTime(2024, 1, 16),
        );

        final state = AddressesState(
          addresses: [address1Default, address2Default],
        );

        // firstOrNull returns the first matching element
        expect(state.defaultAddress, address1Default);
      });
    });

    group('Use cases', () {
      test('should represent initial state', () {
        const state = AddressesState();

        expect(state.addresses, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should represent loading state', () {
        const state = AddressesState(isLoading: true);

        expect(state.isLoading, true);
        expect(state.error, isNull);
      });

      test('should represent loaded state with addresses', () {
        final state = AddressesState(
          addresses: [tAddress, tAddress2],
          isLoading: false,
          selectedAddress: tAddress,
        );

        expect(state.addresses.length, 2);
        expect(state.isLoading, false);
        expect(state.selectedAddress, tAddress);
      });

      test('should represent error state', () {
        const state = AddressesState(
          isLoading: false,
          error: 'Failed to load addresses',
        );

        expect(state.isLoading, false);
        expect(state.error, 'Failed to load addresses');
      });

      test('should transition from loading to loaded', () {
        const loading = AddressesState(isLoading: true);
        final loaded = loading.copyWith(
          isLoading: false,
          addresses: [tAddress],
          selectedAddress: tAddress,
        );

        expect(loaded.isLoading, false);
        expect(loaded.addresses, [tAddress]);
        expect(loaded.selectedAddress, tAddress);
      });

      test('should transition from loading to error', () {
        const loading = AddressesState(isLoading: true);
        final error = loading.copyWith(
          isLoading: false,
          error: 'Network error',
        );

        expect(error.isLoading, false);
        expect(error.error, 'Network error');
      });

      test('should handle adding a new address', () {
        final initial = AddressesState(addresses: [tAddress]);
        final updated = initial.copyWith(
          addresses: [...initial.addresses, tAddress2],
        );

        expect(updated.addresses.length, 2);
        expect(updated.addresses.contains(tAddress2), true);
      });

      test('should handle removing an address', () {
        final initial = AddressesState(addresses: [tAddress, tAddress2]);
        final updated = initial.copyWith(
          addresses: initial.addresses.where((a) => a.id != 1).toList(),
        );

        expect(updated.addresses.length, 1);
        expect(updated.addresses.first.id, 2);
      });

      test('should handle selecting a different address', () {
        final initial = AddressesState(
          addresses: [tAddress, tAddress2],
          selectedAddress: tAddress,
        );
        final updated = initial.copyWith(selectedAddress: tAddress2);

        expect(updated.selectedAddress, tAddress2);
        expect(updated.selectedAddress!.id, 2);
      });
    });

    group('Edge cases', () {
      test('should handle empty addresses list', () {
        final state = AddressesState(addresses: const []);

        expect(state.addresses, isEmpty);
        expect(state.defaultAddress, isNull);
      });

      test('should handle very long error message', () {
        const longError = 'This is a very long error message that could potentially '
            'contain detailed information about what went wrong during the '
            'address loading process including network issues, server errors, '
            'and validation problems.';

        final state = AddressesState(error: longError);

        expect(state.error, longError);
        expect(state.error!.length, greaterThan(100));
      });

      test('should handle many addresses', () {
        final manyAddresses = List<AddressEntity>.generate(
          100,
          (i) => AddressEntity(
            id: i,
            label: 'Address $i',
            address: 'Street $i',
            isDefault: i == 0,
            fullAddress: 'Street $i',
            hasCoordinates: false,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        );

        final state = AddressesState(addresses: manyAddresses);

        expect(state.addresses.length, 100);
        expect(state.defaultAddress!.id, 0);
      });
    });
  });
}
