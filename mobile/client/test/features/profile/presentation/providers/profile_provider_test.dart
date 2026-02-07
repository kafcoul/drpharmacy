import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/profile/presentation/providers/profile_provider.dart';
import 'package:drpharma_client/features/profile/presentation/providers/profile_state.dart';

void main() {
  group('ProfileProvider Tests', () {
    test('profileProvider should be defined', () {
      expect(profileProvider, isNotNull);
    });

    test('profileProvider should be a StateNotifierProvider', () {
      expect(profileProvider, isA<StateNotifierProvider>());
    });

    test('ProfileState should have initial state', () {
      const state = ProfileState.initial();
      expect(state.isLoading, false);
      expect(state.profile, isNull);
      expect(state.error, isNull);
    });

    test('ProfileState should have loading state', () {
      const state = ProfileState.loading();
      expect(state.isLoading, true);
    });

    test('ProfileState should have error state', () {
      const state = ProfileState.error('Test error');
      expect(state.error, 'Test error');
    });
  });
}
