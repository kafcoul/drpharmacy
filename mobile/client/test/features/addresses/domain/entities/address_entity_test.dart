import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/addresses/domain/entities/address_entity.dart';

void main() {
  group('AddressEntity', () {
    final testDate = DateTime(2024, 1, 15);
    final testDate2 = DateTime(2024, 2, 20);

    AddressEntity createAddress({
      int id = 1,
      String label = 'Domicile',
      String address = '123 Rue Test',
      String? city = 'Libreville',
      String? district = 'Centre',
      String? phone = '+241 01 23 45 67',
      String? instructions = 'Deuxième étage',
      double? latitude = 0.4162,
      double? longitude = 9.4673,
      bool isDefault = false,
      String fullAddress = '123 Rue Test, Centre, Libreville',
      bool hasCoordinates = true,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return AddressEntity(
        id: id,
        label: label,
        address: address,
        city: city,
        district: district,
        phone: phone,
        instructions: instructions,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        fullAddress: fullAddress,
        hasCoordinates: hasCoordinates,
        createdAt: createdAt ?? testDate,
        updatedAt: updatedAt ?? testDate,
      );
    }

    group('creation', () {
      test('should create with all required fields', () {
        final address = createAddress();

        expect(address.id, equals(1));
        expect(address.label, equals('Domicile'));
        expect(address.address, equals('123 Rue Test'));
        expect(address.city, equals('Libreville'));
        expect(address.district, equals('Centre'));
        expect(address.phone, equals('+241 01 23 45 67'));
        expect(address.instructions, equals('Deuxième étage'));
        expect(address.latitude, equals(0.4162));
        expect(address.longitude, equals(9.4673));
        expect(address.isDefault, isFalse);
        expect(address.fullAddress, equals('123 Rue Test, Centre, Libreville'));
        expect(address.hasCoordinates, isTrue);
        expect(address.createdAt, equals(testDate));
        expect(address.updatedAt, equals(testDate));
      });

      test('should create with null optional fields', () {
        final address = AddressEntity(
          id: 1,
          label: 'Bureau',
          address: '456 Rue Business',
          city: null,
          district: null,
          phone: null,
          instructions: null,
          latitude: null,
          longitude: null,
          isDefault: true,
          fullAddress: '456 Rue Business',
          hasCoordinates: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(address.city, isNull);
        expect(address.district, isNull);
        expect(address.phone, isNull);
        expect(address.instructions, isNull);
        expect(address.latitude, isNull);
        expect(address.longitude, isNull);
        expect(address.hasCoordinates, isFalse);
      });

      test('should handle isDefault true', () {
        final address = createAddress(isDefault: true);
        expect(address.isDefault, isTrue);
      });

      test('should handle various labels', () {
        expect(createAddress(label: 'Domicile').label, equals('Domicile'));
        expect(createAddress(label: 'Bureau').label, equals('Bureau'));
        expect(createAddress(label: 'Autre').label, equals('Autre'));
        expect(createAddress(label: 'Maison familiale').label, equals('Maison familiale'));
      });
    });

    group('coordinates', () {
      test('should store latitude and longitude', () {
        final address = createAddress(latitude: 0.3924, longitude: 9.4536);
        expect(address.latitude, equals(0.3924));
        expect(address.longitude, equals(9.4536));
      });

      test('should handle negative coordinates', () {
        final address = createAddress(latitude: -0.1234, longitude: -9.5678);
        expect(address.latitude, equals(-0.1234));
        expect(address.longitude, equals(-9.5678));
      });

      test('should handle zero coordinates', () {
        final address = createAddress(latitude: 0.0, longitude: 0.0);
        expect(address.latitude, equals(0.0));
        expect(address.longitude, equals(0.0));
      });

      test('should set hasCoordinates to false when no coordinates', () {
        final address = createAddress(
          latitude: null,
          longitude: null,
          hasCoordinates: false,
        );
        expect(address.hasCoordinates, isFalse);
      });
    });

    group('equality', () {
      test('two addresses with same props should be equal', () {
        final address1 = createAddress();
        final address2 = createAddress();
        expect(address1, equals(address2));
      });

      test('two addresses with different ids should not be equal', () {
        final address1 = createAddress(id: 1);
        final address2 = createAddress(id: 2);
        expect(address1, isNot(equals(address2)));
      });

      test('two addresses with different labels should not be equal', () {
        final address1 = createAddress(label: 'Domicile');
        final address2 = createAddress(label: 'Bureau');
        expect(address1, isNot(equals(address2)));
      });

      test('two addresses with different default status should not be equal', () {
        final address1 = createAddress(isDefault: false);
        final address2 = createAddress(isDefault: true);
        expect(address1, isNot(equals(address2)));
      });

      test('two addresses with different coordinates should not be equal', () {
        final address1 = createAddress(latitude: 0.4162);
        final address2 = createAddress(latitude: 0.5000);
        expect(address1, isNot(equals(address2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final address = createAddress();
        expect(address.props.length, equals(14));
        expect(address.props[0], equals(1)); // id
        expect(address.props[1], equals('Domicile')); // label
        expect(address.props[2], equals('123 Rue Test')); // address
        expect(address.props[3], equals('Libreville')); // city
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = createAddress();
        final copy = original.copyWith();
        expect(copy, equals(original));
      });

      test('should copy with new id', () {
        final original = createAddress(id: 1);
        final copy = original.copyWith(id: 99);
        expect(copy.id, equals(99));
        expect(copy.label, equals(original.label));
      });

      test('should copy with new label', () {
        final original = createAddress(label: 'Domicile');
        final copy = original.copyWith(label: 'Bureau');
        expect(copy.label, equals('Bureau'));
        expect(copy.id, equals(original.id));
      });

      test('should copy with new address', () {
        final original = createAddress(address: '123 Rue Test');
        final copy = original.copyWith(address: '456 Nouvelle Rue');
        expect(copy.address, equals('456 Nouvelle Rue'));
      });

      test('should copy with new city', () {
        final original = createAddress(city: 'Libreville');
        final copy = original.copyWith(city: 'Port-Gentil');
        expect(copy.city, equals('Port-Gentil'));
      });

      test('should copy with new district', () {
        final original = createAddress(district: 'Centre');
        final copy = original.copyWith(district: 'Akanda');
        expect(copy.district, equals('Akanda'));
      });

      test('should copy with new phone', () {
        final original = createAddress(phone: '+241 01 23 45 67');
        final copy = original.copyWith(phone: '+241 99 88 77 66');
        expect(copy.phone, equals('+241 99 88 77 66'));
      });

      test('should copy with new instructions', () {
        final original = createAddress(instructions: 'Deuxième étage');
        final copy = original.copyWith(instructions: 'Porte bleue');
        expect(copy.instructions, equals('Porte bleue'));
      });

      test('should copy with new coordinates', () {
        final original = createAddress(latitude: 0.4162, longitude: 9.4673);
        final copy = original.copyWith(latitude: 0.5000, longitude: 10.0000);
        expect(copy.latitude, equals(0.5000));
        expect(copy.longitude, equals(10.0000));
      });

      test('should copy with new isDefault', () {
        final original = createAddress(isDefault: false);
        final copy = original.copyWith(isDefault: true);
        expect(copy.isDefault, isTrue);
      });

      test('should copy with new fullAddress', () {
        final original = createAddress(fullAddress: '123 Rue Test, Libreville');
        final copy = original.copyWith(fullAddress: '456 Nouvelle Rue, Port-Gentil');
        expect(copy.fullAddress, equals('456 Nouvelle Rue, Port-Gentil'));
      });

      test('should copy with new hasCoordinates', () {
        final original = createAddress(hasCoordinates: true);
        final copy = original.copyWith(hasCoordinates: false);
        expect(copy.hasCoordinates, isFalse);
      });

      test('should copy with new dates', () {
        final original = createAddress(createdAt: testDate, updatedAt: testDate);
        final copy = original.copyWith(createdAt: testDate2, updatedAt: testDate2);
        expect(copy.createdAt, equals(testDate2));
        expect(copy.updatedAt, equals(testDate2));
      });

      test('should copy with multiple changes', () {
        final original = createAddress();
        final copy = original.copyWith(
          label: 'Nouveau Label',
          address: 'Nouvelle Adresse',
          isDefault: true,
          phone: '+241 11 22 33 44',
        );
        expect(copy.label, equals('Nouveau Label'));
        expect(copy.address, equals('Nouvelle Adresse'));
        expect(copy.isDefault, isTrue);
        expect(copy.phone, equals('+241 11 22 33 44'));
        // Others unchanged
        expect(copy.id, equals(original.id));
        expect(copy.city, equals(original.city));
      });
    });

    group('hashCode', () {
      test('same addresses should have same hashCode', () {
        final address1 = createAddress();
        final address2 = createAddress();
        expect(address1.hashCode, equals(address2.hashCode));
      });

      test('different addresses should have different hashCodes', () {
        final address1 = createAddress(id: 1);
        final address2 = createAddress(id: 2);
        expect(address1.hashCode, isNot(equals(address2.hashCode)));
      });
    });
  });
}
