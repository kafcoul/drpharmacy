import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

void main() {
  group('DeliveryAddressEntity', () {
    group('creation', () {
      test('should create with all fields', () {
        const entity = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        expect(entity.address, equals('123 Rue Test'));
        expect(entity.city, equals('Libreville'));
        expect(entity.latitude, equals(0.4162));
        expect(entity.longitude, equals(9.4673));
        expect(entity.phone, equals('+241 01 23 45 67'));
      });

      test('should create with only required address', () {
        const entity = DeliveryAddressEntity(address: 'Simple Address');

        expect(entity.address, equals('Simple Address'));
        expect(entity.city, isNull);
        expect(entity.latitude, isNull);
        expect(entity.longitude, isNull);
        expect(entity.phone, isNull);
      });

      test('should create with partial optional fields', () {
        const entity = DeliveryAddressEntity(
          address: '456 Rue Partielle',
          city: 'Port-Gentil',
        );

        expect(entity.address, equals('456 Rue Partielle'));
        expect(entity.city, equals('Port-Gentil'));
        expect(entity.latitude, isNull);
        expect(entity.longitude, isNull);
        expect(entity.phone, isNull);
      });
    });

    group('fullAddress getter', () {
      test('should return address with city when city is present', () {
        const entity = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
        );

        expect(entity.fullAddress, equals('123 Rue Test, Libreville'));
      });

      test('should return only address when city is null', () {
        const entity = DeliveryAddressEntity(address: '123 Rue Test');

        expect(entity.fullAddress, equals('123 Rue Test'));
      });

      test('should format correctly with different cities', () {
        const entity1 = DeliveryAddressEntity(
          address: 'Avenue Nationale',
          city: 'Franceville',
        );
        const entity2 = DeliveryAddressEntity(
          address: 'Boulevard Maritime',
          city: 'Port-Gentil',
        );

        expect(entity1.fullAddress, equals('Avenue Nationale, Franceville'));
        expect(entity2.fullAddress, equals('Boulevard Maritime, Port-Gentil'));
      });
    });

    group('hasCoordinates getter', () {
      test('should return true when both latitude and longitude are present', () {
        const entity = DeliveryAddressEntity(
          address: 'Test',
          latitude: 0.4162,
          longitude: 9.4673,
        );

        expect(entity.hasCoordinates, isTrue);
      });

      test('should return false when latitude is null', () {
        const entity = DeliveryAddressEntity(
          address: 'Test',
          latitude: null,
          longitude: 9.4673,
        );

        expect(entity.hasCoordinates, isFalse);
      });

      test('should return false when longitude is null', () {
        const entity = DeliveryAddressEntity(
          address: 'Test',
          latitude: 0.4162,
          longitude: null,
        );

        expect(entity.hasCoordinates, isFalse);
      });

      test('should return false when both are null', () {
        const entity = DeliveryAddressEntity(address: 'Test');

        expect(entity.hasCoordinates, isFalse);
      });

      test('should return true with zero coordinates', () {
        const entity = DeliveryAddressEntity(
          address: 'Test',
          latitude: 0.0,
          longitude: 0.0,
        );

        expect(entity.hasCoordinates, isTrue);
      });

      test('should return true with negative coordinates', () {
        const entity = DeliveryAddressEntity(
          address: 'Test',
          latitude: -0.5,
          longitude: -10.5,
        );

        expect(entity.hasCoordinates, isTrue);
      });
    });

    group('equality', () {
      test('two entities with same props should be equal', () {
        const entity1 = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );
        const entity2 = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        expect(entity1, equals(entity2));
      });

      test('two entities with different addresses should not be equal', () {
        const entity1 = DeliveryAddressEntity(address: 'Address 1');
        const entity2 = DeliveryAddressEntity(address: 'Address 2');

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different cities should not be equal', () {
        const entity1 = DeliveryAddressEntity(address: 'Test', city: 'City 1');
        const entity2 = DeliveryAddressEntity(address: 'Test', city: 'City 2');

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different latitudes should not be equal', () {
        const entity1 = DeliveryAddressEntity(address: 'Test', latitude: 0.4);
        const entity2 = DeliveryAddressEntity(address: 'Test', latitude: 0.5);

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different longitudes should not be equal', () {
        const entity1 = DeliveryAddressEntity(address: 'Test', longitude: 9.4);
        const entity2 = DeliveryAddressEntity(address: 'Test', longitude: 9.5);

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different phones should not be equal', () {
        const entity1 = DeliveryAddressEntity(address: 'Test', phone: '111');
        const entity2 = DeliveryAddressEntity(address: 'Test', phone: '222');

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('props', () {
      test('should include all properties in correct order', () {
        const entity = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        expect(entity.props.length, equals(5));
        expect(entity.props[0], equals('123 Rue Test'));
        expect(entity.props[1], equals('Libreville'));
        expect(entity.props[2], equals(0.4162));
        expect(entity.props[3], equals(9.4673));
        expect(entity.props[4], equals('+241 01 23 45 67'));
      });

      test('should include null values in props', () {
        const entity = DeliveryAddressEntity(address: 'Test');

        expect(entity.props[1], isNull);
        expect(entity.props[2], isNull);
        expect(entity.props[3], isNull);
        expect(entity.props[4], isNull);
      });
    });

    group('hashCode', () {
      test('same entities should have same hashCode', () {
        const entity1 = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
        );
        const entity2 = DeliveryAddressEntity(
          address: '123 Rue Test',
          city: 'Libreville',
        );

        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('different entities should have different hashCodes', () {
        const entity1 = DeliveryAddressEntity(address: 'Address 1');
        const entity2 = DeliveryAddressEntity(address: 'Address 2');

        expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
      });
    });

    group('edge cases', () {
      test('should handle empty address', () {
        const entity = DeliveryAddressEntity(address: '');
        expect(entity.address, isEmpty);
        expect(entity.fullAddress, isEmpty);
      });

      test('should handle empty city', () {
        const entity = DeliveryAddressEntity(address: 'Test', city: '');
        expect(entity.fullAddress, equals('Test, '));
      });

      test('should handle very long addresses', () {
        const longAddress = 'Centre Commercial, Niveau 2, Boutique 15, Boulevard Triomphal, Quartier Louis, Libreville, Estuaire, Gabon';
        const entity = DeliveryAddressEntity(address: longAddress);
        expect(entity.address, equals(longAddress));
      });

      test('should handle special characters in address', () {
        const entity = DeliveryAddressEntity(
          address: "123 Rue de l'Église, Bât. A",
        );
        expect(entity.address, equals("123 Rue de l'Église, Bât. A"));
      });

      test('should handle address with numbers', () {
        const entity = DeliveryAddressEntity(
          address: '456 BP 12345',
          city: 'Libreville',
        );
        expect(entity.fullAddress, equals('456 BP 12345, Libreville'));
      });
    });
  });
}
