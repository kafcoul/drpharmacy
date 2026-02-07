import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/addresses/data/models/address_model.dart';
import 'package:drpharma_client/features/addresses/domain/entities/address_entity.dart';

void main() {
  group('AddressModel', () {
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
        'id': 1,
        'label': 'Domicile',
        'address': '123 Rue de la Paix',
        'city': 'Libreville',
        'district': 'Akébé',
        'phone': '+24112345678',
        'instructions': 'Portail bleu',
        'latitude': 0.3924,
        'longitude': 9.4536,
        'is_default': true,
        'full_address': '123 Rue de la Paix, Akébé, Libreville',
        'has_coordinates': true,
        'created_at': '2024-01-15T10:00:00Z',
        'updated_at': '2024-01-15T10:00:00Z',
      };
    });

    group('fromJson', () {
      test('should create AddressModel from valid JSON', () {
        // Act
        final result = AddressModel.fromJson(validJson);

        // Assert
        expect(result.id, 1);
        expect(result.label, 'Domicile');
        expect(result.address, '123 Rue de la Paix');
        expect(result.city, 'Libreville');
        expect(result.district, 'Akébé');
        expect(result.phone, '+24112345678');
        expect(result.instructions, 'Portail bleu');
        expect(result.latitude, 0.3924);
        expect(result.longitude, 9.4536);
        expect(result.isDefault, isTrue);
        expect(result.fullAddress, '123 Rue de la Paix, Akébé, Libreville');
        expect(result.hasCoordinates, isTrue);
      });

      test('should handle null optional fields', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['city'] = null;
        json['district'] = null;
        json['phone'] = null;
        json['instructions'] = null;
        json['latitude'] = null;
        json['longitude'] = null;

        // Act
        final result = AddressModel.fromJson(json);

        // Assert
        expect(result.city, isNull);
        expect(result.district, isNull);
        expect(result.phone, isNull);
        expect(result.instructions, isNull);
        expect(result.latitude, isNull);
        expect(result.longitude, isNull);
      });

      test('should handle string latitude and longitude', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['latitude'] = '0.4123';
        json['longitude'] = '9.5678';

        // Act
        final result = AddressModel.fromJson(json);

        // Assert
        expect(result.latitude, 0.4123);
        expect(result.longitude, 9.5678);
      });

      test('should handle integer latitude and longitude', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['latitude'] = 1;
        json['longitude'] = 9;

        // Act
        final result = AddressModel.fromJson(json);

        // Assert
        expect(result.latitude, 1.0);
        expect(result.longitude, 9.0);
      });
    });

    group('toJson', () {
      test('should convert AddressModel to JSON', () {
        // Arrange
        final model = AddressModel.fromJson(validJson);

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], 1);
        expect(result['label'], 'Domicile');
        expect(result['address'], '123 Rue de la Paix');
        expect(result['is_default'], isTrue);
        expect(result['has_coordinates'], isTrue);
      });
    });

    group('toEntity', () {
      test('should convert AddressModel to AddressEntity', () {
        // Arrange
        final model = AddressModel.fromJson(validJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<AddressEntity>());
        expect(entity.id, 1);
        expect(entity.label, 'Domicile');
        expect(entity.address, '123 Rue de la Paix');
        expect(entity.city, 'Libreville');
        expect(entity.isDefault, isTrue);
        expect(entity.createdAt, isA<DateTime>());
        expect(entity.updatedAt, isA<DateTime>());
      });

      test('should preserve null values in entity', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['city'] = null;
        json['district'] = null;
        final model = AddressModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.city, isNull);
        expect(entity.district, isNull);
      });
    });

    group('fromEntity', () {
      test('should convert AddressEntity to AddressModel', () {
        // Arrange
        final entity = AddressEntity(
          id: 1,
          label: 'Bureau',
          address: '456 Avenue Test',
          city: 'Libreville',
          district: 'Centre',
          phone: '+24198765432',
          instructions: 'Immeuble vert',
          latitude: 0.4,
          longitude: 9.5,
          isDefault: false,
          fullAddress: '456 Avenue Test, Centre, Libreville',
          hasCoordinates: true,
          createdAt: DateTime(2024, 1, 15, 10, 0),
          updatedAt: DateTime(2024, 1, 15, 10, 0),
        );

        // Act
        final model = AddressModel.fromEntity(entity);

        // Assert
        expect(model.id, 1);
        expect(model.label, 'Bureau');
        expect(model.address, '456 Avenue Test');
        expect(model.city, 'Libreville');
        expect(model.isDefault, isFalse);
      });
    });
  });

  group('AddressEntity', () {
    late AddressEntity testEntity;

    setUp(() {
      testEntity = AddressEntity(
        id: 1,
        label: 'Domicile',
        address: '123 Rue de la Paix',
        city: 'Libreville',
        district: 'Akébé',
        phone: '+24112345678',
        instructions: 'Portail bleu',
        latitude: 0.3924,
        longitude: 9.4536,
        isDefault: true,
        fullAddress: '123 Rue de la Paix, Akébé, Libreville',
        hasCoordinates: true,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    group('copyWith', () {
      test('should create copy with modified label', () {
        // Act
        final copy = testEntity.copyWith(label: 'Bureau');

        // Assert
        expect(copy.label, 'Bureau');
        expect(copy.id, testEntity.id);
        expect(copy.address, testEntity.address);
      });

      test('should create copy with modified isDefault', () {
        // Act
        final copy = testEntity.copyWith(isDefault: false);

        // Assert
        expect(copy.isDefault, isFalse);
        expect(copy.label, testEntity.label);
      });

      test('should preserve all values when no changes', () {
        // Act
        final copy = testEntity.copyWith();

        // Assert
        expect(copy, equals(testEntity));
      });

      test('should create copy with modified coordinates', () {
        // Act
        final copy = testEntity.copyWith(
          latitude: 0.5,
          longitude: 9.6,
        );

        // Assert
        expect(copy.latitude, 0.5);
        expect(copy.longitude, 9.6);
        expect(copy.address, testEntity.address);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        final entity1 = testEntity;
        final entity2 = AddressEntity(
          id: 1,
          label: 'Domicile',
          address: '123 Rue de la Paix',
          city: 'Libreville',
          district: 'Akébé',
          phone: '+24112345678',
          instructions: 'Portail bleu',
          latitude: 0.3924,
          longitude: 9.4536,
          isDefault: true,
          fullAddress: '123 Rue de la Paix, Akébé, Libreville',
          hasCoordinates: true,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        // Assert
        expect(entity1, equals(entity2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final entity2 = testEntity.copyWith(id: 2);

        // Assert
        expect(testEntity, isNot(equals(entity2)));
      });

      test('should not be equal when label differs', () {
        // Arrange
        final entity2 = testEntity.copyWith(label: 'Bureau');

        // Assert
        expect(testEntity, isNot(equals(entity2)));
      });

      test('should have props list with all properties', () {
        // Assert
        expect(testEntity.props.length, 14);
      });
    });
  });

  group('StringToDoubleConverter', () {
    test('should convert null to null', () {
      // Arrange
      const converter = StringToDoubleConverter();

      // Act
      final result = converter.fromJson(null);

      // Assert
      expect(result, isNull);
    });

    test('should convert num to double', () {
      // Arrange
      const converter = StringToDoubleConverter();

      // Act
      final result = converter.fromJson(10);

      // Assert
      expect(result, 10.0);
    });

    test('should convert string to double', () {
      // Arrange
      const converter = StringToDoubleConverter();

      // Act
      final result = converter.fromJson('10.5');

      // Assert
      expect(result, 10.5);
    });

    test('should convert invalid string to null', () {
      // Arrange
      const converter = StringToDoubleConverter();

      // Act
      final result = converter.fromJson('invalid');

      // Assert
      expect(result, isNull);
    });

    test('toJson should return the value as-is', () {
      // Arrange
      const converter = StringToDoubleConverter();

      // Act
      final result = converter.toJson(10.5);

      // Assert
      expect(result, 10.5);
    });
  });
}
