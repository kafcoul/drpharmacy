import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/profile/data/models/profile_model.dart';
import 'package:drpharma_client/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('ProfileModel', () {
    const testJsonComplete = {
      'id': 1,
      'name': 'Jean Dupont',
      'email': 'jean.dupont@example.com',
      'phone': '+2250700000000',
      'avatar': 'https://example.com/avatar.jpg',
      'default_address': 'Cocody, Abidjan',
      'created_at': '2024-01-15T10:30:00.000Z',
      'total_orders': 10,
      'completed_orders': 8,
      'total_spent': 150000.0,
    };

    const testJsonMinimal = {
      'id': 2,
      'name': 'Marie Martin',
      'email': 'marie@example.com',
      'created_at': '2024-01-10T08:00:00.000Z',
    };

    group('fromJson', () {
      test('should create model from complete JSON', () {
        // Act
        final model = ProfileModel.fromJson(testJsonComplete);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Jean Dupont');
        expect(model.email, 'jean.dupont@example.com');
        expect(model.phone, '+2250700000000');
        expect(model.avatar, 'https://example.com/avatar.jpg');
        expect(model.defaultAddress, 'Cocody, Abidjan');
        expect(model.totalOrders, 10);
        expect(model.completedOrders, 8);
        expect(model.totalSpent, 150000.0);
      });

      test('should create model from minimal JSON', () {
        // Act
        final model = ProfileModel.fromJson(testJsonMinimal);

        // Assert
        expect(model.id, 2);
        expect(model.name, 'Marie Martin');
        expect(model.email, 'marie@example.com');
        expect(model.phone, isNull);
        expect(model.avatar, isNull);
        expect(model.defaultAddress, isNull);
        expect(model.totalOrders, isNull);
        expect(model.completedOrders, isNull);
      });

      test('should handle total_spent as string', () {
        final json = {...testJsonComplete, 'total_spent': '250000.50'};
        final model = ProfileModel.fromJson(json);
        expect(model.totalSpent, '250000.50');
      });

      test('should handle total_spent as int', () {
        final json = {...testJsonComplete, 'total_spent': 300000};
        final model = ProfileModel.fromJson(json);
        expect(model.totalSpent, 300000);
      });

      test('should handle null total_spent', () {
        final json = {...testJsonComplete, 'total_spent': null};
        final model = ProfileModel.fromJson(json);
        expect(model.totalSpent, isNull);
      });
    });

    group('toJson', () {
      test('should convert complete model to JSON', () {
        // Arrange
        final model = ProfileModel(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          phone: '+2250700000000',
          avatar: 'https://example.com/avatar.jpg',
          defaultAddress: 'Abidjan',
          createdAt: '2024-01-15T10:00:00.000Z',
          totalOrders: 5,
          completedOrders: 4,
          totalSpent: 50000.0,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Test User');
        expect(json['email'], 'test@example.com');
        expect(json['phone'], '+2250700000000');
        expect(json['avatar'], 'https://example.com/avatar.jpg');
        expect(json['default_address'], 'Abidjan');
        expect(json['total_orders'], 5);
        expect(json['completed_orders'], 4);
        expect(json['total_spent'], 50000.0);
      });

      test('should convert minimal model to JSON with nulls', () {
        // Arrange
        final model = ProfileModel(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: '2024-01-15T10:00:00.000Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['phone'], isNull);
        expect(json['avatar'], isNull);
        expect(json['default_address'], isNull);
      });
    });

    group('toEntity', () {
      test('should convert complete model to entity', () {
        // Arrange
        final model = ProfileModel.fromJson(testJsonComplete);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<ProfileEntity>());
        expect(entity.id, 1);
        expect(entity.name, 'Jean Dupont');
        expect(entity.email, 'jean.dupont@example.com');
        expect(entity.phone, '+2250700000000');
        expect(entity.avatar, 'https://example.com/avatar.jpg');
        expect(entity.totalOrders, 10);
        expect(entity.completedOrders, 8);
        expect(entity.totalSpent, 150000.0);
      });

      test('should convert minimal model to entity with defaults', () {
        // Arrange
        final model = ProfileModel.fromJson(testJsonMinimal);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.phone, isNull);
        expect(entity.avatar, isNull);
        expect(entity.totalOrders, 0);
        expect(entity.completedOrders, 0);
        expect(entity.totalSpent, 0.0);
      });

      test('should parse totalSpent from string', () {
        // Arrange
        final model = ProfileModel(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: '2024-01-15T10:00:00.000Z',
          totalSpent: '125000.75',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.totalSpent, 125000.75);
      });

      test('should parse totalSpent from int', () {
        // Arrange
        final model = ProfileModel(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: '2024-01-15T10:00:00.000Z',
          totalSpent: 100000,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.totalSpent, 100000.0);
      });

      test('should handle invalid totalSpent string', () {
        // Arrange
        final model = ProfileModel(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: '2024-01-15T10:00:00.000Z',
          totalSpent: 'invalid',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.totalSpent, 0.0);
      });

      test('should parse createdAt correctly', () {
        // Arrange
        final model = ProfileModel.fromJson(testJsonComplete);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.createdAt.year, 2024);
        expect(entity.createdAt.month, 1);
        expect(entity.createdAt.day, 15);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        // Arrange
        final entity = ProfileEntity(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          phone: '+2250700000000',
          avatar: 'https://example.com/avatar.jpg',
          defaultAddress: 'Cocody',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          totalOrders: 15,
          completedOrders: 12,
          totalSpent: 200000.0,
        );

        // Act
        final model = ProfileModel.fromEntity(entity);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Test User');
        expect(model.email, 'test@example.com');
        expect(model.phone, '+2250700000000');
        expect(model.totalOrders, 15);
        expect(model.totalSpent, 200000.0);
      });

      test('should handle entity with minimal data', () {
        // Arrange
        final entity = ProfileEntity(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: DateTime(2024, 1, 15),
          totalOrders: 0,
          completedOrders: 0,
          totalSpent: 0.0,
        );

        // Act
        final model = ProfileModel.fromEntity(entity);

        // Assert
        expect(model.phone, isNull);
        expect(model.avatar, isNull);
        expect(model.defaultAddress, isNull);
      });

      test('should format createdAt as ISO8601', () {
        // Arrange
        final entity = ProfileEntity(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: DateTime(2024, 6, 15, 14, 30, 0),
          totalOrders: 0,
          completedOrders: 0,
          totalSpent: 0.0,
        );

        // Act
        final model = ProfileModel.fromEntity(entity);

        // Assert
        expect(model.createdAt, contains('2024-06-15'));
      });
    });

    group('constructor', () {
      test('should create model with required fields only', () {
        final model = ProfileModel(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: '2024-01-15T10:00:00.000Z',
        );

        expect(model.id, 1);
        expect(model.phone, isNull);
        expect(model.avatar, isNull);
        expect(model.totalOrders, isNull);
      });

      test('should create model with all fields', () {
        final model = ProfileModel(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          phone: '+2250700000000',
          avatar: 'avatar.jpg',
          defaultAddress: 'Address',
          createdAt: '2024-01-15T10:00:00.000Z',
          totalOrders: 10,
          completedOrders: 8,
          totalSpent: 50000.0,
        );

        expect(model.totalOrders, 10);
        expect(model.completedOrders, 8);
        expect(model.totalSpent, 50000.0);
      });
    });
  });
}
