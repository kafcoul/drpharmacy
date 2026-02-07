import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('should parse complete user data', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Jean Test',
          'email': 'jean.test@example.com',
          'phone': '+24107123456',
          'role': 'customer',
          'address': 'Libreville, Gabon',
          'avatar': 'https://example.com/avatar.jpg',
          'email_verified_at': '2026-01-15T10:00:00.000000Z',
          'phone_verified_at': '2026-01-16T10:00:00.000000Z',
          'created_at': '2026-01-01T00:00:00.000000Z',
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Jean Test');
        expect(model.email, 'jean.test@example.com');
        expect(model.phone, '+24107123456');
        expect(model.role, 'customer');
        expect(model.address, 'Libreville, Gabon');
        expect(model.avatar, 'https://example.com/avatar.jpg');
        expect(model.emailVerifiedAt, '2026-01-15T10:00:00.000000Z');
        expect(model.phoneVerifiedAt, '2026-01-16T10:00:00.000000Z');
        expect(model.createdAt, '2026-01-01T00:00:00.000000Z');
      });

      test('should parse minimal user data', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'User Minimal',
          'email': 'minimal@test.com',
          'phone': '+24100000000',
        };

        // Act
        final model = UserModel.fromJson(json);

        // Assert
        expect(model.id, 2);
        expect(model.name, 'User Minimal');
        expect(model.email, 'minimal@test.com');
        expect(model.phone, '+24100000000');
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
          'id': 3,
          'name': 'Test User',
          'email': 'test@test.com',
          'phone': '+24111111111',
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
      test('should serialize complete user data', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'Jean Test',
          email: 'jean@test.com',
          phone: '+24107123456',
          role: 'customer',
          address: 'Libreville',
          avatar: 'https://example.com/avatar.jpg',
          emailVerifiedAt: '2026-01-15T10:00:00Z',
          phoneVerifiedAt: '2026-01-16T10:00:00Z',
          createdAt: '2026-01-01T00:00:00Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'Jean Test');
        expect(json['email'], 'jean@test.com');
        expect(json['phone'], '+24107123456');
        expect(json['email_verified_at'], '2026-01-15T10:00:00Z');
        expect(json['phone_verified_at'], '2026-01-16T10:00:00Z');
        expect(json['created_at'], '2026-01-01T00:00:00Z');
      });

      test('should serialize minimal user data', () {
        // Arrange
        final model = UserModel(
          id: 2,
          name: 'Minimal',
          email: 'min@test.com',
          phone: '+24100000000',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 2);
        expect(json['name'], 'Minimal');
        expect(json['email'], 'min@test.com');
        expect(json['phone'], '+24100000000');
      });
    });

    group('toEntity', () {
      test('should convert to UserEntity correctly', () {
        // Arrange
        final model = UserModel(
          id: 1,
          name: 'Jean Test',
          email: 'jean@test.com',
          phone: '+24107123456',
          address: 'Libreville, Gabon',
          avatar: 'https://example.com/avatar.jpg',
          emailVerifiedAt: '2026-01-15T10:00:00.000000Z',
          phoneVerifiedAt: '2026-01-16T10:00:00.000000Z',
          createdAt: '2026-01-01T00:00:00.000000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.name, 'Jean Test');
        expect(entity.email, 'jean@test.com');
        expect(entity.phone, '+24107123456');
        expect(entity.address, 'Libreville, Gabon');
        expect(entity.profilePicture, 'https://example.com/avatar.jpg');
        expect(entity.isEmailVerified, true);
        expect(entity.isPhoneVerified, true);
      });

      test('should handle unverified user', () {
        // Arrange
        final model = UserModel(
          id: 2,
          name: 'Unverified User',
          email: 'unverified@test.com',
          phone: '+24100000000',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.isEmailVerified, false);
        expect(entity.isPhoneVerified, false);
        expect(entity.address, isNull);
        expect(entity.profilePicture, isNull);
      });

      test('should parse dates correctly', () {
        // Arrange
        final model = UserModel(
          id: 3,
          name: 'Date Test',
          email: 'date@test.com',
          phone: '+24100000000',
          emailVerifiedAt: '2026-02-01T14:30:00.000000Z',
          createdAt: '2026-01-01T00:00:00.000000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.emailVerifiedAt?.year, 2026);
        expect(entity.emailVerifiedAt?.month, 2);
        expect(entity.emailVerifiedAt?.day, 1);
        expect(entity.createdAt.year, 2026);
      });
    });
  });
}
