import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/orders/data/datasources/delivery_pricing_datasource.dart';

@GenerateMocks([ApiClient])
import 'delivery_pricing_datasource_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late DeliveryPricingDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = DeliveryPricingDataSource(apiClient: mockApiClient);
  });

  group('DeliveryPricingDataSource', () {
    group('getPricing', () {
      test('should return pricing from API', () async {
        // Arrange
        when(mockApiClient.get('/delivery/pricing')).thenAnswer((_) async => Response(
              data: {
                'base_fee': 250,
                'fee_per_km': 150,
                'min_fee': 400,
                'max_fee': 6000,
                'currency': 'XOF',
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/delivery/pricing'),
            ));

        // Act
        final result = await dataSource.getPricing();

        // Assert
        expect(result.baseFee, 250);
        expect(result.feePerKm, 150);
        expect(result.minFee, 400);
        expect(result.maxFee, 6000);
        expect(result.currency, 'XOF');
        verify(mockApiClient.get('/delivery/pricing')).called(1);
      });

      test('should return defaults on API error', () async {
        // Arrange
        when(mockApiClient.get('/delivery/pricing'))
            .thenThrow(Exception('API Error'));

        // Act
        final result = await dataSource.getPricing();

        // Assert
        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
        expect(result.currency, 'XOF');
      });
    });

    group('estimate', () {
      test('should estimate with distance_km', () async {
        // Arrange
        when(mockApiClient.post('/delivery/estimate', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  data: {
                    'distance_km': 5.0,
                    'delivery_fee': 700,
                    'currency': 'XOF',
                    'breakdown': {
                      'base_fee': 200,
                      'distance_fee': 500,
                    },
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/delivery/estimate'),
                ));

        // Act
        final result = await dataSource.estimate(distanceKm: 5.0);

        // Assert
        expect(result.distanceKm, 5.0);
        expect(result.deliveryFee, 700);
        expect(result.baseFee, 200);
        expect(result.distanceFee, 500);
        verify(mockApiClient.post('/delivery/estimate', data: {'distance_km': 5.0}))
            .called(1);
      });

      test('should estimate with coordinates', () async {
        // Arrange
        when(mockApiClient.post('/delivery/estimate', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  data: {
                    'distance_km': 3.5,
                    'delivery_fee': 550,
                    'currency': 'XOF',
                    'breakdown': {
                      'base_fee': 200,
                      'distance_fee': 350,
                    },
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/delivery/estimate'),
                ));

        // Act
        final result = await dataSource.estimate(
          pharmacyLat: 0.3917,
          pharmacyLng: 9.4536,
          deliveryLat: 0.4017,
          deliveryLng: 9.4636,
        );

        // Assert
        expect(result.distanceKm, 3.5);
        expect(result.deliveryFee, 550);
        verify(mockApiClient.post('/delivery/estimate', data: {
          'pharmacy_lat': 0.3917,
          'pharmacy_lng': 9.4536,
          'delivery_lat': 0.4017,
          'delivery_lng': 9.4636,
        })).called(1);
      });

      test('should return defaults on API error', () async {
        // Arrange
        when(mockApiClient.post('/delivery/estimate', data: anyNamed('data')))
            .thenThrow(Exception('API Error'));

        // Act
        final result = await dataSource.estimate(distanceKm: 3.0);

        // Assert
        expect(result.distanceKm, 0);
        expect(result.deliveryFee, 300);
        expect(result.currency, 'XOF');
      });
    });
  });

  group('DeliveryPricingResponse', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'base_fee': 300,
          'fee_per_km': 120,
          'min_fee': 400,
          'max_fee': 7000,
          'currency': 'EUR',
        };

        final result = DeliveryPricingResponse.fromJson(json);

        expect(result.baseFee, 300);
        expect(result.feePerKm, 120);
        expect(result.minFee, 400);
        expect(result.maxFee, 7000);
        expect(result.currency, 'EUR');
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = DeliveryPricingResponse.fromJson(json);

        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
        expect(result.currency, 'XOF');
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = DeliveryPricingResponse.defaults();

        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
        expect(result.currency, 'XOF');
      });
    });

    group('calculateFee', () {
      late DeliveryPricingResponse pricing;

      setUp(() {
        pricing = DeliveryPricingResponse(
          baseFee: 200,
          feePerKm: 100,
          minFee: 300,
          maxFee: 5000,
          currency: 'XOF',
        );
      });

      test('should calculate fee for short distance', () {
        // 200 + (1 * 100) = 300 equals min
        expect(pricing.calculateFee(1.0), 300);
      });

      test('should calculate fee for medium distance', () {
        // 200 + (5 * 100) = 700
        expect(pricing.calculateFee(5.0), 700);
      });

      test('should apply minimum fee', () {
        // 200 + (0.5 * 100) = 250, should be 300 (min)
        expect(pricing.calculateFee(0.5), 300);
      });

      test('should apply maximum fee', () {
        // 200 + (100 * 100) = 10200, should be 5000 (max)
        expect(pricing.calculateFee(100.0), 5000);
      });

      test('should round up partial km', () {
        // 200 + (2.7 * 100) = 470
        expect(pricing.calculateFee(2.7), 470);
      });

      test('should handle zero distance', () {
        // 200 + (0 * 100) = 200, should be 300 (min)
        expect(pricing.calculateFee(0.0), 300);
      });
    });
  });

  group('DeliveryEstimateResponse', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'distance_km': 4.5,
          'delivery_fee': 650,
          'currency': 'XOF',
          'breakdown': {
            'base_fee': 200,
            'distance_fee': 450,
          },
        };

        final result = DeliveryEstimateResponse.fromJson(json);

        expect(result.distanceKm, 4.5);
        expect(result.deliveryFee, 650);
        expect(result.currency, 'XOF');
        expect(result.baseFee, 200);
        expect(result.distanceFee, 450);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = DeliveryEstimateResponse.fromJson(json);

        expect(result.distanceKm, 0.0);
        expect(result.deliveryFee, 300);
        expect(result.currency, 'XOF');
        expect(result.baseFee, 200);
        expect(result.distanceFee, 100);
      });

      test('should handle missing breakdown', () {
        final json = {
          'distance_km': 2.0,
          'delivery_fee': 400,
          'currency': 'XOF',
        };

        final result = DeliveryEstimateResponse.fromJson(json);

        expect(result.baseFee, 200);
        expect(result.distanceFee, 100);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = DeliveryEstimateResponse.defaults();

        expect(result.distanceKm, 0);
        expect(result.deliveryFee, 300);
        expect(result.currency, 'XOF');
        expect(result.baseFee, 200);
        expect(result.distanceFee, 100);
      });
    });
  });
}
