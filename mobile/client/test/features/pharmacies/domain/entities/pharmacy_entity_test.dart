import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/pharmacies/domain/entities/pharmacy_entity.dart';

void main() {
  group('PharmacyEntity', () {
    const tPharmacy = PharmacyEntity(
      id: 1,
      name: 'Pharmacie du Centre',
      address: '123 Rue Principale',
      phone: '+241 01 23 45 67',
      email: 'contact@pharmacie.com',
      latitude: 0.3924,
      longitude: 9.4536,
      status: 'active',
      isOpen: true,
      distance: 1.5,
      openingHours: '08:00-20:00',
      description: 'Une pharmacie de qualité',
      isOnDuty: true,
      dutyType: 'night',
      dutyEndAt: '2024-01-15T08:00:00Z',
    );

    group('Constructor', () {
      test('should create a valid PharmacyEntity with all required fields', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test Pharmacy',
          address: '123 Street',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.id, 1);
        expect(pharmacy.name, 'Test Pharmacy');
        expect(pharmacy.address, '123 Street');
        expect(pharmacy.status, 'active');
        expect(pharmacy.isOpen, true);
      });

      test('should have null optional fields by default', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: false,
        );

        expect(pharmacy.phone, isNull);
        expect(pharmacy.email, isNull);
        expect(pharmacy.latitude, isNull);
        expect(pharmacy.longitude, isNull);
        expect(pharmacy.distance, isNull);
        expect(pharmacy.openingHours, isNull);
        expect(pharmacy.description, isNull);
        expect(pharmacy.dutyType, isNull);
        expect(pharmacy.dutyEndAt, isNull);
      });

      test('should have isOnDuty default to false', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: false,
        );

        expect(pharmacy.isOnDuty, false);
      });

      test('should create a valid entity with all fields', () {
        expect(tPharmacy.id, 1);
        expect(tPharmacy.name, 'Pharmacie du Centre');
        expect(tPharmacy.address, '123 Rue Principale');
        expect(tPharmacy.phone, '+241 01 23 45 67');
        expect(tPharmacy.email, 'contact@pharmacie.com');
        expect(tPharmacy.latitude, 0.3924);
        expect(tPharmacy.longitude, 9.4536);
        expect(tPharmacy.status, 'active');
        expect(tPharmacy.isOpen, true);
        expect(tPharmacy.distance, 1.5);
        expect(tPharmacy.openingHours, '08:00-20:00');
        expect(tPharmacy.description, 'Une pharmacie de qualité');
        expect(tPharmacy.isOnDuty, true);
        expect(tPharmacy.dutyType, 'night');
        expect(tPharmacy.dutyEndAt, '2024-01-15T08:00:00Z');
      });
    });

    group('initials', () {
      test('should return first letter when name has one word', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Pharmacie',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.initials, 'P');
      });

      test('should return first letters of first two words', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Pharmacie Centrale',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.initials, 'PC');
      });

      test('should return uppercase initials', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'pharmacie centrale',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.initials, 'PC');
      });

      test('should handle names with more than two words', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Pharmacie du Centre Ville',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.initials, 'PD');
      });

      // Note: empty name causes a RangeError in current implementation
      // This is a known edge case that should be handled by validation
      test('should handle single character name', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'A',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.initials, 'A');
      });
    });

    group('statusLabel', () {
      test('should return "Active" for active status', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.statusLabel, 'Active');
      });

      test('should return "Inactive" for inactive status', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'inactive',
          isOpen: false,
        );

        expect(pharmacy.statusLabel, 'Inactive');
      });

      test('should return "Suspendue" for suspended status', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'suspended',
          isOpen: false,
        );

        expect(pharmacy.statusLabel, 'Suspendue');
      });

      test('should return status as-is for unknown status', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'pending',
          isOpen: false,
        );

        expect(pharmacy.statusLabel, 'pending');
      });
    });

    group('distanceLabel', () {
      test('should return empty string when distance is null', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: null,
        );

        expect(pharmacy.distanceLabel, '');
      });

      test('should return meters when distance < 1 km', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 0.5,
        );

        expect(pharmacy.distanceLabel, '500 m');
      });

      test('should return meters for small distances', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 0.123,
        );

        expect(pharmacy.distanceLabel, '123 m');
      });

      test('should return km when distance >= 1 km', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 1.5,
        );

        expect(pharmacy.distanceLabel, '1.5 km');
      });

      test('should return km with one decimal for large distances', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 10.75,
        );

        expect(pharmacy.distanceLabel, '10.8 km');
      });

      test('should return exactly 1 km for distance of 1', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 1.0,
        );

        expect(pharmacy.distanceLabel, '1.0 km');
      });

      test('should return 0 m for distance of 0', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 0,
        );

        expect(pharmacy.distanceLabel, '0 m');
      });

      test('should handle very small distances', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          distance: 0.05,
        );

        expect(pharmacy.distanceLabel, '50 m');
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        const pharmacy2 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy1, pharmacy2);
      });

      test('should return false when ids are different', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        const pharmacy2 = PharmacyEntity(
          id: 2,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy1, isNot(pharmacy2));
      });

      test('should return false when names are different', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Test1',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        const pharmacy2 = PharmacyEntity(
          id: 1,
          name: 'Test2',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy1, isNot(pharmacy2));
      });

      test('should return false when statuses are different', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        const pharmacy2 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'inactive',
          isOpen: true,
        );

        expect(pharmacy1, isNot(pharmacy2));
      });

      test('should return false when isOnDuty is different', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          isOnDuty: true,
        );

        const pharmacy2 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          isOnDuty: false,
        );

        expect(pharmacy1, isNot(pharmacy2));
      });

      test('should have same hashCode for equal entities', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        const pharmacy2 = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy1.hashCode, pharmacy2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields', () {
        expect(tPharmacy.props, [
          1,
          'Pharmacie du Centre',
          '123 Rue Principale',
          '+241 01 23 45 67',
          'contact@pharmacie.com',
          0.3924,
          9.4536,
          'active',
          true,
          1.5,
          '08:00-20:00',
          'Une pharmacie de qualité',
          true,
          'night',
          '2024-01-15T08:00:00Z',
        ]);
      });

      test('should include null values in props', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: false,
        );

        expect(pharmacy.props, contains(isNull));
      });
    });

    group('Edge cases', () {
      test('should handle pharmacy with coordinates but no distance', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          latitude: 0.3924,
          longitude: 9.4536,
        );

        expect(pharmacy.latitude, 0.3924);
        expect(pharmacy.longitude, 9.4536);
        expect(pharmacy.distance, isNull);
        expect(pharmacy.distanceLabel, '');
      });

      test('should handle pharmacy with duty info', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          isOnDuty: true,
          dutyType: 'day',
          dutyEndAt: '2024-01-15T18:00:00Z',
        );

        expect(pharmacy.isOnDuty, true);
        expect(pharmacy.dutyType, 'day');
        expect(pharmacy.dutyEndAt, '2024-01-15T18:00:00Z');
      });

      test('should handle closed pharmacy', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Closed Pharmacy',
          address: 'Address',
          status: 'active',
          isOpen: false,
        );

        expect(pharmacy.isOpen, false);
        expect(pharmacy.status, 'active');
      });

      test('should handle suspended pharmacy', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Suspended Pharmacy',
          address: 'Address',
          status: 'suspended',
          isOpen: false,
        );

        expect(pharmacy.isOpen, false);
        expect(pharmacy.status, 'suspended');
        expect(pharmacy.statusLabel, 'Suspendue');
      });

      test('should handle very long names for initials', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Super Grande Pharmacie Internationale de Libreville',
          address: 'Address',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.initials, 'SG');
      });

      test('should handle negative coordinates', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          latitude: -0.3924,
          longitude: -9.4536,
        );

        expect(pharmacy.latitude, -0.3924);
        expect(pharmacy.longitude, -9.4536);
      });

      test('should handle zero coordinates', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test',
          address: 'Address',
          status: 'active',
          isOpen: true,
          latitude: 0.0,
          longitude: 0.0,
        );

        expect(pharmacy.latitude, 0.0);
        expect(pharmacy.longitude, 0.0);
      });
    });
  });
}
