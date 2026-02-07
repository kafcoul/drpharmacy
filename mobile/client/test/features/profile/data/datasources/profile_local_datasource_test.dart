import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drpharma_client/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:drpharma_client/features/profile/data/models/profile_model.dart';

@GenerateMocks([SharedPreferences])
import 'profile_local_datasource_test.mocks.dart';

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late ProfileLocalDataSourceImpl dataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ProfileLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  ProfileModel createTestProfile() {
    return ProfileModel(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      phone: '+24177000000',
      avatar: 'https://example.com/avatar.jpg',
      defaultAddress: '123 Rue Test',
      createdAt: '2024-01-01T00:00:00Z',
      totalOrders: 10,
      completedOrders: 8,
      totalSpent: 50000.0,
    );
  }

  group('ProfileLocalDataSourceImpl', () {
    group('getCachedProfile', () {
      test('should return cached profile when present', () async {
        // Arrange
        final profile = createTestProfile();
        final jsonString = json.encode(profile.toJson());
        when(mockSharedPreferences.getString('CACHED_PROFILE'))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.name, 'Test User');
        expect(result.email, 'test@example.com');
        verify(mockSharedPreferences.getString('CACHED_PROFILE')).called(1);
      });

      test('should return null when no cached profile', () async {
        // Arrange
        when(mockSharedPreferences.getString('CACHED_PROFILE'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result, isNull);
      });
    });

    group('cacheProfile', () {
      test('should save profile to SharedPreferences', () async {
        // Arrange
        final profile = createTestProfile();
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheProfile(profile);

        // Assert
        verify(mockSharedPreferences.setString(
          'CACHED_PROFILE',
          argThat(isA<String>()),
        )).called(1);
      });

      test('should serialize profile correctly', () async {
        // Arrange
        final profile = createTestProfile();
        String? savedJson;
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((invocation) async {
          savedJson = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheProfile(profile);

        // Assert
        expect(savedJson, isNotNull);
        final decoded = json.decode(savedJson!);
        expect(decoded['id'], 1);
        expect(decoded['name'], 'Test User');
      });
    });

    group('clearCache', () {
      test('should remove cached profile', () async {
        // Arrange
        when(mockSharedPreferences.remove('CACHED_PROFILE'))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearCache();

        // Assert
        verify(mockSharedPreferences.remove('CACHED_PROFILE')).called(1);
      });
    });
  });
}
