import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/core/constants/api_constants.dart';
import 'package:drpharma_client/features/profile/data/datasources/profile_remote_datasource.dart';

@GenerateMocks([ApiClient])
import 'profile_remote_datasource_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late ProfileRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProfileRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('ProfileRemoteDataSourceImpl', () {
    group('getProfile', () {
      test('should return ProfileModel from API', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.profile)).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'id': 1,
                'name': 'Test User',
                'email': 'test@example.com',
                'phone': '+24177000000',
                'avatar': 'https://example.com/avatar.jpg',
                'default_address': '123 Rue Test',
                'created_at': '2024-01-01T00:00:00Z',
                'total_orders': 10,
                'completed_orders': 8,
                'total_spent': 50000.0,
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.profile),
          ),
        );

        // Act
        final result = await dataSource.getProfile();

        // Assert
        expect(result.id, 1);
        expect(result.name, 'Test User');
        expect(result.email, 'test@example.com');
        verify(mockApiClient.get(ApiConstants.profile)).called(1);
      });

      test('should throw exception on API error', () async {
        // Arrange
        when(mockApiClient.get(ApiConstants.profile))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ApiConstants.profile),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => dataSource.getProfile(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('updateProfile', () {
      test('should return updated ProfileModel from API', () async {
        // Arrange
        final profileData = {'name': 'Updated Name'};
        when(mockApiClient.post(ApiConstants.updateProfile, data: profileData))
            .thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'id': 1,
                'name': 'Updated Name',
                'email': 'test@example.com',
                'phone': '+24177000000',
                'avatar': null,
                'default_address': null,
                'created_at': '2024-01-01T00:00:00Z',
                'total_orders': 0,
                'completed_orders': 0,
                'total_spent': 0.0,
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.updateProfile),
          ),
        );

        // Act
        final result = await dataSource.updateProfile(profileData);

        // Assert
        expect(result.name, 'Updated Name');
        verify(mockApiClient.post(ApiConstants.updateProfile, data: profileData))
            .called(1);
      });

      test('should send correct data to API', () async {
        // Arrange
        final profileData = {
          'name': 'New Name',
          'phone': '+24166000000',
        };
        when(mockApiClient.post(ApiConstants.updateProfile, data: profileData))
            .thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'id': 1,
                'name': 'New Name',
                'email': 'test@example.com',
                'phone': '+24166000000',
                'avatar': null,
                'default_address': null,
                'created_at': '2024-01-01T00:00:00Z',
                'total_orders': 0,
                'completed_orders': 0,
                'total_spent': 0.0,
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.updateProfile),
          ),
        );

        // Act
        final result = await dataSource.updateProfile(profileData);

        // Assert
        expect(result.name, 'New Name');
        expect(result.phone, '+24166000000');
      });
    });

    group('uploadAvatar', () {
      test('should return avatar URL from API', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(mockApiClient.uploadMultipart(
          ApiConstants.uploadAvatar,
          formData: anyNamed('formData'),
        )).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'avatar_url': 'https://example.com/new-avatar.jpg',
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.uploadAvatar),
          ),
        );

        // Act
        final result = await dataSource.uploadAvatar(imageBytes);

        // Assert
        expect(result, 'https://example.com/new-avatar.jpg');
        verify(mockApiClient.uploadMultipart(
          ApiConstants.uploadAvatar,
          formData: anyNamed('formData'),
        )).called(1);
      });

      test('should throw exception on upload error', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        when(mockApiClient.uploadMultipart(
          ApiConstants.uploadAvatar,
          formData: anyNamed('formData'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ApiConstants.uploadAvatar),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => dataSource.uploadAvatar(imageBytes),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('deleteAvatar', () {
      test('should call delete API', () async {
        // Arrange
        when(mockApiClient.delete(ApiConstants.deleteAvatar)).thenAnswer(
          (_) async => Response(
            data: {'message': 'Avatar deleted'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.deleteAvatar),
          ),
        );

        // Act
        await dataSource.deleteAvatar();

        // Assert
        verify(mockApiClient.delete(ApiConstants.deleteAvatar)).called(1);
      });

      test('should throw exception on delete error', () async {
        // Arrange
        when(mockApiClient.delete(ApiConstants.deleteAvatar))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ApiConstants.deleteAvatar),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => dataSource.deleteAvatar(),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
