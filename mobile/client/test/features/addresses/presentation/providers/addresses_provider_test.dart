import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/addresses/presentation/providers/addresses_provider.dart';

void main() {
  group('AddressesProvider Tests', () {
    test('addressesProvider should be defined', () {
      expect(addressesProvider, isNotNull);
    });

    test('addressesProvider should be a StateNotifierProvider', () {
      expect(addressesProvider, isA<StateNotifierProvider>());
    });
  });
}
