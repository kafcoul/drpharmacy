import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/domain/entities/pricing_entity.dart';
import 'package:drpharma_client/features/orders/presentation/providers/pricing_provider.dart';

void main() {
  group('PricingState', () {
    group('constructor', () {
      test('should create with default values', () {
        const state = PricingState();

        expect(state.isLoading, false);
        expect(state.config, isNull);
        expect(state.error, isNull);
      });

      test('should create with custom values', () {
        const config = PricingConfigEntity.defaults();
        const state = PricingState(
          isLoading: true,
          config: config,
          error: 'Test error',
        );

        expect(state.isLoading, true);
        expect(state.config, isNotNull);
        expect(state.error, 'Test error');
      });
    });

    group('initial', () {
      test('should create initial state', () {
        const state = PricingState.initial();

        expect(state.isLoading, false);
        expect(state.config, isNull);
        expect(state.error, isNull);
      });
    });

    group('copyWith', () {
      test('should copy with new isLoading', () {
        const state = PricingState();
        final copied = state.copyWith(isLoading: true);

        expect(copied.isLoading, true);
        expect(copied.config, isNull);
        expect(copied.error, isNull);
      });

      test('should copy with new config', () {
        const state = PricingState();
        const config = PricingConfigEntity.defaults();
        final copied = state.copyWith(config: config);

        expect(copied.isLoading, false);
        expect(copied.config, config);
      });

      test('should copy with new error', () {
        const state = PricingState();
        final copied = state.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should set error to null when not provided', () {
        const state = PricingState(error: 'Existing error');
        final copied = state.copyWith(isLoading: true);

        // Error is explicitly set to null in copyWith when not provided
        expect(copied.error, isNull);
      });

      test('should preserve other values when partially updated', () {
        const config = PricingConfigEntity.defaults();
        const state = PricingState(
          isLoading: true,
          config: config,
          error: 'Error',
        );
        final copied = state.copyWith(isLoading: false);

        expect(copied.isLoading, false);
        expect(copied.config, config);
        // Error is cleared by copyWith design
        expect(copied.error, isNull);
      });
    });
  });

  group('PricingConfigEntity', () {
    group('defaults', () {
      test('should create with default values', () {
        const config = PricingConfigEntity.defaults();

        expect(config.delivery, isNotNull);
        expect(config.service, isNotNull);
      });
    });

    group('props', () {
      test('should have correct props for equality', () {
        const config = PricingConfigEntity.defaults();
        expect(config.props, [config.delivery, config.service]);
      });

      test('should be equal for same values', () {
        const config1 = PricingConfigEntity.defaults();
        const config2 = PricingConfigEntity.defaults();

        expect(config1, equals(config2));
      });
    });
  });

  group('DeliveryPricingEntity', () {
    group('defaults', () {
      test('should have correct default values', () {
        const delivery = DeliveryPricingEntity.defaults();

        expect(delivery.baseFee, 200);
        expect(delivery.feePerKm, 100);
        expect(delivery.minFee, 300);
        expect(delivery.maxFee, 5000);
      });
    });

    group('calculateFee', () {
      test('should calculate fee for 1km', () {
        const delivery = DeliveryPricingEntity.defaults();
        final fee = delivery.calculateFee(1.0);

        // 200 (base) + 100 (1km * 100) = 300
        expect(fee, 300);
      });

      test('should calculate fee for 5km', () {
        const delivery = DeliveryPricingEntity.defaults();
        final fee = delivery.calculateFee(5.0);

        // 200 (base) + 500 (5km * 100) = 700
        expect(fee, 700);
      });

      test('should clamp to minimum fee', () {
        const delivery = DeliveryPricingEntity.defaults();
        final fee = delivery.calculateFee(0.5);

        // 200 (base) + 50 (0.5km * 100) = 250, clamped to 300 (minFee)
        expect(fee, 300);
      });

      test('should clamp to maximum fee', () {
        const delivery = DeliveryPricingEntity.defaults();
        final fee = delivery.calculateFee(100.0);

        // 200 (base) + 10000 (100km * 100) = 10200, clamped to 5000 (maxFee)
        expect(fee, 5000);
      });

      test('should round up for fractional distances', () {
        const delivery = DeliveryPricingEntity.defaults();
        final fee = delivery.calculateFee(2.3);

        // 200 (base) + ceil(230) = 430
        expect(fee, 430);
      });
    });

    group('props', () {
      test('should have correct props', () {
        const delivery = DeliveryPricingEntity.defaults();
        expect(delivery.props, [200, 100, 300, 5000]);
      });

      test('should be equal for same values', () {
        const delivery1 = DeliveryPricingEntity.defaults();
        const delivery2 = DeliveryPricingEntity.defaults();

        expect(delivery1, equals(delivery2));
      });
    });
  });

  group('ServiceFeeConfigEntity', () {
    group('defaults', () {
      test('should have correct default values', () {
        const serviceFee = ServiceFeeConfigEntity.defaults();

        expect(serviceFee.enabled, true);
        expect(serviceFee.percentage, 3);
        expect(serviceFee.min, 100);
        expect(serviceFee.max, 2000);
      });
    });

    group('calculateFee', () {
      test('should calculate fee for normal amount', () {
        const serviceFee = ServiceFeeConfigEntity.defaults();
        final fee = serviceFee.calculateFee(5000);

        // 5000 * 3% = 150
        expect(fee, 150);
      });

      test('should clamp to minimum', () {
        const serviceFee = ServiceFeeConfigEntity.defaults();
        final fee = serviceFee.calculateFee(1000);

        // 1000 * 3% = 30, clamped to 100 (min)
        expect(fee, 100);
      });

      test('should clamp to maximum', () {
        const serviceFee = ServiceFeeConfigEntity.defaults();
        final fee = serviceFee.calculateFee(100000);

        // 100000 * 3% = 3000, clamped to 2000 (max)
        expect(fee, 2000);
      });

      test('should return 0 when disabled', () {
        const serviceFee = ServiceFeeConfigEntity(
          enabled: false,
          percentage: 3,
          min: 100,
          max: 2000,
        );
        final fee = serviceFee.calculateFee(5000);

        expect(fee, 0);
      });
    });
  });

  group('PaymentFeeConfigEntity', () {
    group('defaults', () {
      test('should have correct default values', () {
        const paymentFee = PaymentFeeConfigEntity.defaults();

        expect(paymentFee.enabled, true);
        expect(paymentFee.fixedFee, 50);
        expect(paymentFee.percentage, 1.5);
      });
    });

    group('calculateFee', () {
      test('should calculate fee for mobile payment', () {
        const paymentFee = PaymentFeeConfigEntity.defaults();
        final fee = paymentFee.calculateFee(10000, 'mobile_money');

        // 50 (fixed) + ceil(10000 * 1.5%) = 50 + 150 = 200
        expect(fee, 200);
      });

      test('should return 0 for cash payment', () {
        const paymentFee = PaymentFeeConfigEntity.defaults();
        final fee = paymentFee.calculateFee(10000, 'cash');

        expect(fee, 0);
      });

      test('should return 0 for on_delivery payment', () {
        const paymentFee = PaymentFeeConfigEntity.defaults();
        final fee = paymentFee.calculateFee(10000, 'on_delivery');

        expect(fee, 0);
      });

      test('should return 0 when disabled', () {
        const paymentFee = PaymentFeeConfigEntity(
          enabled: false,
          fixedFee: 50,
          percentage: 1.5,
        );
        final fee = paymentFee.calculateFee(10000, 'mobile_money');

        expect(fee, 0);
      });

      test('should handle card payment', () {
        const paymentFee = PaymentFeeConfigEntity.defaults();
        final fee = paymentFee.calculateFee(5000, 'card');

        // 50 (fixed) + ceil(5000 * 1.5%) = 50 + 75 = 125
        expect(fee, 125);
      });
    });

    group('cashModes', () {
      test('should contain cash modes', () {
        expect(PaymentFeeConfigEntity.cashModes, contains('cash'));
        expect(PaymentFeeConfigEntity.cashModes, contains('on_delivery'));
      });
    });
  });

  group('ServicePricingEntity', () {
    group('defaults', () {
      test('should create with default sub-entities', () {
        const service = ServicePricingEntity.defaults();

        expect(service.serviceFee, isNotNull);
        expect(service.paymentFee, isNotNull);
      });
    });

    group('props', () {
      test('should be equal for same values', () {
        const service1 = ServicePricingEntity.defaults();
        const service2 = ServicePricingEntity.defaults();

        expect(service1, equals(service2));
      });
    });
  });
}
