import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/pharmacies/data/datasources/pharmacies_remote_datasource.dart';
import 'package:drpharma_client/features/pharmacies/data/models/pharmacy_model.dart';

import 'pharmacies_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late PharmaciesRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = PharmaciesRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  Map<String, dynamic> createPharmacyJson({
    int id = 1,
    String name = 'Test Pharmacy',
    String address = '123 Test Street',
    String phone = '+1234567890',
    String? email,
    double? latitude,
    double? longitude,
    String status = 'active',
    bool isOpen = true,
    bool isOnDuty = false,
  }) {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'is_open': isOpen,
      'is_on_duty': isOnDuty,
    };
  }

  group('PharmaciesRemoteDataSourceImpl', () {
    group('getPharmacies', () {
      test('should return list of pharmacies on success', () async {
        // Arrange
        final pharmacyData = [
          createPharmacyJson(id: 1, name: 'Pharmacy 1'),
          createPharmacyJson(id: 2, name: 'Pharmacy 2'),
        ];

        when(mockApiClient.get(
          '/customer/pharmacies',
          queryParameters: {'page': 1, 'per_page': 20},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': pharmacyData},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/pharmacies'),
          ),
        );

        // Act
        final result = await dataSource.getPharmacies();

        // Assert
        expect(result, isA<List<PharmacyModel>>());
        expect(result.length, 2);
        verify(mockApiClient.get(
          '/customer/pharmacies',
          queryParameters: {'page': 1, 'per_page': 20},
        )).called(1);
      });

      test('should pass custom pagination parameters', () async {
        // Arrange
        const page = 2;
        const perPage = 50;

        when(mockApiClient.get(
          '/customer/pharmacies',
          queryParameters: {'page': page, 'per_page': perPage},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/pharmacies'),
          ),
        );

        // Act
        final result = await dataSource.getPharmacies(
          page: page,
          perPage: perPage,
        );

        // Assert
        expect(result, isEmpty);
        verify(mockApiClient.get(
          '/customer/pharmacies',
          queryParameters: {'page': page, 'per_page': perPage},
        )).called(1);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get(
          '/customer/pharmacies',
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customer/pharmacies'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getPharmacies(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getNearbyPharmacies', () {
      test('should return nearby pharmacies on success', () async {
        // Arrange
        const latitude = 5.123;
        const longitude = -0.456;
        const radius = 5.0;

        final pharmacyData = [
          createPharmacyJson(
            id: 1,
            name: 'Nearby Pharmacy',
            latitude: 5.125,
            longitude: -0.458,
          ),
        ];

        when(mockApiClient.get(
          '/customer/pharmacies/nearby',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radius': radius,
          },
        )).thenAnswer(
          (_) async => Response(
            data: {'data': pharmacyData},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/nearby',
            ),
          ),
        );

        // Act
        final result = await dataSource.getNearbyPharmacies(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );

        // Assert
        expect(result, isA<List<PharmacyModel>>());
        expect(result.length, 1);
      });

      test('should use default radius of 10.0', () async {
        // Arrange
        const latitude = 5.123;
        const longitude = -0.456;

        when(mockApiClient.get(
          '/customer/pharmacies/nearby',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radius': 10.0,
          },
        )).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/nearby',
            ),
          ),
        );

        // Act
        await dataSource.getNearbyPharmacies(
          latitude: latitude,
          longitude: longitude,
        );

        // Assert
        verify(mockApiClient.get(
          '/customer/pharmacies/nearby',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radius': 10.0,
          },
        )).called(1);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get(
          '/customer/pharmacies/nearby',
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/nearby',
            ),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getNearbyPharmacies(
            latitude: 5.0,
            longitude: -0.5,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getOnDutyPharmacies', () {
      test('should return on-duty pharmacies without location', () async {
        // Arrange
        final pharmacyData = [
          createPharmacyJson(id: 1, name: 'On Duty Pharmacy', isOnDuty: true),
        ];

        when(mockApiClient.get(
          '/customer/pharmacies/on-duty',
          queryParameters: {},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': pharmacyData},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/on-duty',
            ),
          ),
        );

        // Act
        final result = await dataSource.getOnDutyPharmacies();

        // Assert
        expect(result, isA<List<PharmacyModel>>());
        expect(result.length, 1);
      });

      test('should pass location parameters when provided', () async {
        // Arrange
        const latitude = 5.123;
        const longitude = -0.456;
        const radius = 20.0;

        when(mockApiClient.get(
          '/customer/pharmacies/on-duty',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radius': radius,
          },
        )).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/on-duty',
            ),
          ),
        );

        // Act
        await dataSource.getOnDutyPharmacies(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );

        // Assert
        verify(mockApiClient.get(
          '/customer/pharmacies/on-duty',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radius': radius,
          },
        )).called(1);
      });

      test('should only pass non-null parameters', () async {
        // Arrange
        const latitude = 5.123;

        when(mockApiClient.get(
          '/customer/pharmacies/on-duty',
          queryParameters: {'latitude': latitude},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/on-duty',
            ),
          ),
        );

        // Act
        await dataSource.getOnDutyPharmacies(latitude: latitude);

        // Assert
        verify(mockApiClient.get(
          '/customer/pharmacies/on-duty',
          queryParameters: {'latitude': latitude},
        )).called(1);
      });
    });

    group('getPharmacyDetails', () {
      test('should return pharmacy details on success', () async {
        // Arrange
        const pharmacyId = 123;
        final pharmacyJson = createPharmacyJson(
          id: pharmacyId,
          name: 'Detailed Pharmacy',
          email: 'pharmacy@test.com',
          latitude: 5.123,
          longitude: -0.456,
        );

        when(mockApiClient.get('/customer/pharmacies/$pharmacyId')).thenAnswer(
          (_) async => Response(
            data: {'data': pharmacyJson},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/$pharmacyId',
            ),
          ),
        );

        // Act
        final result = await dataSource.getPharmacyDetails(pharmacyId);

        // Assert
        expect(result, isA<PharmacyModel>());
        expect(result.id, pharmacyId);
        verify(mockApiClient.get('/customer/pharmacies/$pharmacyId')).called(1);
      });

      test('should throw when pharmacy not found', () async {
        // Arrange
        const pharmacyId = 999;
        when(mockApiClient.get('/customer/pharmacies/$pharmacyId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/$pharmacyId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/pharmacies/$pharmacyId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getPharmacyDetails(pharmacyId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getFeaturedPharmacies', () {
      test('should return featured pharmacies on success', () async {
        // Arrange
        final pharmacyData = [
          createPharmacyJson(id: 1, name: 'Featured Pharmacy 1'),
          createPharmacyJson(id: 2, name: 'Featured Pharmacy 2'),
        ];

        when(mockApiClient.get('/customer/pharmacies/featured')).thenAnswer(
          (_) async => Response(
            data: {'data': pharmacyData},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/featured',
            ),
          ),
        );

        // Act
        final result = await dataSource.getFeaturedPharmacies();

        // Assert
        expect(result, isA<List<PharmacyModel>>());
        expect(result.length, 2);
        verify(mockApiClient.get('/customer/pharmacies/featured')).called(1);
      });

      test('should return empty list when no featured pharmacies', () async {
        // Arrange
        when(mockApiClient.get('/customer/pharmacies/featured')).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/featured',
            ),
          ),
        );

        // Act
        final result = await dataSource.getFeaturedPharmacies();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get('/customer/pharmacies/featured')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/pharmacies/featured',
            ),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getFeaturedPharmacies(),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
