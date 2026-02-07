import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/profile/presentation/providers/profile_async_provider.dart';

void main() {
  group('ProfileAsyncProvider Tests', () {
    test('profileAsyncProvider should be defined', () {
      expect(profileAsyncProvider, isNotNull);
    });

    test('profileAsyncProvider should be a FutureProvider', () {
      expect(profileAsyncProvider, isA<FutureProvider>());
    });
  });
}
