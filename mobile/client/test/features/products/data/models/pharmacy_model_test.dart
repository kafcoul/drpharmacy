import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/products/data/models/pharmacy_model.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';

void main() {
  group('PharmacyModel', () {
    group('creation', () {
      test('should create with all fields', () {
        final model = PharmacyModel(
          id: 1,
          name: 'Pharmacie Centrale',
          address: '123 Avenue Test, Libreville',
          phone: '+241 01 23 45 67',
          email: 'contact@pharmacie.ga',
          latitude: 0.4162,
          longitude: 9.4673,
          status: 'active',
          isOpen: true,
        );

        expect(model.id, equals(1));
        expect(model.name, equals('Pharmacie Centrale'));
        expect(model.address, equals('123 Avenue Test, Libreville'));
        expect(model.phone, equals('+241 01 23 45 67'));
        expect(model.email, equals('contact@pharmacie.ga'));
        expect(model.latitude, equals(0.4162));
        expect(model.longitude, equals(9.4673));
        expect(model.status, equals('active'));
        expect(model.isOpen, isTrue);
      });

      test('should create with null optional fields', () {
        final model = PharmacyModel(
          id: 2,
          name: 'Pharmacie Simple',
          address: '456 Rue',
          phone: '+241 99 88 77 66',
          email: null,
          latitude: null,
          longitude: null,
          status: 'inactive',
          isOpen: false,
        );

        expect(model.email, isNull);
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
        expect(model.isOpen, isFalse);
      });
    });

    group('fromJson', () {
      test('should parse complete JSON', () {
        final json = {
          'id': 1,
          'name': 'Pharmacie API',
          'address': '123 Rue API',
          'phone': '+241 11 22 33 44',
          'email': 'api@pharmacie.ga',
          'latitude': 0.5,
          'longitude': 9.5,
          'status': 'active',
          'is_open': true,
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.id, equals(1));
        expect(model.name, equals('Pharmacie API'));
        expect(model.latitude, equals(0.5));
        expect(model.longitude, equals(9.5));
        expect(model.isOpen, isTrue);
      });

      test('should parse JSON with string coordinates', () {
        final json = {
          'id': 2,
          'name': 'String Coords Pharmacy',
          'address': 'Address',
          'phone': 'Phone',
          'latitude': '0.4162',
          'longitude': '9.4673',
          'status': 'active',
          'is_open': true,
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.latitude, equals(0.4162));
        expect(model.longitude, equals(9.4673));
      });

      test('should parse JSON with integer coordinates', () {
        final json = {
          'id': 3,
          'name': 'Int Coords Pharmacy',
          'address': 'Address',
          'phone': 'Phone',
          'latitude': 1,
          'longitude': 9,
          'status': 'active',
          'is_open': false,
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.latitude, equals(1.0));
        expect(model.longitude, equals(9.0));
      });

      test('should use default status when missing', () {
        final json = {
          'id': 4,
          'name': 'No Status Pharmacy',
          'address': 'Address',
          'phone': 'Phone',
          'is_open': true,
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.status, equals('active'));
      });

      test('should use default isOpen false when missing', () {
        final json = {
          'id': 5,
          'name': 'No isOpen Pharmacy',
          'address': 'Address',
          'phone': 'Phone',
          'status': 'active',
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.isOpen, isFalse);
      });

      test('should parse JSON with null optional fields', () {
        final json = {
          'id': 6,
          'name': 'Minimal Pharmacy',
          'address': 'Minimal Address',
          'phone': '+241 00 00 00 00',
          'email': null,
          'latitude': null,
          'longitude': null,
          'status': 'pending',
          'is_open': false,
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.email, isNull);
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
      });

      test('should handle invalid string coordinates', () {
        final json = {
          'id': 7,
          'name': 'Invalid Coords',
          'address': 'Address',
          'phone': 'Phone',
          'latitude': 'invalid',
          'longitude': 'not_a_number',
          'status': 'active',
          'is_open': true,
        };

        final model = PharmacyModel.fromJson(json);

        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields', () {
        final model = PharmacyModel(
          id: 1,
          name: 'Serialize Test',
          address: 'Test Address',
          phone: '+241 55 66 77 88',
          email: 'test@email.com',
          latitude: 0.4,
          longitude: 9.4,
          status: 'active',
          isOpen: true,
        );

        final json = model.toJson();

        expect(json['id'], equals(1));
        expect(json['name'], equals('Serialize Test'));
        expect(json['address'], equals('Test Address'));
        expect(json['phone'], equals('+241 55 66 77 88'));
        expect(json['email'], equals('test@email.com'));
        expect(json['latitude'], equals(0.4));
        expect(json['longitude'], equals(9.4));
        expect(json['status'], equals('active'));
        expect(json['is_open'], equals(true));
      });

      test('should serialize null fields', () {
        final model = PharmacyModel(
          id: 2,
          name: 'Null Fields',
          address: 'Address',
          phone: 'Phone',
          email: null,
          latitude: null,
          longitude: null,
          status: 'inactive',
          isOpen: false,
        );

        final json = model.toJson();

        expect(json['email'], isNull);
        expect(json['latitude'], isNull);
        expect(json['longitude'], isNull);
      });
    });

    group('toEntity', () {
      test('should convert to PharmacyEntity with all fields', () {
        final model = PharmacyModel(
          id: 1,
          name: 'Entity Pharmacy',
          address: 'Entity Address',
          phone: '+241 77 88 99 00',
          email: 'entity@pharmacie.ga',
          latitude: 0.5,
          longitude: 9.5,
          status: 'active',
          isOpen: true,
        );

        final entity = model.toEntity();

        expect(entity, isA<PharmacyEntity>());
        expect(entity.id, equals(1));
        expect(entity.name, equals('Entity Pharmacy'));
        expect(entity.address, equals('Entity Address'));
        expect(entity.phone, equals('+241 77 88 99 00'));
        expect(entity.email, equals('entity@pharmacie.ga'));
        expect(entity.latitude, equals(0.5));
        expect(entity.longitude, equals(9.5));
        expect(entity.status, equals('active'));
        expect(entity.isOpen, isTrue);
      });

      test('should convert to entity with null fields', () {
        final model = PharmacyModel(
          id: 2,
          name: 'Null Entity',
          address: 'Address',
          phone: 'Phone',
          email: null,
          latitude: null,
          longitude: null,
          status: 'inactive',
          isOpen: false,
        );

        final entity = model.toEntity();

        expect(entity.email, isNull);
        expect(entity.latitude, isNull);
        expect(entity.longitude, isNull);
        expect(entity.isOpen, isFalse);
      });
    });

    group('roundtrip', () {
      test('toJson -> fromJson should preserve data', () {
        final original = PharmacyModel(
          id: 99,
          name: 'Roundtrip Pharmacy',
          address: 'Roundtrip Address',
          phone: '+241 11 22 33 44',
          email: 'roundtrip@email.com',
          latitude: 0.6,
          longitude: 9.6,
          status: 'active',
          isOpen: true,
        );

        final json = original.toJson();
        final restored = PharmacyModel.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.address, equals(original.address));
        expect(restored.phone, equals(original.phone));
        expect(restored.email, equals(original.email));
        expect(restored.latitude, equals(original.latitude));
        expect(restored.longitude, equals(original.longitude));
        expect(restored.status, equals(original.status));
        expect(restored.isOpen, equals(original.isOpen));
      });
    });

    group('status values', () {
      test('should handle active status', () {
        final model = PharmacyModel(
          id: 1,
          name: 'Active',
          address: 'A',
          phone: 'P',
          status: 'active',
          isOpen: true,
        );
        expect(model.status, equals('active'));
      });

      test('should handle inactive status', () {
        final model = PharmacyModel(
          id: 2,
          name: 'Inactive',
          address: 'A',
          phone: 'P',
          status: 'inactive',
          isOpen: false,
        );
        expect(model.status, equals('inactive'));
      });

      test('should handle pending status', () {
        final model = PharmacyModel(
          id: 3,
          name: 'Pending',
          address: 'A',
          phone: 'P',
          status: 'pending',
          isOpen: false,
        );
        expect(model.status, equals('pending'));
      });

      test('should handle suspended status', () {
        final model = PharmacyModel(
          id: 4,
          name: 'Suspended',
          address: 'A',
          phone: 'P',
          status: 'suspended',
          isOpen: false,
        );
        expect(model.status, equals('suspended'));
      });
    });
  });
}
