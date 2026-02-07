import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/providers/delivery_fee_provider.dart';

void main() {
  group('DeliveryFeeProvider Tests', () {
    test('deliveryFeeProvider should be defined', () {
      expect(deliveryFeeProvider, isNotNull);
    });

    test('deliveryFeeProvider should be a Provider', () {
      expect(deliveryFeeProvider, isA<Provider>());
    });
  });
}
