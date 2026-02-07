import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/prescriptions/data/datasources/prescriptions_remote_datasource.dart';

import 'prescriptions_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late PrescriptionsRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = PrescriptionsRemoteDataSourceImpl(mockApiClient);
  });

  group('PrescriptionsRemoteDataSourceImpl', () {
    group('getPrescriptions', () {
      test('should return list of prescriptions on success', () async {
        // Arrange
        final prescriptionData = [
          {'id': 1, 'status': 'pending', 'created_at': '2024-01-01'},
          {'id': 2, 'status': 'processed', 'created_at': '2024-01-02'},
        ];

        when(mockApiClient.get('/customer/prescriptions')).thenAnswer(
          (_) async => Response(
            data: {'data': prescriptionData},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/prescriptions'),
          ),
        );

        // Act
        final result = await dataSource.getPrescriptions();

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 2);
        expect(result[0]['id'], 1);
        expect(result[1]['status'], 'processed');
        verify(mockApiClient.get('/customer/prescriptions')).called(1);
      });

      test('should return empty list when no prescriptions', () async {
        // Arrange
        when(mockApiClient.get('/customer/prescriptions')).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/prescriptions'),
          ),
        );

        // Act
        final result = await dataSource.getPrescriptions();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get('/customer/prescriptions')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customer/prescriptions'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getPrescriptions(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getPrescriptionDetails', () {
      test('should return prescription details on success', () async {
        // Arrange
        const prescriptionId = 123;
        final prescriptionDetails = {
          'id': prescriptionId,
          'status': 'pending',
          'notes': 'Test notes',
          'images': ['image1.jpg', 'image2.jpg'],
          'created_at': '2024-01-01T00:00:00.000Z',
        };

        when(mockApiClient.get('/customer/prescriptions/$prescriptionId'))
            .thenAnswer(
          (_) async => Response(
            data: {'data': prescriptionDetails},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/prescriptions/$prescriptionId',
            ),
          ),
        );

        // Act
        final result = await dataSource.getPrescriptionDetails(prescriptionId);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], prescriptionId);
        expect(result['status'], 'pending');
        verify(mockApiClient.get('/customer/prescriptions/$prescriptionId'))
            .called(1);
      });

      test('should throw when prescription not found', () async {
        // Arrange
        const prescriptionId = 999;
        when(mockApiClient.get('/customer/prescriptions/$prescriptionId'))
            .thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/prescriptions/$prescriptionId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/prescriptions/$prescriptionId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getPrescriptionDetails(prescriptionId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('payPrescription', () {
      test('should return payment response on success', () async {
        // Arrange
        const prescriptionId = 123;
        const paymentMethod = 'mobile_money';
        final paymentResponse = {
          'success': true,
          'data': {
            'payment_url': 'https://payment.example.com/pay/123',
            'transaction_id': 'TXN12345',
          },
        };

        when(mockApiClient.post(
          '/customer/prescriptions/$prescriptionId/pay',
          data: {'payment_method': paymentMethod},
        )).thenAnswer(
          (_) async => Response(
            data: paymentResponse,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/prescriptions/$prescriptionId/pay',
            ),
          ),
        );

        // Act
        final result = await dataSource.payPrescription(
          prescriptionId,
          paymentMethod,
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], true);
        expect(result['data']['transaction_id'], 'TXN12345');
        verify(mockApiClient.post(
          '/customer/prescriptions/$prescriptionId/pay',
          data: {'payment_method': paymentMethod},
        )).called(1);
      });

      test('should throw when payment fails', () async {
        // Arrange
        const prescriptionId = 123;
        const paymentMethod = 'mobile_money';
        when(mockApiClient.post(
          '/customer/prescriptions/$prescriptionId/pay',
          data: {'payment_method': paymentMethod},
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/prescriptions/$prescriptionId/pay',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 422,
              data: {'message': 'Invalid payment method'},
              requestOptions: RequestOptions(
                path: '/customer/prescriptions/$prescriptionId/pay',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.payPrescription(prescriptionId, paymentMethod),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle different payment methods', () async {
        // Arrange
        const prescriptionId = 123;
        const paymentMethods = ['mobile_money', 'card', 'cash'];

        for (final method in paymentMethods) {
          when(mockApiClient.post(
            '/customer/prescriptions/$prescriptionId/pay',
            data: {'payment_method': method},
          )).thenAnswer(
            (_) async => Response(
              data: {'success': true, 'payment_method': method},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: '/customer/prescriptions/$prescriptionId/pay',
              ),
            ),
          );

          // Act
          final result = await dataSource.payPrescription(
            prescriptionId,
            method,
          );

          // Assert
          expect(result['payment_method'], method);
        }
      });
    });

    // Note: uploadPrescription requires file system access and is tested via integration tests
  });
}
