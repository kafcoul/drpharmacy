import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/prescriptions/presentation/providers/prescriptions_provider.dart';

void main() {
  group('PrescriptionsProvider Tests', () {
    test('prescriptionsProvider should be defined', () {
      expect(prescriptionsProvider, isNotNull);
    });

    test('prescriptionsProvider should be a StateNotifierProvider', () {
      expect(prescriptionsProvider, isA<StateNotifierProvider>());
    });
  });
}
