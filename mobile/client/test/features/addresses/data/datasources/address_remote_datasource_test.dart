import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/addresses/data/datasources/address_remote_datasource.dart';
import 'package:drpharma_client/features/addresses/data/models/address_model.dart';

import 'address_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late AddressRemoteDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AddressRemoteDataSource(mockApiClient);
  });

  Map<String, dynamic> createAddressJson({
    int id = 1,
    String label = 'Home',
    String address = '123 Test Street',
    String? city,
    String? district,
    String? phone,
    String? instructions,
    double? latitude,
    double? longitude,
    bool isDefault = false,
    String fullAddress = '123 Test Street, Test City',
    bool hasCoordinates = false,
    String createdAt = '2024-01-01T00:00:00.000Z',
    String updatedAt = '2024-01-01T00:00:00.000Z',
  }) {
    return {
      'id': id,
      'label': label,
      'address': address,
      'city': city,
      'district': district,
      'phone': phone,
      'instructions': instructions,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'full_address': fullAddress,
      'has_coordinates': hasCoordinates,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  group('AddressRemoteDataSource', () {
    group('getAddresses', () {
      test('should return list of addresses on success', () async {
        // Arrange
        final addressData = [
          createAddressJson(id: 1, label: 'Home'),
          createAddressJson(id: 2, label: 'Work'),
        ];

        when(mockApiClient.get('/customer/addresses')).thenAnswer(
          (_) async => Response(
            data: {'data': addressData},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/addresses'),
          ),
        );

        // Act
        final result = await dataSource.getAddresses();

        // Assert
        expect(result, isA<List<AddressModel>>());
        expect(result.length, 2);
        verify(mockApiClient.get('/customer/addresses')).called(1);
      });

      test('should return empty list when no addresses', () async {
        // Arrange
        when(mockApiClient.get('/customer/addresses')).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/addresses'),
          ),
        );

        // Act
        final result = await dataSource.getAddresses();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle null data gracefully', () async {
        // Arrange
        when(mockApiClient.get('/customer/addresses')).thenAnswer(
          (_) async => Response(
            data: {'data': null},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/addresses'),
          ),
        );

        // Act
        final result = await dataSource.getAddresses();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get('/customer/addresses')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customer/addresses'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getAddresses(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getAddress', () {
      test('should return address on success', () async {
        // Arrange
        const addressId = 123;
        final addressJson = createAddressJson(id: addressId, label: 'Office');

        when(mockApiClient.get('/customer/addresses/$addressId')).thenAnswer(
          (_) async => Response(
            data: {'data': addressJson},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId',
            ),
          ),
        );

        // Act
        final result = await dataSource.getAddress(addressId);

        // Assert
        expect(result, isA<AddressModel>());
        expect(result.id, addressId);
        verify(mockApiClient.get('/customer/addresses/$addressId')).called(1);
      });

      test('should throw when address not found', () async {
        // Arrange
        const addressId = 999;
        when(mockApiClient.get('/customer/addresses/$addressId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/addresses/$addressId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getAddress(addressId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getDefaultAddress', () {
      test('should return default address on success', () async {
        // Arrange
        final addressJson = createAddressJson(
          id: 1,
          label: 'Default Home',
          isDefault: true,
        );

        when(mockApiClient.get('/customer/addresses/default')).thenAnswer(
          (_) async => Response(
            data: {'data': addressJson},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/addresses/default',
            ),
          ),
        );

        // Act
        final result = await dataSource.getDefaultAddress();

        // Assert
        expect(result, isA<AddressModel>());
        verify(mockApiClient.get('/customer/addresses/default')).called(1);
      });

      test('should throw when no default address', () async {
        // Arrange
        when(mockApiClient.get('/customer/addresses/default')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/addresses/default',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/addresses/default',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getDefaultAddress(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('createAddress', () {
      test('should create address with required fields only', () async {
        // Arrange
        const label = 'New Address';
        const address = '456 New Street';
        final responseJson = createAddressJson(
          id: 10,
          label: label,
          address: address,
        );

        when(mockApiClient.post(
          '/customer/addresses',
          data: {
            'label': label,
            'address': address,
            'is_default': false,
          },
        )).thenAnswer(
          (_) async => Response(
            data: {'data': responseJson},
            statusCode: 201,
            requestOptions: RequestOptions(path: '/customer/addresses'),
          ),
        );

        // Act
        final result = await dataSource.createAddress(
          label: label,
          address: address,
        );

        // Assert
        expect(result, isA<AddressModel>());
        expect(result.id, 10);
      });

      test('should create address with all fields', () async {
        // Arrange
        const label = 'Full Address';
        const address = '789 Full Street';
        const city = 'Test City';
        const district = 'Test District';
        const phone = '+1234567890';
        const instructions = 'Ring the bell';
        const latitude = 5.123;
        const longitude = -0.456;

        final responseJson = createAddressJson(
          id: 11,
          label: label,
          address: address,
          city: city,
          district: district,
          phone: phone,
          instructions: instructions,
          latitude: latitude,
          longitude: longitude,
          isDefault: true,
        );

        when(mockApiClient.post(
          '/customer/addresses',
          data: {
            'label': label,
            'address': address,
            'city': city,
            'district': district,
            'phone': phone,
            'instructions': instructions,
            'latitude': latitude,
            'longitude': longitude,
            'is_default': true,
          },
        )).thenAnswer(
          (_) async => Response(
            data: {'data': responseJson},
            statusCode: 201,
            requestOptions: RequestOptions(path: '/customer/addresses'),
          ),
        );

        // Act
        final result = await dataSource.createAddress(
          label: label,
          address: address,
          city: city,
          district: district,
          phone: phone,
          instructions: instructions,
          latitude: latitude,
          longitude: longitude,
          isDefault: true,
        );

        // Assert
        expect(result, isA<AddressModel>());
        expect(result.id, 11);
      });

      test('should throw when creation fails', () async {
        // Arrange
        when(mockApiClient.post(
          '/customer/addresses',
          data: anyNamed('data'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customer/addresses'),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 422,
              data: {'message': 'Validation error'},
              requestOptions: RequestOptions(path: '/customer/addresses'),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.createAddress(label: 'Test', address: 'Test'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('updateAddress', () {
      test('should update address with provided fields', () async {
        // Arrange
        const addressId = 123;
        const newLabel = 'Updated Label';
        final responseJson = createAddressJson(
          id: addressId,
          label: newLabel,
        );

        when(mockApiClient.put(
          '/customer/addresses/$addressId',
          data: {'label': newLabel},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': responseJson},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId',
            ),
          ),
        );

        // Act
        final result = await dataSource.updateAddress(
          id: addressId,
          label: newLabel,
        );

        // Assert
        expect(result, isA<AddressModel>());
        expect(result.id, addressId);
      });

      test('should throw when update fails', () async {
        // Arrange
        const addressId = 999;
        when(mockApiClient.put(
          '/customer/addresses/$addressId',
          data: anyNamed('data'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/addresses/$addressId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.updateAddress(id: addressId, label: 'Test'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('deleteAddress', () {
      test('should delete address successfully', () async {
        // Arrange
        const addressId = 123;
        when(mockApiClient.delete('/customer/addresses/$addressId'))
            .thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId',
            ),
          ),
        );

        // Act
        await dataSource.deleteAddress(addressId);

        // Assert
        verify(mockApiClient.delete('/customer/addresses/$addressId'))
            .called(1);
      });

      test('should throw when delete fails', () async {
        // Arrange
        const addressId = 999;
        when(mockApiClient.delete('/customer/addresses/$addressId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/addresses/$addressId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.deleteAddress(addressId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('setDefaultAddress', () {
      test('should set address as default successfully', () async {
        // Arrange
        const addressId = 123;
        final responseJson = createAddressJson(
          id: addressId,
          isDefault: true,
        );

        when(mockApiClient.post('/customer/addresses/$addressId/default'))
            .thenAnswer(
          (_) async => Response(
            data: {'data': responseJson},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId/default',
            ),
          ),
        );

        // Act
        final result = await dataSource.setDefaultAddress(addressId);

        // Assert
        expect(result, isA<AddressModel>());
        verify(mockApiClient.post('/customer/addresses/$addressId/default'))
            .called(1);
      });

      test('should throw when setting default fails', () async {
        // Arrange
        const addressId = 999;
        when(mockApiClient.post('/customer/addresses/$addressId/default'))
            .thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/addresses/$addressId/default',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/addresses/$addressId/default',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.setDefaultAddress(addressId),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
