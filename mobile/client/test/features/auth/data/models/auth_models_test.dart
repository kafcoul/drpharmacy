import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/auth/data/models/user_model.dart';
import 'package:drpharma_client/features/auth/data/models/auth_response_model.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('should correctly parse complete user data', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+24177123456',
          'role': 'customer',
          'address': '123 Rue Test, Libreville',
          'avatar': 'https://example.com/avatar.jpg',
          'email_verified_at': '2024-01-15T10:00:00.000Z',
          'phone_verified_at': '2024-01-15T11:00:00.000Z',
          'created_at': '2024-01-01T00:00:00.000Z',
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'John Doe');
        expect(model.email, 'john@example.com');
        expect(model.phone, '+24177123456');
        expect(model.role, 'customer');
        expect(model.address, '123 Rue Test, Libreville');
        expect(model.avatar, isNotEmpty);
        expect(model.emailVerifiedAt, isNotNull);
        expect(model.phoneVerifiedAt, isNotNull);
        expect(model.createdAt, isNotNull);
      });

      test('should correctly parse minimal user data', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+24177123456',
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'John Doe');
        expect(model.role, isNull);
        expect(model.address, isNull);
        expect(model.avatar, isNull);
        expect(model.emailVerifiedAt, isNull);
        expect(model.phoneVerifiedAt, isNull);
        expect(model.createdAt, isNull);
      });

      test('should handle null optional fields', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'phone': '+24177654321',
          'role': null,
          'address': null,
          'avatar': null,
          'email_verified_at': null,
          'phone_verified_at': null,
          'created_at': null,
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.role, isNull);
        expect(model.address, isNull);
        expect(model.avatar, isNull);
        expect(model.emailVerifiedAt, isNull);
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          role: 'customer',
          address: '123 Rue Test',
          avatar: 'https://example.com/avatar.jpg',
          emailVerifiedAt: '2024-01-15T10:00:00.000Z',
          phoneVerifiedAt: '2024-01-15T11:00:00.000Z',
          createdAt: '2024-01-01T00:00:00.000Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@example.com');
        expect(json['phone'], '+24177123456');
        expect(json['role'], 'customer');
        expect(json['address'], '123 Rue Test');
        expect(json['avatar'], isNotEmpty);
        expect(json['email_verified_at'], isNotNull);
        expect(json['phone_verified_at'], isNotNull);
        expect(json['created_at'], isNotNull);
      });

      test('should handle null optional fields in serialization', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['role'], isNull);
        expect(json['address'], isNull);
        expect(json['avatar'], isNull);
      });
    });

    group('toEntity', () {
      test('should correctly convert to UserEntity', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          address: '123 Rue Test',
          avatar: 'https://example.com/avatar.jpg',
          emailVerifiedAt: '2024-01-15T10:00:00.000Z',
          phoneVerifiedAt: '2024-01-15T11:00:00.000Z',
          createdAt: '2024-01-01T00:00:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<UserEntity>());
        expect(entity.id, 1);
        expect(entity.name, 'John Doe');
        expect(entity.email, 'john@example.com');
        expect(entity.phone, '+24177123456');
        expect(entity.address, '123 Rue Test');
        expect(entity.profilePicture, 'https://example.com/avatar.jpg');
        expect(entity.emailVerifiedAt, isNotNull);
        expect(entity.phoneVerifiedAt, isNotNull);
        expect(entity.createdAt.year, 2024);
        expect(entity.createdAt.month, 1);
        expect(entity.createdAt.day, 1);
      });

      test('should handle null dates in conversion', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.emailVerifiedAt, isNull);
        expect(entity.phoneVerifiedAt, isNull);
        expect(entity.createdAt, isNotNull); // Default to DateTime.now()
      });

      test('should correctly map avatar to profilePicture', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          avatar: 'https://example.com/my-avatar.jpg',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.profilePicture, 'https://example.com/my-avatar.jpg');
      });

      test('should correctly map address field', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          address: '456 Avenue Test, Libreville',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.address, '456 Avenue Test, Libreville');
      });
    });

    group('Roundtrip', () {
      test('should maintain data through JSON roundtrip', () {
        // Arrange
        final originalJson = {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+24177123456',
          'role': 'customer',
          'address': '123 Rue Test',
          'avatar': 'https://example.com/avatar.jpg',
          'email_verified_at': '2024-01-15T10:00:00.000Z',
          'phone_verified_at': '2024-01-15T11:00:00.000Z',
          'created_at': '2024-01-01T00:00:00.000Z',
        };

        // Act
        final model = UserModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['name'], originalJson['name']);
        expect(resultJson['email'], originalJson['email']);
        expect(resultJson['phone'], originalJson['phone']);
        expect(resultJson['role'], originalJson['role']);
        expect(resultJson['address'], originalJson['address']);
        expect(resultJson['avatar'], originalJson['avatar']);
      });
    });
  });

  group('AuthResponseModel', () {
    group('fromJson', () {
      test('should correctly parse auth response', () {
        // Arrange
        final json = {
          'user': {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'phone': '+24177123456',
          },
          'token': 'jwt_token_12345',
        };

        // Act
        final model = AuthResponseModel.fromJson(json);

        // Assert
        expect(model.token, 'jwt_token_12345');
        expect(model.user.id, 1);
        expect(model.user.name, 'John Doe');
      });

      test('should correctly parse auth response with full user data', () {
        // Arrange
        final json = {
          'user': {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'phone': '+24177123456',
            'role': 'customer',
            'address': '123 Rue Test',
            'avatar': 'https://example.com/avatar.jpg',
            'email_verified_at': '2024-01-15T10:00:00.000Z',
            'phone_verified_at': '2024-01-15T11:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
          },
          'token': 'jwt_token_67890',
        };

        // Act
        final model = AuthResponseModel.fromJson(json);

        // Assert
        expect(model.token, 'jwt_token_67890');
        expect(model.user.role, 'customer');
        expect(model.user.address, '123 Rue Test');
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON', () {
        // Arrange
        final model = AuthResponseModel(
          user: UserModel(
            id: 1,
            name: 'John Doe',
            email: 'john@example.com',
            phone: '+24177123456',
          ),
          token: 'test_token',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['token'], 'test_token');
        expect(json['user'], isNotNull);
      });
    });

    group('toEntity', () {
      test('should correctly convert to AuthResponseEntity', () {
        // Arrange
        final model = AuthResponseModel(
          user: UserModel(
            id: 1,
            name: 'John Doe',
            email: 'john@example.com',
            phone: '+24177123456',
          ),
          token: 'jwt_token_test',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.token, 'jwt_token_test');
        expect(entity.user.id, 1);
        expect(entity.user.name, 'John Doe');
      });

      test('should correctly convert nested user to entity', () {
        // Arrange
        final model = AuthResponseModel(
          user: UserModel(
            id: 1,
            name: 'John Doe',
            email: 'john@example.com',
            phone: '+24177123456',
            avatar: 'https://example.com/avatar.jpg',
            address: '123 Rue Test',
          ),
          token: 'jwt_token_test',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.user.profilePicture, 'https://example.com/avatar.jpg');
        expect(entity.user.address, '123 Rue Test');
      });
    });
  });
}
