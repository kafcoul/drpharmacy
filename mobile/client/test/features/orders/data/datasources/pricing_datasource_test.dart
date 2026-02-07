import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/orders/data/datasources/pricing_datasource.dart';

@GenerateMocks([ApiClient])
import 'pricing_datasource_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late PricingDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = PricingDataSource(apiClient: mockApiClient);
  });

  group('PricingDataSource', () {
    group('getPricing', () {
      test('should return PricingConfig from API', () async {
        // Arrange
        when(mockApiClient.get('/pricing')).thenAnswer((_) async => Response(
              data: {
                'data': {
                  'delivery': {
                    'base_fee': 250,
                    'fee_per_km': 150,
                    'min_fee': 400,
                    'max_fee': 6000,
                  },
                  'service': {
                    'service_fee': {
                      'enabled': true,
                      'percentage': 5,
                      'min': 200,
                      'max': 3000,
                    },
                    'payment_fee': {
                      'enabled': true,
                      'fixed_fee': 100,
                      'percentage': 2.0,
                    },
                  },
                },
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/pricing'),
            ));

        // Act
        final result = await dataSource.getPricing();

        // Assert
        expect(result.delivery.baseFee, 250);
        expect(result.delivery.feePerKm, 150);
        expect(result.service.serviceFee.percentage, 5);
        verify(mockApiClient.get('/pricing')).called(1);
      });

      test('should return defaults on API error', () async {
        // Arrange
        when(mockApiClient.get('/pricing')).thenThrow(Exception('API Error'));

        // Act
        final result = await dataSource.getPricing();

        // Assert
        expect(result.delivery.baseFee, 200);
        expect(result.delivery.feePerKm, 100);
        expect(result.delivery.minFee, 300);
        expect(result.delivery.maxFee, 5000);
      });
    });

    group('calculateFees', () {
      test('should return calculated fees from API', () async {
        // Arrange
        when(mockApiClient.post('/pricing/calculate', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  data: {
                    'data': {
                      'subtotal': 10000,
                      'delivery_fee': 500,
                      'service_fee': 300,
                      'payment_fee': 200,
                      'total_amount': 11000,
                      'pharmacy_amount': 10000,
                    },
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/pricing/calculate'),
                ));

        // Act
        final result = await dataSource.calculateFees(
          subtotal: 10000,
          deliveryFee: 500,
          paymentMode: 'mobile_money',
        );

        // Assert
        expect(result.subtotal, 10000);
        expect(result.deliveryFee, 500);
        expect(result.serviceFee, 300);
        expect(result.paymentFee, 200);
        expect(result.totalAmount, 11000);
      });

      test('should return fallback calculation on API error', () async {
        // Arrange
        when(mockApiClient.post('/pricing/calculate', data: anyNamed('data')))
            .thenThrow(Exception('API Error'));

        // Act
        final result = await dataSource.calculateFees(
          subtotal: 10000,
          deliveryFee: 500,
          paymentMode: 'cash',
        );

        // Assert
        expect(result.subtotal, 10000);
        expect(result.deliveryFee, 500);
        expect(result.serviceFee, 0);
        expect(result.paymentFee, 0);
        expect(result.totalAmount, 10500);
      });
    });

    group('estimateDelivery', () {
      test('should return delivery estimate from API', () async {
        // Arrange
        when(mockApiClient.post('/pricing/delivery', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  data: {
                    'data': {
                      'distance_km': 5.5,
                      'delivery_fee': 750,
                    },
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/pricing/delivery'),
                ));

        // Act
        final result = await dataSource.estimateDelivery(distanceKm: 5.5);

        // Assert
        expect(result.distanceKm, 5.5);
        expect(result.deliveryFee, 750);
      });

      test('should return default estimate on API error', () async {
        // Arrange
        when(mockApiClient.post('/pricing/delivery', data: anyNamed('data')))
            .thenThrow(Exception('API Error'));

        // Act
        final result = await dataSource.estimateDelivery(distanceKm: 3.0);

        // Assert
        expect(result.distanceKm, 3.0);
        expect(result.deliveryFee, 300);
      });
    });
  });

  group('DeliveryPricing', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'base_fee': 300,
          'fee_per_km': 120,
          'min_fee': 400,
          'max_fee': 7000,
        };

        final result = DeliveryPricing.fromJson(json);

        expect(result.baseFee, 300);
        expect(result.feePerKm, 120);
        expect(result.minFee, 400);
        expect(result.maxFee, 7000);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = DeliveryPricing.fromJson(json);

        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = DeliveryPricing.defaults();

        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
      });
    });

    group('calculateFee', () {
      late DeliveryPricing pricing;

      setUp(() {
        pricing = DeliveryPricing(
          baseFee: 200,
          feePerKm: 100,
          minFee: 300,
          maxFee: 5000,
        );
      });

      test('should calculate fee for short distance', () {
        // 200 + (1 * 100) = 300 which equals min
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
        // 200 + (2.7 * 100) = 470, ceil to 470
        expect(pricing.calculateFee(2.7), 470);
      });
    });
  });

  group('ServiceFeeConfig', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'enabled': true,
          'percentage': 5,
          'min': 150,
          'max': 2500,
        };

        final result = ServiceFeeConfig.fromJson(json);

        expect(result.enabled, true);
        expect(result.percentage, 5);
        expect(result.min, 150);
        expect(result.max, 2500);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = ServiceFeeConfig.fromJson(json);

        expect(result.enabled, true);
        expect(result.percentage, 3);
        expect(result.min, 100);
        expect(result.max, 2000);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = ServiceFeeConfig.defaults();

        expect(result.enabled, true);
        expect(result.percentage, 3);
        expect(result.min, 100);
        expect(result.max, 2000);
      });
    });

    group('calculateFee', () {
      test('should calculate 3% of subtotal', () {
        final config = ServiceFeeConfig(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        // 3% of 10000 = 300
        expect(config.calculateFee(10000), 300);
      });

      test('should apply minimum fee', () {
        final config = ServiceFeeConfig(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        // 3% of 1000 = 30, should be 100 (min)
        expect(config.calculateFee(1000), 100);
      });

      test('should apply maximum fee', () {
        final config = ServiceFeeConfig(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        // 3% of 100000 = 3000, should be 2000 (max)
        expect(config.calculateFee(100000), 2000);
      });

      test('should return 0 when disabled', () {
        final config = ServiceFeeConfig(
          enabled: false,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        expect(config.calculateFee(10000), 0);
      });

      test('should round up partial values', () {
        final config = ServiceFeeConfig(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        // 3% of 3333 = 99.99, ceil to 100
        expect(config.calculateFee(3333), 100);
      });
    });
  });

  group('PaymentFeeConfig', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'enabled': true,
          'fixed_fee': 75,
          'percentage': 2.0,
        };

        final result = PaymentFeeConfig.fromJson(json);

        expect(result.enabled, true);
        expect(result.fixedFee, 75);
        expect(result.percentage, 2.0);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = PaymentFeeConfig.fromJson(json);

        expect(result.enabled, true);
        expect(result.fixedFee, 50);
        expect(result.percentage, 1.5);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = PaymentFeeConfig.defaults();

        expect(result.enabled, true);
        expect(result.fixedFee, 50);
        expect(result.percentage, 1.5);
      });
    });

    group('calculateFee', () {
      late PaymentFeeConfig config;

      setUp(() {
        config = PaymentFeeConfig(
          enabled: true,
          fixedFee: 50,
          percentage: 1.5,
        );
      });

      test('should calculate fee for mobile money', () {
        // 50 + ceil(1.5% of 10000) = 50 + 150 = 200
        expect(config.calculateFee(10000, 'mobile_money'), 200);
      });

      test('should return 0 for cash payment', () {
        expect(config.calculateFee(10000, 'cash'), 0);
      });

      test('should return 0 for on_delivery payment', () {
        expect(config.calculateFee(10000, 'on_delivery'), 0);
      });

      test('should return 0 when disabled', () {
        final disabledConfig = PaymentFeeConfig(
          enabled: false,
          fixedFee: 50,
          percentage: 1.5,
        );

        expect(disabledConfig.calculateFee(10000, 'mobile_money'), 0);
      });

      test('should round up partial percentage', () {
        // 50 + ceil(1.5% of 3333) = 50 + ceil(49.995) = 50 + 50 = 100
        expect(config.calculateFee(3333, 'mobile_money'), 100);
      });
    });
  });

  group('PricingCalculation', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'subtotal': 15000,
          'delivery_fee': 800,
          'service_fee': 450,
          'payment_fee': 280,
          'total_amount': 16530,
          'pharmacy_amount': 15000,
        };

        final result = PricingCalculation.fromJson(json);

        expect(result.subtotal, 15000);
        expect(result.deliveryFee, 800);
        expect(result.serviceFee, 450);
        expect(result.paymentFee, 280);
        expect(result.totalAmount, 16530);
        expect(result.pharmacyAmount, 15000);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = PricingCalculation.fromJson(json);

        expect(result.subtotal, 0);
        expect(result.deliveryFee, 0);
        expect(result.serviceFee, 0);
        expect(result.paymentFee, 0);
        expect(result.totalAmount, 0);
        expect(result.pharmacyAmount, 0);
      });
    });

    group('calculate', () {
      test('should calculate all fees correctly for mobile money', () {
        final config = PricingConfig.defaults();

        final result = PricingCalculation.calculate(
          subtotal: 10000,
          deliveryFee: 500,
          paymentMode: 'mobile_money',
          config: config,
        );

        // Service fee: 3% of 10000 = 300
        expect(result.serviceFee, 300);
        
        // Amount before payment: 10000 + 500 + 300 = 10800
        // Payment fee: 50 + ceil(1.5% of 10800) = 50 + 162 = 212
        expect(result.paymentFee, 212);
        
        // Total: 10800 + 212 = 11012
        expect(result.totalAmount, 11012);
        expect(result.pharmacyAmount, 10000);
      });

      test('should calculate with no payment fee for cash', () {
        final config = PricingConfig.defaults();

        final result = PricingCalculation.calculate(
          subtotal: 10000,
          deliveryFee: 500,
          paymentMode: 'cash',
          config: config,
        );

        expect(result.serviceFee, 300);
        expect(result.paymentFee, 0);
        expect(result.totalAmount, 10800); // 10000 + 500 + 300
      });
    });
  });

  group('DeliveryEstimate', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'distance_km': 3.5,
          'delivery_fee': 550,
        };

        final result = DeliveryEstimate.fromJson(json);

        expect(result.distanceKm, 3.5);
        expect(result.deliveryFee, 550);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = DeliveryEstimate.fromJson(json);

        expect(result.distanceKm, 0.0);
        expect(result.deliveryFee, 0);
      });
    });
  });

  group('PricingConfig', () {
    group('fromJson', () {
      test('should parse nested JSON correctly', () {
        final json = {
          'delivery': {
            'base_fee': 300,
            'fee_per_km': 150,
            'min_fee': 400,
            'max_fee': 6000,
          },
          'service': {
            'service_fee': {
              'enabled': true,
              'percentage': 4,
              'min': 150,
              'max': 2500,
            },
            'payment_fee': {
              'enabled': true,
              'fixed_fee': 75,
              'percentage': 2.0,
            },
          },
        };

        final result = PricingConfig.fromJson(json);

        expect(result.delivery.baseFee, 300);
        expect(result.delivery.feePerKm, 150);
        expect(result.service.serviceFee.percentage, 4);
        expect(result.service.paymentFee.fixedFee, 75);
      });
    });

    group('defaults', () {
      test('should create default config', () {
        final result = PricingConfig.defaults();

        expect(result.delivery.baseFee, 200);
        expect(result.service.serviceFee.percentage, 3);
        expect(result.service.paymentFee.fixedFee, 50);
      });
    });
  });

  group('ServicePricing', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'service_fee': {
            'enabled': true,
            'percentage': 5,
            'min': 200,
            'max': 3000,
          },
          'payment_fee': {
            'enabled': false,
            'fixed_fee': 100,
            'percentage': 2.5,
          },
        };

        final result = ServicePricing.fromJson(json);

        expect(result.serviceFee.percentage, 5);
        expect(result.paymentFee.enabled, false);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = ServicePricing.defaults();

        expect(result.serviceFee.enabled, true);
        expect(result.paymentFee.enabled, true);
      });
    });
  });
}
