import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmacy_flutter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pharmacy_flutter/features/auth/data/models/user_model.dart';
import 'package:pharmacy_flutter/core/constants/app_constants.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late AuthLocalDataSourceImpl dataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = AuthLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('cacheToken', () {
    test('should cache token in shared preferences', () async {
      const token = 'test-jwt-token';
      when(() => mockSharedPreferences.setString(AppConstants.tokenKey, token))
          .thenAnswer((_) async => true);

      await dataSource.cacheToken(token);

      verify(() => mockSharedPreferences.setString(AppConstants.tokenKey, token)).called(1);
    });
  });

  group('getToken', () {
    test('should return cached token when present', () async {
      const token = 'cached-token';
      when(() => mockSharedPreferences.getString(AppConstants.tokenKey))
          .thenReturn(token);

      final result = await dataSource.getToken();

      expect(result, token);
      verify(() => mockSharedPreferences.getString(AppConstants.tokenKey)).called(1);
    });

    test('should return null when no token cached', () async {
      when(() => mockSharedPreferences.getString(AppConstants.tokenKey))
          .thenReturn(null);

      final result = await dataSource.getToken();

      expect(result, isNull);
    });
  });

  group('cacheUser', () {
    test('should cache user in shared preferences as JSON', () async {
      const user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        phone: '+225 01 02 03 04 05',
        role: 'pharmacist',
      );
      
      when(() => mockSharedPreferences.setString(
        AppConstants.userKey,
        any(),
      )).thenAnswer((_) async => true);

      await dataSource.cacheUser(user);

      verify(() => mockSharedPreferences.setString(
        AppConstants.userKey,
        any(that: contains('"email":"test@example.com"')),
      )).called(1);
    });
  });

  group('getUser', () {
    test('should return cached user when present', () async {
      final userJson = json.encode({
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '+225 01 02 03 04 05',
        'role': 'pharmacist',
      });
      
      when(() => mockSharedPreferences.getString(AppConstants.userKey))
          .thenReturn(userJson);

      final result = await dataSource.getUser();

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.name, 'Test User');
      expect(result.email, 'test@example.com');
    });

    test('should return null when no user cached', () async {
      when(() => mockSharedPreferences.getString(AppConstants.userKey))
          .thenReturn(null);

      final result = await dataSource.getUser();

      expect(result, isNull);
    });
  });

  group('clearAuthData', () {
    test('should remove token and user from shared preferences', () async {
      when(() => mockSharedPreferences.remove(AppConstants.tokenKey))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.remove(AppConstants.userKey))
          .thenAnswer((_) async => true);

      await dataSource.clearAuthData();

      verify(() => mockSharedPreferences.remove(AppConstants.tokenKey)).called(1);
      verify(() => mockSharedPreferences.remove(AppConstants.userKey)).called(1);
    });
  });

  group('hasToken', () {
    test('should return true when token exists', () async {
      when(() => mockSharedPreferences.containsKey(AppConstants.tokenKey))
          .thenReturn(true);

      final result = await dataSource.hasToken();

      expect(result, isTrue);
    });

    test('should return false when token does not exist', () async {
      when(() => mockSharedPreferences.containsKey(AppConstants.tokenKey))
          .thenReturn(false);

      final result = await dataSource.hasToken();

      expect(result, isFalse);
    });
  });
}
