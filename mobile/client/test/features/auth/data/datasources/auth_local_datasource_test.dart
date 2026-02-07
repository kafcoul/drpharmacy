import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drpharma_client/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:drpharma_client/features/auth/data/models/user_model.dart';
import 'package:drpharma_client/core/constants/app_constants.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late SharedPreferences sharedPreferences;

  UserModel createTestUser({
    int id = 1,
    String name = 'John Doe',
    String email = 'john@example.com',
    String phone = '0123456789',
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    dataSource = AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  });

  group('AuthLocalDataSource', () {
    group('interface', () {
      test('AuthLocalDataSourceImpl should implement AuthLocalDataSource', () {
        expect(dataSource, isA<AuthLocalDataSource>());
      });
    });

    group('cacheUser', () {
      test('should save user to SharedPreferences', () async {
        // Arrange
        final user = createTestUser();

        // Act
        await dataSource.cacheUser(user);

        // Assert
        final savedJson = sharedPreferences.getString(AppConstants.userKey);
        expect(savedJson, isNotNull);
      });

      test('should save user with correct JSON format', () async {
        // Arrange
        final user = createTestUser(
          id: 42,
          name: 'Jane Smith',
          email: 'jane@test.com',
          phone: '0987654321',
        );

        // Act
        await dataSource.cacheUser(user);

        // Assert
        final savedJson = sharedPreferences.getString(AppConstants.userKey);
        final decodedJson = jsonDecode(savedJson!);
        expect(decodedJson['id'], 42);
        expect(decodedJson['name'], 'Jane Smith');
        expect(decodedJson['email'], 'jane@test.com');
        expect(decodedJson['phone'], '0987654321');
      });

      test('should overwrite existing user when caching new one', () async {
        // Arrange
        final user1 = createTestUser(id: 1, name: 'User 1');
        final user2 = createTestUser(id: 2, name: 'User 2');

        // Act
        await dataSource.cacheUser(user1);
        await dataSource.cacheUser(user2);

        // Assert
        final savedJson = sharedPreferences.getString(AppConstants.userKey);
        final decodedJson = jsonDecode(savedJson!);
        expect(decodedJson['id'], 2);
        expect(decodedJson['name'], 'User 2');
      });
    });

    group('getCachedUser', () {
      test('should return null when no user is cached', () async {
        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isNull);
      });

      test('should return cached user when available', () async {
        // Arrange
        final user = createTestUser(
          id: 123,
          name: 'Cached User',
          email: 'cached@test.com',
          phone: '5551234567',
        );
        await dataSource.cacheUser(user);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 123);
        expect(result.name, 'Cached User');
        expect(result.email, 'cached@test.com');
        expect(result.phone, '5551234567');
      });

      test('should return UserModel instance', () async {
        // Arrange
        final user = createTestUser();
        await dataSource.cacheUser(user);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isA<UserModel>());
      });

      test('should return user with all optional fields', () async {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Full User',
          email: 'full@test.com',
          phone: '1234567890',
          address: '123 Main St',
          avatar: 'https://example.com/avatar.jpg',
          emailVerifiedAt: '2024-01-01T00:00:00Z',
          phoneVerifiedAt: '2024-01-02T00:00:00Z',
          createdAt: '2024-01-03T00:00:00Z',
        );
        await dataSource.cacheUser(user);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result!.address, '123 Main St');
        expect(result.avatar, 'https://example.com/avatar.jpg');
      });
    });

    group('clearUser', () {
      test('should remove cached user from SharedPreferences', () async {
        // Arrange
        final user = createTestUser();
        await dataSource.cacheUser(user);
        expect(sharedPreferences.getString(AppConstants.userKey), isNotNull);

        // Act
        await dataSource.clearUser();

        // Assert
        expect(sharedPreferences.getString(AppConstants.userKey), isNull);
      });

      test('should not throw when no user is cached', () async {
        // Act & Assert
        await expectLater(dataSource.clearUser(), completes);
      });

      test('getCachedUser should return null after clearUser', () async {
        // Arrange
        final user = createTestUser();
        await dataSource.cacheUser(user);

        // Act
        await dataSource.clearUser();
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('clearAll', () {
      // NOTE: clearAll tests are skipped because they depend on SecureStorageService
      // which requires platform channels that are not available in unit tests.
      // These would be tested in integration tests instead.

      test('should be callable', () async {
        // Just verify the method exists and is callable
        expect(dataSource.clearAll, isA<Function>());
      });
    });

    group('constructor', () {
      test('should create instance with SharedPreferences', () {
        final ds = AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
        expect(ds, isNotNull);
      });
    });

    group('integration scenarios', () {
      test('should handle cache -> get -> clear -> get flow', () async {
        // Cache user
        final user = createTestUser(id: 100, name: 'Flow Test');
        await dataSource.cacheUser(user);

        // Get user
        var result = await dataSource.getCachedUser();
        expect(result?.id, 100);

        // Clear user
        await dataSource.clearUser();

        // Get user again
        result = await dataSource.getCachedUser();
        expect(result, isNull);
      });

      test('should handle multiple cache operations', () async {
        // Cache multiple times
        for (var i = 0; i < 5; i++) {
          await dataSource.cacheUser(createTestUser(id: i, name: 'User $i'));
        }

        // Only last user should be stored
        final result = await dataSource.getCachedUser();
        expect(result?.id, 4);
        expect(result?.name, 'User 4');
      });

      test('should handle unicode characters in user data', () async {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Жан-Пьер Дюпон',
          email: 'jean@example.com',
          phone: '+33123456789',
          address: '12 Rue de la Paix, Paris 🇫🇷',
        );

        // Act
        await dataSource.cacheUser(user);
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result?.name, 'Жан-Пьер Дюпон');
        expect(result?.address, '12 Rue de la Paix, Paris 🇫🇷');
      });

      test('should handle special characters in email', () async {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Test User',
          email: 'test+special_chars@example.com',
          phone: '1234567890',
        );

        // Act
        await dataSource.cacheUser(user);
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result?.email, 'test+special_chars@example.com');
      });
    });
  });
}
