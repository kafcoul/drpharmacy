import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/data/models/delivery_address_model.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

void main() {
  group('DeliveryAddressModel', () {
    group('creation', () {
      test('should create with all required fields', () {
        const model = DeliveryAddressModel(
          address: '123 Rue Test, Libreville',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        expect(model.address, equals('123 Rue Test, Libreville'));
        expect(model.city, equals('Libreville'));
        expect(model.latitude, equals(0.4162));
        expect(model.longitude, equals(9.4673));
        expect(model.phone, equals('+241 01 23 45 67'));
      });

      test('should create with null optional fields', () {
        const model = DeliveryAddressModel(
          address: '456 Rue Simple',
          city: null,
          latitude: null,
          longitude: null,
          phone: null,
        );

        expect(model.address, equals('456 Rue Simple'));
        expect(model.city, isNull);
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
        expect(model.phone, isNull);
      });

      test('should create with only address', () {
        const model = DeliveryAddressModel(address: 'Simple Address');
        
        expect(model.address, equals('Simple Address'));
        expect(model.city, isNull);
      });
    });

    group('fromJson', () {
      test('should parse complete JSON', () {
        final json = {
          'address': '123 Rue API',
          'city': 'Port-Gentil',
          'latitude': 0.7193,
          'longitude': 8.7815,
          'phone': '+241 99 88 77 66',
        };

        final model = DeliveryAddressModel.fromJson(json);

        expect(model.address, equals('123 Rue API'));
        expect(model.city, equals('Port-Gentil'));
        expect(model.latitude, equals(0.7193));
        expect(model.longitude, equals(8.7815));
        expect(model.phone, equals('+241 99 88 77 66'));
      });

      test('should parse JSON with null optional fields', () {
        final json = {
          'address': 'Minimal Address',
        };

        final model = DeliveryAddressModel.fromJson(json);

        expect(model.address, equals('Minimal Address'));
        expect(model.city, isNull);
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
        expect(model.phone, isNull);
      });

      test('should parse JSON with integer coordinates', () {
        final json = {
          'address': 'Test',
          'latitude': 1,
          'longitude': 9,
        };

        final model = DeliveryAddressModel.fromJson(json);

        expect(model.latitude, equals(1.0));
        expect(model.longitude, equals(9.0));
      });
    });

    group('toJson', () {
      test('should serialize all fields', () {
        const model = DeliveryAddressModel(
          address: '123 Rue Test',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        final json = model.toJson();

        expect(json['address'], equals('123 Rue Test'));
        expect(json['city'], equals('Libreville'));
        expect(json['latitude'], equals(0.4162));
        expect(json['longitude'], equals(9.4673));
        expect(json['phone'], equals('+241 01 23 45 67'));
      });

      test('should serialize null fields', () {
        const model = DeliveryAddressModel(address: 'Simple');

        final json = model.toJson();

        expect(json['address'], equals('Simple'));
        expect(json['city'], isNull);
        expect(json['latitude'], isNull);
        expect(json['longitude'], isNull);
        expect(json['phone'], isNull);
      });
    });

    group('toEntity', () {
      test('should convert to entity with all fields', () {
        const model = DeliveryAddressModel(
          address: '123 Rue Test',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        final entity = model.toEntity();

        expect(entity, isA<DeliveryAddressEntity>());
        expect(entity.address, equals('123 Rue Test'));
        expect(entity.city, equals('Libreville'));
        expect(entity.latitude, equals(0.4162));
        expect(entity.longitude, equals(9.4673));
        expect(entity.phone, equals('+241 01 23 45 67'));
      });

      test('should convert to entity with null fields', () {
        const model = DeliveryAddressModel(address: 'Simple Address');

        final entity = model.toEntity();

        expect(entity.address, equals('Simple Address'));
        expect(entity.city, isNull);
        expect(entity.latitude, isNull);
        expect(entity.longitude, isNull);
        expect(entity.phone, isNull);
      });
    });

    group('fromEntity', () {
      test('should create from entity with all fields', () {
        const entity = DeliveryAddressEntity(
          address: '123 Rue Entity',
          city: 'Franceville',
          latitude: 1.6333,
          longitude: 13.5833,
          phone: '+241 77 66 55 44',
        );

        final model = DeliveryAddressModel.fromEntity(entity);

        expect(model.address, equals('123 Rue Entity'));
        expect(model.city, equals('Franceville'));
        expect(model.latitude, equals(1.6333));
        expect(model.longitude, equals(13.5833));
        expect(model.phone, equals('+241 77 66 55 44'));
      });

      test('should create from entity with null fields', () {
        const entity = DeliveryAddressEntity(address: 'Simple Entity');

        final model = DeliveryAddressModel.fromEntity(entity);

        expect(model.address, equals('Simple Entity'));
        expect(model.city, isNull);
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
        expect(model.phone, isNull);
      });
    });

    group('roundtrip', () {
      test('toJson -> fromJson should preserve data', () {
        const original = DeliveryAddressModel(
          address: '123 Rue Roundtrip',
          city: 'Libreville',
          latitude: 0.4162,
          longitude: 9.4673,
          phone: '+241 01 23 45 67',
        );

        final json = original.toJson();
        final restored = DeliveryAddressModel.fromJson(json);

        expect(restored.address, equals(original.address));
        expect(restored.city, equals(original.city));
        expect(restored.latitude, equals(original.latitude));
        expect(restored.longitude, equals(original.longitude));
        expect(restored.phone, equals(original.phone));
      });

      test('toEntity -> fromEntity should preserve data', () {
        const original = DeliveryAddressModel(
          address: '456 Rue Roundtrip',
          city: 'Port-Gentil',
          latitude: 0.7193,
          longitude: 8.7815,
          phone: '+241 99 88 77 66',
        );

        final entity = original.toEntity();
        final restored = DeliveryAddressModel.fromEntity(entity);

        expect(restored.address, equals(original.address));
        expect(restored.city, equals(original.city));
        expect(restored.latitude, equals(original.latitude));
        expect(restored.longitude, equals(original.longitude));
        expect(restored.phone, equals(original.phone));
      });
    });
  });
}
