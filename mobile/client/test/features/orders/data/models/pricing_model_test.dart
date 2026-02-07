import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/orders/data/models/pricing_model.dart';

void main() {
  group('PricingConfigModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
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
        };

        final result = PricingConfigModel.fromJson(json);

        expect(result.delivery.baseFee, 300);
        expect(result.delivery.feePerKm, 150);
        expect(result.service.serviceFee.percentage, 5);
        expect(result.service.paymentFee.fixedFee, 100);
      });

      test('should handle empty json', () {
        final json = <String, dynamic>{};

        final result = PricingConfigModel.fromJson(json);

        expect(result.delivery.baseFee, 200);
        expect(result.service.serviceFee.percentage, 3);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = PricingConfigModel.defaults();

        expect(result.delivery.baseFee, 200);
        expect(result.delivery.feePerKm, 100);
        expect(result.service.serviceFee.percentage, 3);
        expect(result.service.paymentFee.fixedFee, 50);
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = PricingConfigModel.defaults();

        final entity = model.toEntity();

        expect(entity.delivery.baseFee, 200);
        expect(entity.service.serviceFee.percentage, 3);
      });
    });
  });

  group('DeliveryPricingModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'base_fee': 300,
          'fee_per_km': 150,
          'min_fee': 400,
          'max_fee': 6000,
        };

        final result = DeliveryPricingModel.fromJson(json);

        expect(result.baseFee, 300);
        expect(result.feePerKm, 150);
        expect(result.minFee, 400);
        expect(result.maxFee, 6000);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = DeliveryPricingModel.fromJson(json);

        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = DeliveryPricingModel.defaults();

        expect(result.baseFee, 200);
        expect(result.feePerKm, 100);
        expect(result.minFee, 300);
        expect(result.maxFee, 5000);
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = DeliveryPricingModel(
          baseFee: 250,
          feePerKm: 120,
          minFee: 350,
          maxFee: 5500,
        );

        final entity = model.toEntity();

        expect(entity.baseFee, 250);
        expect(entity.feePerKm, 120);
        expect(entity.minFee, 350);
        expect(entity.maxFee, 5500);
      });
    });
  });

  group('ServicePricingModel', () {
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
            'fixed_fee': 75,
            'percentage': 2.0,
          },
        };

        final result = ServicePricingModel.fromJson(json);

        expect(result.serviceFee.percentage, 5);
        expect(result.paymentFee.enabled, false);
        expect(result.paymentFee.fixedFee, 75);
      });

      test('should handle empty json', () {
        final json = <String, dynamic>{};

        final result = ServicePricingModel.fromJson(json);

        expect(result.serviceFee.percentage, 3);
        expect(result.paymentFee.fixedFee, 50);
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = ServicePricingModel.defaults();

        expect(result.serviceFee.enabled, true);
        expect(result.paymentFee.enabled, true);
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = ServicePricingModel.defaults();

        final entity = model.toEntity();

        expect(entity.serviceFee.enabled, true);
        expect(entity.paymentFee.enabled, true);
      });
    });
  });

  group('ServiceFeeConfigModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'enabled': true,
          'percentage': 5,
          'min': 200,
          'max': 3000,
        };

        final result = ServiceFeeConfigModel.fromJson(json);

        expect(result.enabled, true);
        expect(result.percentage, 5);
        expect(result.min, 200);
        expect(result.max, 3000);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = ServiceFeeConfigModel.fromJson(json);

        expect(result.enabled, true);
        expect(result.percentage, 3);
        expect(result.min, 100);
        expect(result.max, 2000);
      });

      test('should convert integer percentage to double', () {
        final json = {'percentage': 5};

        final result = ServiceFeeConfigModel.fromJson(json);

        expect(result.percentage, 5.0);
        expect(result.percentage, isA<double>());
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = ServiceFeeConfigModel.defaults();

        expect(result.enabled, true);
        expect(result.percentage, 3);
        expect(result.min, 100);
        expect(result.max, 2000);
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = ServiceFeeConfigModel(
          enabled: false,
          percentage: 4.5,
          min: 150,
          max: 2500,
        );

        final entity = model.toEntity();

        expect(entity.enabled, false);
        expect(entity.percentage, 4.5);
        expect(entity.min, 150);
        expect(entity.max, 2500);
      });
    });
  });

  group('PaymentFeeConfigModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'enabled': true,
          'fixed_fee': 75,
          'percentage': 2.0,
        };

        final result = PaymentFeeConfigModel.fromJson(json);

        expect(result.enabled, true);
        expect(result.fixedFee, 75);
        expect(result.percentage, 2.0);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = PaymentFeeConfigModel.fromJson(json);

        expect(result.enabled, true);
        expect(result.fixedFee, 50);
        expect(result.percentage, 1.5);
      });

      test('should convert integer percentage to double', () {
        final json = {'percentage': 2};

        final result = PaymentFeeConfigModel.fromJson(json);

        expect(result.percentage, 2.0);
        expect(result.percentage, isA<double>());
      });
    });

    group('defaults', () {
      test('should create default values', () {
        final result = PaymentFeeConfigModel.defaults();

        expect(result.enabled, true);
        expect(result.fixedFee, 50);
        expect(result.percentage, 1.5);
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = PaymentFeeConfigModel(
          enabled: false,
          fixedFee: 100,
          percentage: 2.5,
        );

        final entity = model.toEntity();

        expect(entity.enabled, false);
        expect(entity.fixedFee, 100);
        expect(entity.percentage, 2.5);
      });
    });
  });

  group('PricingCalculationModel', () {
    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {
          'subtotal': 10000,
          'delivery_fee': 500,
          'service_fee': 300,
          'payment_fee': 200,
          'total_amount': 11000,
          'pharmacy_amount': 10000,
        };

        final result = PricingCalculationModel.fromJson(json);

        expect(result.subtotal, 10000);
        expect(result.deliveryFee, 500);
        expect(result.serviceFee, 300);
        expect(result.paymentFee, 200);
        expect(result.totalAmount, 11000);
        expect(result.pharmacyAmount, 10000);
      });

      test('should use defaults for missing fields', () {
        final json = <String, dynamic>{};

        final result = PricingCalculationModel.fromJson(json);

        expect(result.subtotal, 0);
        expect(result.deliveryFee, 0);
        expect(result.serviceFee, 0);
        expect(result.paymentFee, 0);
        expect(result.totalAmount, 0);
        expect(result.pharmacyAmount, 0);
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly', () {
        final model = PricingCalculationModel(
          subtotal: 15000,
          deliveryFee: 800,
          serviceFee: 450,
          paymentFee: 280,
          totalAmount: 16530,
          pharmacyAmount: 15000,
        );

        final entity = model.toEntity();

        expect(entity.subtotal, 15000);
        expect(entity.deliveryFee, 800);
        expect(entity.serviceFee, 450);
        expect(entity.paymentFee, 280);
        expect(entity.totalAmount, 16530);
        expect(entity.pharmacyAmount, 15000);
      });
    });
  });
}
