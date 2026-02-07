import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/domain/entities/pricing_entity.dart';

void main() {
  group('PricingConfigEntity', () {
    const tPricingConfig = PricingConfigEntity(
      delivery: DeliveryPricingEntity(
        baseFee: 250,
        feePerKm: 120,
        minFee: 350,
        maxFee: 6000,
      ),
      service: ServicePricingEntity(
        serviceFee: ServiceFeeConfigEntity(
          enabled: true,
          percentage: 5,
          min: 150,
          max: 2500,
        ),
        paymentFee: PaymentFeeConfigEntity(
          enabled: true,
          fixedFee: 75,
          percentage: 2.0,
        ),
      ),
    );

    group('Constructor', () {
      test('should create valid PricingConfigEntity', () {
        expect(tPricingConfig.delivery, isNotNull);
        expect(tPricingConfig.service, isNotNull);
      });
    });

    group('defaults', () {
      test('should create PricingConfigEntity with default values', () {
        const defaults = PricingConfigEntity.defaults();

        expect(defaults.delivery.baseFee, 200);
        expect(defaults.delivery.feePerKm, 100);
        expect(defaults.delivery.minFee, 300);
        expect(defaults.delivery.maxFee, 5000);

        expect(defaults.service.serviceFee.enabled, true);
        expect(defaults.service.serviceFee.percentage, 3);
        expect(defaults.service.serviceFee.min, 100);
        expect(defaults.service.serviceFee.max, 2000);

        expect(defaults.service.paymentFee.enabled, true);
        expect(defaults.service.paymentFee.fixedFee, 50);
        expect(defaults.service.paymentFee.percentage, 1.5);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal configs', () {
        const config1 = PricingConfigEntity.defaults();
        const config2 = PricingConfigEntity.defaults();

        expect(config1, config2);
      });
    });
  });

  group('DeliveryPricingEntity', () {
    const tDeliveryPricing = DeliveryPricingEntity(
      baseFee: 200,
      feePerKm: 100,
      minFee: 300,
      maxFee: 5000,
    );

    group('Constructor', () {
      test('should create valid DeliveryPricingEntity', () {
        expect(tDeliveryPricing.baseFee, 200);
        expect(tDeliveryPricing.feePerKm, 100);
        expect(tDeliveryPricing.minFee, 300);
        expect(tDeliveryPricing.maxFee, 5000);
      });
    });

    group('defaults', () {
      test('should create entity with default values', () {
        const defaults = DeliveryPricingEntity.defaults();

        expect(defaults.baseFee, 200);
        expect(defaults.feePerKm, 100);
        expect(defaults.minFee, 300);
        expect(defaults.maxFee, 5000);
      });
    });

    group('calculateFee', () {
      test('should calculate fee correctly for 1km', () {
        final fee = tDeliveryPricing.calculateFee(1.0);

        // baseFee (200) + 1km * feePerKm (100) = 300
        expect(fee, 300);
      });

      test('should calculate fee correctly for 5km', () {
        final fee = tDeliveryPricing.calculateFee(5.0);

        // baseFee (200) + 5km * feePerKm (100) = 700
        expect(fee, 700);
      });

      test('should calculate fee correctly for 10km', () {
        final fee = tDeliveryPricing.calculateFee(10.0);

        // baseFee (200) + 10km * feePerKm (100) = 1200
        expect(fee, 1200);
      });

      test('should clamp to minFee when calculated fee is too low', () {
        final fee = tDeliveryPricing.calculateFee(0.5);

        // baseFee (200) + 0.5km * feePerKm (100) = 250, clamped to 300
        expect(fee, 300);
      });

      test('should clamp to maxFee when calculated fee is too high', () {
        final fee = tDeliveryPricing.calculateFee(100.0);

        // baseFee (200) + 100km * feePerKm (100) = 10200, clamped to 5000
        expect(fee, 5000);
      });

      test('should return minFee for zero distance', () {
        final fee = tDeliveryPricing.calculateFee(0.0);

        // baseFee (200), clamped to minFee (300)
        expect(fee, 300);
      });

      test('should handle decimal distances correctly', () {
        final fee = tDeliveryPricing.calculateFee(2.5);

        // baseFee (200) + 2.5km * feePerKm (100) = 450
        expect(fee, 450);
      });

      test('should ceil fractional distances', () {
        final fee = tDeliveryPricing.calculateFee(2.3);

        // baseFee (200) + ceil(2.3 * 100) = 200 + 230 = 430
        expect(fee, 430);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const pricing1 = DeliveryPricingEntity(
          baseFee: 200,
          feePerKm: 100,
          minFee: 300,
          maxFee: 5000,
        );

        const pricing2 = DeliveryPricingEntity(
          baseFee: 200,
          feePerKm: 100,
          minFee: 300,
          maxFee: 5000,
        );

        expect(pricing1, pricing2);
      });

      test('should return false when baseFee is different', () {
        const pricing1 = DeliveryPricingEntity(
          baseFee: 200,
          feePerKm: 100,
          minFee: 300,
          maxFee: 5000,
        );

        const pricing2 = DeliveryPricingEntity(
          baseFee: 300,
          feePerKm: 100,
          minFee: 300,
          maxFee: 5000,
        );

        expect(pricing1, isNot(pricing2));
      });
    });
  });

  group('ServicePricingEntity', () {
    const tServicePricing = ServicePricingEntity(
      serviceFee: ServiceFeeConfigEntity(
        enabled: true,
        percentage: 3,
        min: 100,
        max: 2000,
      ),
      paymentFee: PaymentFeeConfigEntity(
        enabled: true,
        fixedFee: 50,
        percentage: 1.5,
      ),
    );

    group('Constructor', () {
      test('should create valid ServicePricingEntity', () {
        expect(tServicePricing.serviceFee, isNotNull);
        expect(tServicePricing.paymentFee, isNotNull);
      });
    });

    group('defaults', () {
      test('should create entity with default values', () {
        const defaults = ServicePricingEntity.defaults();

        expect(defaults.serviceFee.enabled, true);
        expect(defaults.serviceFee.percentage, 3);
        expect(defaults.paymentFee.enabled, true);
        expect(defaults.paymentFee.fixedFee, 50);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const service1 = ServicePricingEntity.defaults();
        const service2 = ServicePricingEntity.defaults();

        expect(service1, service2);
      });
    });
  });

  group('ServiceFeeConfigEntity', () {
    const tServiceFee = ServiceFeeConfigEntity(
      enabled: true,
      percentage: 3,
      min: 100,
      max: 2000,
    );

    group('Constructor', () {
      test('should create valid ServiceFeeConfigEntity', () {
        expect(tServiceFee.enabled, true);
        expect(tServiceFee.percentage, 3);
        expect(tServiceFee.min, 100);
        expect(tServiceFee.max, 2000);
      });
    });

    group('defaults', () {
      test('should create entity with default values', () {
        const defaults = ServiceFeeConfigEntity.defaults();

        expect(defaults.enabled, true);
        expect(defaults.percentage, 3);
        expect(defaults.min, 100);
        expect(defaults.max, 2000);
      });
    });

    group('calculateFee', () {
      test('should return 0 when disabled', () {
        const disabledFee = ServiceFeeConfigEntity(
          enabled: false,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        final fee = disabledFee.calculateFee(10000);
        expect(fee, 0);
      });

      test('should calculate fee correctly for 5000 subtotal', () {
        final fee = tServiceFee.calculateFee(5000);

        // 5000 * 3% = 150
        expect(fee, 150);
      });

      test('should calculate fee correctly for 10000 subtotal', () {
        final fee = tServiceFee.calculateFee(10000);

        // 10000 * 3% = 300
        expect(fee, 300);
      });

      test('should clamp to min when fee is too low', () {
        final fee = tServiceFee.calculateFee(1000);

        // 1000 * 3% = 30, clamped to min (100)
        expect(fee, 100);
      });

      test('should clamp to max when fee is too high', () {
        final fee = tServiceFee.calculateFee(100000);

        // 100000 * 3% = 3000, clamped to max (2000)
        expect(fee, 2000);
      });

      test('should return min for zero subtotal', () {
        final fee = tServiceFee.calculateFee(0);

        // 0 * 3% = 0, clamped to min (100)
        expect(fee, 100);
      });

      test('should ceil fractional fees', () {
        final fee = tServiceFee.calculateFee(3333);

        // 3333 * 3% = 99.99, ceil = 100
        expect(fee, 100);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const fee1 = ServiceFeeConfigEntity(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        const fee2 = ServiceFeeConfigEntity(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        expect(fee1, fee2);
      });

      test('should return false when percentage is different', () {
        const fee1 = ServiceFeeConfigEntity(
          enabled: true,
          percentage: 3,
          min: 100,
          max: 2000,
        );

        const fee2 = ServiceFeeConfigEntity(
          enabled: true,
          percentage: 5,
          min: 100,
          max: 2000,
        );

        expect(fee1, isNot(fee2));
      });
    });
  });

  group('PaymentFeeConfigEntity', () {
    const tPaymentFee = PaymentFeeConfigEntity(
      enabled: true,
      fixedFee: 50,
      percentage: 1.5,
    );

    group('Constructor', () {
      test('should create valid PaymentFeeConfigEntity', () {
        expect(tPaymentFee.enabled, true);
        expect(tPaymentFee.fixedFee, 50);
        expect(tPaymentFee.percentage, 1.5);
      });
    });

    group('defaults', () {
      test('should create entity with default values', () {
        const defaults = PaymentFeeConfigEntity.defaults();

        expect(defaults.enabled, true);
        expect(defaults.fixedFee, 50);
        expect(defaults.percentage, 1.5);
      });
    });

    group('cashModes', () {
      test('should contain cash and on_delivery', () {
        expect(PaymentFeeConfigEntity.cashModes, contains('cash'));
        expect(PaymentFeeConfigEntity.cashModes, contains('on_delivery'));
        expect(PaymentFeeConfigEntity.cashModes.length, 2);
      });
    });

    group('calculateFee', () {
      test('should return 0 when disabled', () {
        const disabledFee = PaymentFeeConfigEntity(
          enabled: false,
          fixedFee: 50,
          percentage: 1.5,
        );

        final fee = disabledFee.calculateFee(10000, 'card');
        expect(fee, 0);
      });

      test('should return 0 for cash payment', () {
        final fee = tPaymentFee.calculateFee(10000, 'cash');
        expect(fee, 0);
      });

      test('should return 0 for on_delivery payment', () {
        final fee = tPaymentFee.calculateFee(10000, 'on_delivery');
        expect(fee, 0);
      });

      test('should calculate fee correctly for card payment', () {
        final fee = tPaymentFee.calculateFee(10000, 'card');

        // fixedFee (50) + (10000 * 1.5%) = 50 + 150 = 200
        expect(fee, 200);
      });

      test('should calculate fee correctly for mobile_money', () {
        final fee = tPaymentFee.calculateFee(5000, 'mobile_money');

        // fixedFee (50) + (5000 * 1.5%) = 50 + 75 = 125
        expect(fee, 125);
      });

      test('should ceil fractional percentage fees', () {
        final fee = tPaymentFee.calculateFee(1000, 'card');

        // fixedFee (50) + ceil(1000 * 1.5%) = 50 + 15 = 65
        expect(fee, 65);
      });

      test('should handle large amounts', () {
        final fee = tPaymentFee.calculateFee(100000, 'card');

        // fixedFee (50) + (100000 * 1.5%) = 50 + 1500 = 1550
        expect(fee, 1550);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const fee1 = PaymentFeeConfigEntity(
          enabled: true,
          fixedFee: 50,
          percentage: 1.5,
        );

        const fee2 = PaymentFeeConfigEntity(
          enabled: true,
          fixedFee: 50,
          percentage: 1.5,
        );

        expect(fee1, fee2);
      });

      test('should return false when fixedFee is different', () {
        const fee1 = PaymentFeeConfigEntity(
          enabled: true,
          fixedFee: 50,
          percentage: 1.5,
        );

        const fee2 = PaymentFeeConfigEntity(
          enabled: true,
          fixedFee: 100,
          percentage: 1.5,
        );

        expect(fee1, isNot(fee2));
      });
    });
  });

  group('PricingCalculationEntity', () {
    const tCalculation = PricingCalculationEntity(
      subtotal: 10000,
      deliveryFee: 500,
      serviceFee: 300,
      paymentFee: 200,
      totalAmount: 11000,
      pharmacyAmount: 10000,
    );

    group('Constructor', () {
      test('should create valid PricingCalculationEntity', () {
        expect(tCalculation.subtotal, 10000);
        expect(tCalculation.deliveryFee, 500);
        expect(tCalculation.serviceFee, 300);
        expect(tCalculation.paymentFee, 200);
        expect(tCalculation.totalAmount, 11000);
        expect(tCalculation.pharmacyAmount, 10000);
      });
    });

    group('calculate factory', () {
      const config = PricingConfigEntity.defaults();

      test('should calculate pricing correctly for cash payment', () {
        final result = PricingCalculationEntity.calculate(
          subtotal: 10000,
          deliveryFee: 500,
          paymentMode: 'cash',
          config: config,
        );

        expect(result.subtotal, 10000);
        expect(result.deliveryFee, 500);
        // serviceFee: 10000 * 3% = 300
        expect(result.serviceFee, 300);
        // paymentFee: 0 (cash mode)
        expect(result.paymentFee, 0);
        // total: 10000 + 500 + 300 + 0 = 10800
        expect(result.totalAmount, 10800);
        expect(result.pharmacyAmount, 10000);
      });

      test('should calculate pricing correctly for card payment', () {
        final result = PricingCalculationEntity.calculate(
          subtotal: 10000,
          deliveryFee: 500,
          paymentMode: 'card',
          config: config,
        );

        expect(result.subtotal, 10000);
        expect(result.deliveryFee, 500);
        // serviceFee: 10000 * 3% = 300
        expect(result.serviceFee, 300);
        // amountBeforePayment: 10000 + 500 + 300 = 10800
        // paymentFee: 50 + ceil(10800 * 1.5%) = 50 + 162 = 212
        expect(result.paymentFee, 212);
        // total: 10800 + 212 = 11012
        expect(result.totalAmount, 11012);
        expect(result.pharmacyAmount, 10000);
      });

      test('should calculate pricing correctly with on_delivery payment', () {
        final result = PricingCalculationEntity.calculate(
          subtotal: 5000,
          deliveryFee: 300,
          paymentMode: 'on_delivery',
          config: config,
        );

        expect(result.subtotal, 5000);
        expect(result.deliveryFee, 300);
        // serviceFee: 5000 * 3% = 150
        expect(result.serviceFee, 150);
        // paymentFee: 0 (on_delivery mode)
        expect(result.paymentFee, 0);
        // total: 5000 + 300 + 150 + 0 = 5450
        expect(result.totalAmount, 5450);
        expect(result.pharmacyAmount, 5000);
      });

      test('should handle minimum service fee', () {
        final result = PricingCalculationEntity.calculate(
          subtotal: 1000,
          deliveryFee: 300,
          paymentMode: 'cash',
          config: config,
        );

        expect(result.subtotal, 1000);
        // serviceFee: 1000 * 3% = 30, clamped to min 100
        expect(result.serviceFee, 100);
        expect(result.totalAmount, 1400); // 1000 + 300 + 100
      });

      test('should handle large subtotal with max service fee', () {
        final result = PricingCalculationEntity.calculate(
          subtotal: 100000,
          deliveryFee: 500,
          paymentMode: 'cash',
          config: config,
        );

        expect(result.subtotal, 100000);
        // serviceFee: 100000 * 3% = 3000, clamped to max 2000
        expect(result.serviceFee, 2000);
        expect(result.totalAmount, 102500); // 100000 + 500 + 2000
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal calculations', () {
        const calc1 = PricingCalculationEntity(
          subtotal: 10000,
          deliveryFee: 500,
          serviceFee: 300,
          paymentFee: 200,
          totalAmount: 11000,
          pharmacyAmount: 10000,
        );

        const calc2 = PricingCalculationEntity(
          subtotal: 10000,
          deliveryFee: 500,
          serviceFee: 300,
          paymentFee: 200,
          totalAmount: 11000,
          pharmacyAmount: 10000,
        );

        expect(calc1, calc2);
      });

      test('should return false when totals are different', () {
        const calc1 = PricingCalculationEntity(
          subtotal: 10000,
          deliveryFee: 500,
          serviceFee: 300,
          paymentFee: 200,
          totalAmount: 11000,
          pharmacyAmount: 10000,
        );

        const calc2 = PricingCalculationEntity(
          subtotal: 10000,
          deliveryFee: 500,
          serviceFee: 300,
          paymentFee: 200,
          totalAmount: 12000,
          pharmacyAmount: 10000,
        );

        expect(calc1, isNot(calc2));
      });

      test('should have same hashCode for equal calculations', () {
        const calc1 = PricingCalculationEntity(
          subtotal: 5000,
          deliveryFee: 300,
          serviceFee: 150,
          paymentFee: 0,
          totalAmount: 5450,
          pharmacyAmount: 5000,
        );

        const calc2 = PricingCalculationEntity(
          subtotal: 5000,
          deliveryFee: 300,
          serviceFee: 150,
          paymentFee: 0,
          totalAmount: 5450,
          pharmacyAmount: 5000,
        );

        expect(calc1.hashCode, calc2.hashCode);
      });
    });
  });
}
