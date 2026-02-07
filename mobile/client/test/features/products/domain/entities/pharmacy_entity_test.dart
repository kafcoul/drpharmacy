import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';

void main() {
  group('PharmacyEntity', () {
    PharmacyEntity createPharmacy({
      int id = 1,
      String name = 'Pharmacie Centrale',
      String address = '123 Avenue Test, Libreville',
      String phone = '+241 01 23 45 67',
      String? email = 'contact@pharmacie.ga',
      double? latitude = 0.4162,
      double? longitude = 9.4673,
      String status = 'active',
      bool isOpen = true,
    }) {
      return PharmacyEntity(
        id: id,
        name: name,
        address: address,
        phone: phone,
        email: email,
        latitude: latitude,
        longitude: longitude,
        status: status,
        isOpen: isOpen,
      );
    }

    group('creation', () {
      test('should create with all required fields', () {
        final pharmacy = createPharmacy();

        expect(pharmacy.id, equals(1));
        expect(pharmacy.name, equals('Pharmacie Centrale'));
        expect(pharmacy.address, equals('123 Avenue Test, Libreville'));
        expect(pharmacy.phone, equals('+241 01 23 45 67'));
        expect(pharmacy.email, equals('contact@pharmacie.ga'));
        expect(pharmacy.latitude, equals(0.4162));
        expect(pharmacy.longitude, equals(9.4673));
        expect(pharmacy.status, equals('active'));
        expect(pharmacy.isOpen, isTrue);
      });

      test('should create with null optional fields', () {
        final pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test Pharmacy',
          address: '456 Rue',
          phone: '+241 99 88 77 66',
          email: null,
          latitude: null,
          longitude: null,
          status: 'inactive',
          isOpen: false,
        );

        expect(pharmacy.email, isNull);
        expect(pharmacy.latitude, isNull);
        expect(pharmacy.longitude, isNull);
      });

      test('should handle closed pharmacy', () {
        final pharmacy = createPharmacy(isOpen: false);
        expect(pharmacy.isOpen, isFalse);
      });

      test('should handle various statuses', () {
        expect(createPharmacy(status: 'active').status, equals('active'));
        expect(createPharmacy(status: 'inactive').status, equals('inactive'));
        expect(createPharmacy(status: 'pending').status, equals('pending'));
        expect(createPharmacy(status: 'suspended').status, equals('suspended'));
      });
    });

    group('coordinates', () {
      test('should store latitude and longitude', () {
        final pharmacy = createPharmacy(latitude: 0.3924, longitude: 9.4536);
        expect(pharmacy.latitude, equals(0.3924));
        expect(pharmacy.longitude, equals(9.4536));
      });

      test('should handle negative coordinates', () {
        final pharmacy = createPharmacy(latitude: -0.1234, longitude: -9.5678);
        expect(pharmacy.latitude, equals(-0.1234));
        expect(pharmacy.longitude, equals(-9.5678));
      });

      test('should handle zero coordinates', () {
        final pharmacy = createPharmacy(latitude: 0.0, longitude: 0.0);
        expect(pharmacy.latitude, equals(0.0));
        expect(pharmacy.longitude, equals(0.0));
      });

      test('should handle null coordinates', () {
        final pharmacy = createPharmacy(latitude: null, longitude: null);
        expect(pharmacy.latitude, isNull);
        expect(pharmacy.longitude, isNull);
      });
    });

    group('contact info', () {
      test('should store phone number', () {
        final pharmacy = createPharmacy(phone: '+241 01 76 54 32');
        expect(pharmacy.phone, equals('+241 01 76 54 32'));
      });

      test('should store email', () {
        final pharmacy = createPharmacy(email: 'info@pharmacie-test.ga');
        expect(pharmacy.email, equals('info@pharmacie-test.ga'));
      });

      test('should allow null email', () {
        final pharmacy = createPharmacy(email: null);
        expect(pharmacy.email, isNull);
      });
    });

    group('equality', () {
      test('two pharmacies with same props should be equal', () {
        final pharmacy1 = createPharmacy();
        final pharmacy2 = createPharmacy();
        expect(pharmacy1, equals(pharmacy2));
      });

      test('two pharmacies with different ids should not be equal', () {
        final pharmacy1 = createPharmacy(id: 1);
        final pharmacy2 = createPharmacy(id: 2);
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different names should not be equal', () {
        final pharmacy1 = createPharmacy(name: 'Pharmacie A');
        final pharmacy2 = createPharmacy(name: 'Pharmacie B');
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different addresses should not be equal', () {
        final pharmacy1 = createPharmacy(address: 'Address 1');
        final pharmacy2 = createPharmacy(address: 'Address 2');
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different phones should not be equal', () {
        final pharmacy1 = createPharmacy(phone: '+241 01 11 11 11');
        final pharmacy2 = createPharmacy(phone: '+241 01 22 22 22');
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different statuses should not be equal', () {
        final pharmacy1 = createPharmacy(status: 'active');
        final pharmacy2 = createPharmacy(status: 'inactive');
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different isOpen should not be equal', () {
        final pharmacy1 = createPharmacy(isOpen: true);
        final pharmacy2 = createPharmacy(isOpen: false);
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different coordinates should not be equal', () {
        final pharmacy1 = createPharmacy(latitude: 0.4162);
        final pharmacy2 = createPharmacy(latitude: 0.5000);
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });

      test('two pharmacies with different emails should not be equal', () {
        final pharmacy1 = createPharmacy(email: 'a@test.com');
        final pharmacy2 = createPharmacy(email: 'b@test.com');
        expect(pharmacy1, isNot(equals(pharmacy2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final pharmacy = createPharmacy();
        expect(pharmacy.props.length, equals(9));
        expect(pharmacy.props[0], equals(1)); // id
        expect(pharmacy.props[1], equals('Pharmacie Centrale')); // name
        expect(pharmacy.props[2], equals('123 Avenue Test, Libreville')); // address
        expect(pharmacy.props[3], equals('+241 01 23 45 67')); // phone
        expect(pharmacy.props[4], equals('contact@pharmacie.ga')); // email
        expect(pharmacy.props[5], equals(0.4162)); // latitude
        expect(pharmacy.props[6], equals(9.4673)); // longitude
        expect(pharmacy.props[7], equals('active')); // status
        expect(pharmacy.props[8], equals(true)); // isOpen
      });

      test('should include null values in props', () {
        final pharmacy = createPharmacy(email: null, latitude: null, longitude: null);
        expect(pharmacy.props[4], isNull); // email
        expect(pharmacy.props[5], isNull); // latitude
        expect(pharmacy.props[6], isNull); // longitude
      });
    });

    group('hashCode', () {
      test('same pharmacies should have same hashCode', () {
        final pharmacy1 = createPharmacy();
        final pharmacy2 = createPharmacy();
        expect(pharmacy1.hashCode, equals(pharmacy2.hashCode));
      });

      test('different pharmacies should have different hashCodes', () {
        final pharmacy1 = createPharmacy(id: 1);
        final pharmacy2 = createPharmacy(id: 2);
        expect(pharmacy1.hashCode, isNot(equals(pharmacy2.hashCode)));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        final pharmacy = createPharmacy();
        final str = pharmacy.toString();
        expect(str, contains('PharmacyEntity'));
      });
    });

    group('pharmacy types', () {
      test('should handle different pharmacy names', () {
        expect(createPharmacy(name: 'Pharmacie du Carrefour').name, equals('Pharmacie du Carrefour'));
        expect(createPharmacy(name: 'Pharmacie des Cocotiers').name, equals('Pharmacie des Cocotiers'));
        expect(createPharmacy(name: 'Grande Pharmacie').name, equals('Grande Pharmacie'));
      });

      test('should handle long addresses', () {
        final longAddress = 'Centre Commercial, Niveau 2, Boutique 15, Boulevard Triomphal, Libreville, Gabon';
        final pharmacy = createPharmacy(address: longAddress);
        expect(pharmacy.address, equals(longAddress));
      });
    });
  });
}
