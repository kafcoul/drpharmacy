import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/products/data/models/product_model.dart';
import 'package:drpharma_client/features/products/data/models/pharmacy_model.dart';
import 'package:drpharma_client/features/products/data/models/category_model.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';

void main() {
  group('ProductModel', () {
    late Map<String, dynamic> validJson;
    late PharmacyModel testPharmacy;

    setUp(() {
      testPharmacy = PharmacyModel(
        id: 1,
        name: 'Pharmacie Test',
        address: '123 Rue Test',
        phone: '+24112345678',
        email: 'test@pharmacy.com',
        latitude: 0.3924,
        longitude: 9.4536,
        status: 'active',
        isOpen: true,
      );

      validJson = {
        'id': 1,
        'name': 'Doliprane 1000mg',
        'description': 'Antalgique et antipyrétique',
        'price': 2500.0,
        'image_url': 'https://example.com/image.jpg',
        'stock_quantity': 50,
        'manufacturer': 'Sanofi',
        'requires_prescription': false,
        'pharmacy': {
          'id': 1,
          'name': 'Pharmacie Test',
          'address': '123 Rue Test',
          'phone': '+24112345678',
          'email': 'test@pharmacy.com',
          'latitude': 0.3924,
          'longitude': 9.4536,
          'status': 'active',
          'is_open': true,
        },
        'category': {
          'id': 1,
          'name': 'Médicaments',
          'description': 'Médicaments généraux',
        },
        'created_at': '2024-01-15T10:00:00Z',
        'updated_at': '2024-01-15T10:00:00Z',
      };
    });

    group('fromJson', () {
      test('should create ProductModel from valid JSON', () {
        // Act
        final result = ProductModel.fromJson(validJson);

        // Assert
        expect(result.id, 1);
        expect(result.name, 'Doliprane 1000mg');
        expect(result.description, 'Antalgique et antipyrétique');
        expect(result.price, 2500.0);
        expect(result.imageUrl, 'https://example.com/image.jpg');
        expect(result.stockQuantity, 50);
        expect(result.manufacturer, 'Sanofi');
        expect(result.requiresPrescription, isFalse);
      });

      test('should handle null optional fields', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['description'] = null;
        json['manufacturer'] = null;
        json['category'] = null;

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.description, isNull);
        expect(result.manufacturer, isNull);
        expect(result.category, isNull);
      });

      test('should handle string price', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['price'] = '3500.50';

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.price, 3500.50);
      });

      test('should handle null price as 0', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['price'] = null;

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.price, 0.0);
      });

      test('should handle category as string (legacy)', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['category'] = 'Médicaments';

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.category, isNotNull);
        expect(result.category!.name, 'Médicaments');
        expect(result.category!.id, 0);
      });

      test('should use image field when image_url is null', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['image_url'] = null;
        json['image'] = 'https://example.com/image2.jpg';

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.image, 'https://example.com/image2.jpg');
      });

      test('should default stock_quantity to 0', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json.remove('stock_quantity');

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.stockQuantity, 0);
      });

      test('should default requires_prescription to false', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json.remove('requires_prescription');

        // Act
        final result = ProductModel.fromJson(json);

        // Assert
        expect(result.requiresPrescription, isFalse);
      });
    });

    group('toJson', () {
      test('should convert ProductModel to JSON', () {
        // Arrange
        final model = ProductModel(
          id: 1,
          name: 'Doliprane',
          description: 'Test',
          price: 2500.0,
          imageUrl: 'https://example.com/image.jpg',
          stockQuantity: 50,
          manufacturer: 'Sanofi',
          requiresPrescription: false,
          pharmacy: testPharmacy,
          category: CategoryModel(id: 1, name: 'Test', description: null),
          createdAt: '2024-01-15T10:00:00Z',
          updatedAt: '2024-01-15T10:00:00Z',
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], 1);
        expect(result['name'], 'Doliprane');
        expect(result['price'], 2500.0);
        expect(result['stock_quantity'], 50);
        expect(result['requires_prescription'], isFalse);
      });
    });

    group('toEntity', () {
      test('should convert ProductModel to ProductEntity', () {
        // Arrange
        final model = ProductModel.fromJson(validJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<ProductEntity>());
        expect(entity.id, 1);
        expect(entity.name, 'Doliprane 1000mg');
        expect(entity.price, 2500.0);
        expect(entity.stockQuantity, 50);
        expect(entity.requiresPrescription, isFalse);
        expect(entity.createdAt, isA<DateTime>());
        expect(entity.updatedAt, isA<DateTime>());
      });

      test('should use imageUrl in entity', () {
        // Arrange
        final model = ProductModel.fromJson(validJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.imageUrl, 'https://example.com/image.jpg');
      });

      test('should use image field when imageUrl is null', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['image_url'] = null;
        json['image'] = 'https://example.com/fallback.jpg';
        final model = ProductModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.imageUrl, 'https://example.com/fallback.jpg');
      });

      test('should convert pharmacy to entity', () {
        // Arrange
        final model = ProductModel.fromJson(validJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.pharmacy.id, 1);
        expect(entity.pharmacy.name, 'Pharmacie Test');
      });

      test('should convert category to entity when present', () {
        // Arrange
        final model = ProductModel.fromJson(validJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.category, isNotNull);
        expect(entity.category!.name, 'Médicaments');
      });

      test('should handle null category', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['category'] = null;
        final model = ProductModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.category, isNull);
      });
    });
  });

  group('ProductEntity', () {
    late ProductEntity testEntity;

    setUp(() {
      testEntity = ProductEntity(
        id: 1,
        name: 'Doliprane 1000mg',
        description: 'Antalgique',
        price: 2500.0,
        imageUrl: 'https://example.com/image.jpg',
        stockQuantity: 50,
        manufacturer: 'Sanofi',
        requiresPrescription: false,
        pharmacy: const PharmacyEntity(
          id: 1,
          name: 'Pharmacie Test',
          address: '123 Rue Test',
          phone: '+24112345678',
          email: 'test@pharmacy.com',
          latitude: 0.3924,
          longitude: 9.4536,
          status: 'active',
          isOpen: true,
        ),
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    group('isAvailable', () {
      test('should return true when stock is greater than 0', () {
        // Assert
        expect(testEntity.isAvailable, isTrue);
      });

      test('should return false when stock is 0', () {
        // Arrange
        final entity = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(entity.isAvailable, isFalse);
      });
    });

    group('isLowStock', () {
      test('should return true when stock is between 1 and 10', () {
        // Arrange
        final entity = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 5,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(entity.isLowStock, isTrue);
      });

      test('should return false when stock is greater than 10', () {
        // Assert
        expect(testEntity.isLowStock, isFalse);
      });

      test('should return false when stock is 0', () {
        // Arrange
        final entity = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(entity.isLowStock, isFalse);
      });

      test('should return true at stock boundary of 10', () {
        // Arrange
        final entity = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(entity.isLowStock, isTrue);
      });
    });

    group('isOutOfStock', () {
      test('should return true when stock is 0', () {
        // Arrange
        final entity = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(entity.isOutOfStock, isTrue);
      });

      test('should return false when stock is greater than 0', () {
        // Assert
        expect(testEntity.isOutOfStock, isFalse);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        final entity1 = testEntity;
        final entity2 = ProductEntity(
          id: 1,
          name: 'Doliprane 1000mg',
          description: 'Antalgique',
          price: 2500.0,
          imageUrl: 'https://example.com/image.jpg',
          stockQuantity: 50,
          manufacturer: 'Sanofi',
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        // Assert
        expect(entity1, equals(entity2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final entity2 = ProductEntity(
          id: 2,
          name: 'Doliprane 1000mg',
          description: 'Antalgique',
          price: 2500.0,
          stockQuantity: 50,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        // Assert
        expect(testEntity, isNot(equals(entity2)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        final entity2 = ProductEntity(
          id: 1,
          name: 'Efferalgan',
          description: 'Antalgique',
          price: 2500.0,
          stockQuantity: 50,
          requiresPrescription: false,
          pharmacy: testEntity.pharmacy,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        // Assert
        expect(testEntity, isNot(equals(entity2)));
      });

      test('should have props list with all properties', () {
        // Assert
        expect(testEntity.props.length, 12);
      });
    });
  });
}
