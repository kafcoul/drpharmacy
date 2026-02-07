import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/core/errors/exceptions.dart';
import 'package:drpharma_client/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:drpharma_client/features/orders/data/models/order_model.dart';
import 'package:drpharma_client/features/orders/data/models/order_item_model.dart';

import 'orders_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late OrdersRemoteDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = OrdersRemoteDataSource(mockApiClient);
  });

  Map<String, dynamic> createOrderJson({
    int id = 1,
    String reference = 'ORD-001',
    String status = 'pending',
    String paymentStatus = 'pending',
    String totalAmount = '1000.00',
    String paymentMode = 'mobile_money',
  }) {
    return {
      'id': id,
      'reference': reference,
      'status': status,
      'payment_status': paymentStatus,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      'pharmacy': {
        'id': 1,
        'name': 'Test Pharmacy',
        'address': '123 Test Street',
        'phone': '+1234567890',
        'status': 'active',
        'is_open': true,
      },
      'items': [],
      'delivery_address': '123 Delivery Street',
      'customer_phone': '+1234567890',
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-01-01T00:00:00.000Z',
    };
  }

  group('OrdersRemoteDataSource', () {
    group('getOrders', () {
      test('should return list of orders on success', () async {
        // Arrange
        final orderData = [
          createOrderJson(id: 1, status: 'pending'),
          createOrderJson(id: 2, status: 'completed'),
        ];

        when(mockApiClient.get(
          '/customer/orders',
          queryParameters: {'page': 1, 'per_page': 20},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': orderData},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/orders'),
          ),
        );

        // Act
        final result = await dataSource.getOrders();

        // Assert
        expect(result, isA<List<OrderModel>>());
        expect(result.length, 2);
        verify(mockApiClient.get(
          '/customer/orders',
          queryParameters: {'page': 1, 'per_page': 20},
        )).called(1);
      });

      test('should pass status filter when provided', () async {
        // Arrange
        const status = 'pending';

        when(mockApiClient.get(
          '/customer/orders',
          queryParameters: {
            'page': 1,
            'per_page': 20,
            'status': status,
          },
        )).thenAnswer(
          (_) async => Response(
            data: {'data': [createOrderJson(status: status)]},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/orders'),
          ),
        );

        // Act
        final result = await dataSource.getOrders(status: status);

        // Assert
        expect(result.length, 1);
      });

      test('should pass pagination parameters', () async {
        // Arrange
        const page = 2;
        const perPage = 50;

        when(mockApiClient.get(
          '/customer/orders',
          queryParameters: {'page': page, 'per_page': perPage},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/orders'),
          ),
        );

        // Act
        await dataSource.getOrders(page: page, perPage: perPage);

        // Assert
        verify(mockApiClient.get(
          '/customer/orders',
          queryParameters: {'page': page, 'per_page': perPage},
        )).called(1);
      });

      test('should return empty list when no orders', () async {
        // Arrange
        when(mockApiClient.get(
          '/customer/orders',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer(
          (_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/customer/orders'),
          ),
        );

        // Act
        final result = await dataSource.getOrders();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get(
          '/customer/orders',
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customer/orders'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getOrders(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getOrderDetails', () {
      test('should return order details on success', () async {
        // Arrange
        const orderId = 123;
        final orderJson = createOrderJson(id: orderId);

        when(mockApiClient.get('/customer/orders/$orderId')).thenAnswer(
          (_) async => Response(
            data: {'data': orderJson},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId',
            ),
          ),
        );

        // Act
        final result = await dataSource.getOrderDetails(orderId);

        // Assert
        expect(result, isA<OrderModel>());
        expect(result.id, orderId);
        verify(mockApiClient.get('/customer/orders/$orderId')).called(1);
      });

      test('should throw when order not found', () async {
        // Arrange
        const orderId = 999;
        when(mockApiClient.get('/customer/orders/$orderId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/customer/orders/$orderId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getOrderDetails(orderId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('createOrder', () {
      test('should throw ValidationException when phone is missing', () async {
        // Arrange
        final items = <OrderItemModel>[
          const OrderItemModel(
            productId: 1,
            name: 'Test Product',
            quantity: 2,
            unitPrice: 100.0,
            totalPrice: 200.0,
          ),
        ];
        final deliveryAddress = {
          'address': '123 Test Street',
        };

        // Act & Assert
        expect(
          () => dataSource.createOrder(
            pharmacyId: 1,
            items: items,
            deliveryAddress: deliveryAddress,
            paymentMode: 'mobile_money',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when phone is empty', () async {
        // Arrange
        final items = <OrderItemModel>[
          const OrderItemModel(
            productId: 1,
            name: 'Test Product',
            quantity: 2,
            unitPrice: 100.0,
            totalPrice: 200.0,
          ),
        ];
        final deliveryAddress = {
          'address': '123 Test Street',
          'phone': '',
        };

        // Act & Assert
        expect(
          () => dataSource.createOrder(
            pharmacyId: 1,
            items: items,
            deliveryAddress: deliveryAddress,
            paymentMode: 'mobile_money',
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('cancelOrder', () {
      test('should cancel order successfully', () async {
        // Arrange
        const orderId = 123;
        const reason = 'Changed my mind';

        when(mockApiClient.post(
          '/customer/orders/$orderId/cancel',
          data: {'reason': reason},
        )).thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId/cancel',
            ),
          ),
        );

        // Act
        await dataSource.cancelOrder(orderId, reason);

        // Assert
        verify(mockApiClient.post(
          '/customer/orders/$orderId/cancel',
          data: {'reason': reason},
        )).called(1);
      });

      test('should throw when cancel fails', () async {
        // Arrange
        const orderId = 123;
        const reason = 'Test reason';

        when(mockApiClient.post(
          '/customer/orders/$orderId/cancel',
          data: {'reason': reason},
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId/cancel',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 400,
              data: {'message': 'Cannot cancel order'},
              requestOptions: RequestOptions(
                path: '/customer/orders/$orderId/cancel',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.cancelOrder(orderId, reason),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('initiatePayment', () {
      test('should return payment data on success', () async {
        // Arrange
        const orderId = 123;
        const provider = 'mobile_money';
        final paymentData = {
          'payment_url': 'https://payment.example.com/pay/123',
          'transaction_id': 'TXN12345',
        };

        when(mockApiClient.post(
          '/customer/orders/$orderId/payment/initiate',
          data: {'provider': provider},
        )).thenAnswer(
          (_) async => Response(
            data: {'data': paymentData},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId/payment/initiate',
            ),
          ),
        );

        // Act
        final result = await dataSource.initiatePayment(
          orderId: orderId,
          provider: provider,
        );

        // Assert
        expect(result, equals(paymentData));
        verify(mockApiClient.post(
          '/customer/orders/$orderId/payment/initiate',
          data: {'provider': provider},
        )).called(1);
      });

      test('should throw when payment initiation fails', () async {
        // Arrange
        const orderId = 123;
        const provider = 'mobile_money';

        when(mockApiClient.post(
          '/customer/orders/$orderId/payment/initiate',
          data: {'provider': provider},
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId/payment/initiate',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 422,
              data: {'message': 'Payment already initiated'},
              requestOptions: RequestOptions(
                path: '/customer/orders/$orderId/payment/initiate',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.initiatePayment(
            orderId: orderId,
            provider: provider,
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getTrackingInfo', () {
      test('should return tracking info when delivery exists', () async {
        // Arrange
        const orderId = 123;
        final deliveryInfo = {
          'status': 'in_transit',
          'courier_name': 'John Doe',
          'courier_phone': '+1234567890',
        };

        when(mockApiClient.get('/customer/orders/$orderId')).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                ...createOrderJson(id: orderId),
                'delivery': deliveryInfo,
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId',
            ),
          ),
        );

        // Act
        final result = await dataSource.getTrackingInfo(orderId);

        // Assert
        expect(result, equals(deliveryInfo));
      });

      test('should return null when no delivery info', () async {
        // Arrange
        const orderId = 123;

        when(mockApiClient.get('/customer/orders/$orderId')).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                ...createOrderJson(id: orderId),
                'delivery': null,
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId',
            ),
          ),
        );

        // Act
        final result = await dataSource.getTrackingInfo(orderId);

        // Assert
        expect(result, isNull);
      });

      test('should throw when API call fails', () async {
        // Arrange
        const orderId = 123;

        when(mockApiClient.get('/customer/orders/$orderId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/customer/orders/$orderId',
            ),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getTrackingInfo(orderId),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
