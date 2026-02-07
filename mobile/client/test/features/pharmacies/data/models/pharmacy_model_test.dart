import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/pharmacies/data/models/pharmacy_model.dart';
import 'package:drpharma_client/features/pharmacies/domain/entities/pharmacy_entity.dart';

void main() {
  group('PharmacyModel', () {
    group('fromJson', () {
      test('should parse complete pharmacy data', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Pharmacie du Centre',
          'address': '123 Rue Principale, Libreville',
          'phone': '+24107123456',
          'email': 'contact@pharmacie-centre.ga',
          'latitude': 0.4162,
          'longitude': 9.4673,
          'status': 'active',
          'is_open': true,
          'distance': 1.5,
          'opening_hours': '08:00 - 20:00',
          'description': 'Pharmacie moderne au centre-ville',
          'is_on_duty': false,
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Pharmacie du Centre');
        expect(model.address, '123 Rue Principale, Libreville');
        expect(model.phone, '+24107123456');
        expect(model.email, 'contact@pharmacie-centre.ga');
        expect(model.latitude, 0.4162);
        expect(model.longitude, 9.4673);
        expect(model.status, 'active');
        expect(model.isOpen, true);
        expect(model.distance, 1.5);
        expect(model.openingHours, '08:00 - 20:00');
        expect(model.description, 'Pharmacie moderne au centre-ville');
        expect(model.isOnDuty, false);
      });

      test('should parse pharmacy with duty info', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'Pharmacie de Garde',
          'address': 'Quartier Glass',
          'status': 'active',
          'is_open': true,
          'is_on_duty': true,
          'duty_info': {
            'type': 'night',
            'end_at': '2026-02-02T08:00:00Z',
          },
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.isOnDuty, true);
        expect(model.dutyType, 'night');
        expect(model.dutyEndAt, '2026-02-02T08:00:00Z');
      });

      test('should parse minimal pharmacy data', () {
        // Arrange
        final json = {
          'id': 3,
          'name': 'Pharmacie Test',
          'address': 'Adresse Test',
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.id, 3);
        expect(model.name, 'Pharmacie Test');
        expect(model.address, 'Adresse Test');
        expect(model.status, 'active'); // default
        expect(model.isOpen, false); // default
        expect(model.isOnDuty, false); // default
        expect(model.phone, isNull);
        expect(model.email, isNull);
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
      });

      test('should parse latitude/longitude from string', () {
        // Arrange
        final json = {
          'id': 4,
          'name': 'Test',
          'address': 'Test',
          'latitude': '0.4162',
          'longitude': '9.4673',
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.latitude, 0.4162);
        expect(model.longitude, 9.4673);
      });

      test('should handle invalid latitude/longitude values', () {
        // Arrange
        final json = {
          'id': 5,
          'name': 'Test',
          'address': 'Test',
          'latitude': 'invalid',
          'longitude': '',
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
      });

      test('should handle null string for coordinates', () {
        // Arrange
        final json = {
          'id': 6,
          'name': 'Test',
          'address': 'Test',
          'latitude': 'null',
          'longitude': null,
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
      });

      test('should parse distance from string', () {
        // Arrange
        final json = {
          'id': 7,
          'name': 'Test',
          'address': 'Test',
          'distance': '2.5',
        };

        // Act
        final model = PharmacyModel.fromJson(json);

        // Assert
        expect(model.distance, 2.5);
      });
    });

    group('toJson', () {
      test('should serialize complete pharmacy data', () {
        // Arrange
        final model = PharmacyModel(
          id: 1,
          name: 'Pharmacie Test',
          address: 'Libreville',
          phone: '+24107123456',
          email: 'test@test.com',
          latitude: 0.4162,
          longitude: 9.4673,
          status: 'active',
          isOpen: true,
          distance: 1.5,
          openingHours: '08:00 - 20:00',
          description: 'Description test',
          isOnDuty: false,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Pharmacie Test');
        expect(json['address'], 'Libreville');
        expect(json['phone'], '+24107123456');
        expect(json['latitude'], 0.4162);
        expect(json['longitude'], 9.4673);
        expect(json['is_open'], true);
        expect(json['is_on_duty'], false);
        expect(json['duty_info'], isNull);
      });

      test('should serialize pharmacy with duty info', () {
        // Arrange
        final model = PharmacyModel(
          id: 2,
          name: 'Pharmacie de Garde',
          address: 'Test',
          status: 'active',
          isOpen: true,
          isOnDuty: true,
          dutyType: 'night',
          dutyEndAt: '2026-02-02T08:00:00Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['is_on_duty'], true);
        expect(json['duty_info'], isNotNull);
        expect(json['duty_info']['type'], 'night');
        expect(json['duty_info']['end_at'], '2026-02-02T08:00:00Z');
      });
    });

    group('toEntity', () {
      test('should convert to PharmacyEntity correctly', () {
        // Arrange
        final model = PharmacyModel(
          id: 1,
          name: 'Pharmacie du Centre',
          address: 'Libreville',
          phone: '+24107123456',
          email: 'test@test.com',
          latitude: 0.4162,
          longitude: 9.4673,
          status: 'active',
          isOpen: true,
          distance: 1.5,
          openingHours: '08:00 - 20:00',
          description: 'Description',
          isOnDuty: true,
          dutyType: 'day',
          dutyEndAt: '2026-02-01T20:00:00Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.name, 'Pharmacie du Centre');
        expect(entity.address, 'Libreville');
        expect(entity.phone, '+24107123456');
        expect(entity.latitude, 0.4162);
        expect(entity.longitude, 9.4673);
        expect(entity.isOpen, true);
        expect(entity.isOnDuty, true);
        expect(entity.dutyType, 'day');
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        // Arrange
        const entity = PharmacyEntity(
          id: 1,
          name: 'Test Pharmacy',
          address: 'Test Address',
          phone: '+24107000000',
          status: 'active',
          isOpen: true,
          isOnDuty: false,
        );

        // Act
        final model = PharmacyModel.fromEntity(entity);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Test Pharmacy');
        expect(model.address, 'Test Address');
        expect(model.phone, '+24107000000');
        expect(model.status, 'active');
        expect(model.isOpen, true);
        expect(model.isOnDuty, false);
      });
    });
  });
}
