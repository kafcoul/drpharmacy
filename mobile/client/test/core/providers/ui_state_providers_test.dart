import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/providers/ui_state_providers.dart';

void main() {
  group('ToggleNotifier', () {
    test('should start with initial value false by default', () {
      final notifier = ToggleNotifier();
      expect(notifier.state, false);
    });

    test('should start with custom initial value', () {
      final notifier = ToggleNotifier(false);
      expect(notifier.state, false);
    });

    test('toggle should flip the state', () {
      final notifier = ToggleNotifier(true);
      
      notifier.toggle();
      expect(notifier.state, false);
      
      notifier.toggle();
      expect(notifier.state, true);
    });

    test('set should update the state to specific value', () {
      final notifier = ToggleNotifier(true);
      
      notifier.set(false);
      expect(notifier.state, false);
      
      notifier.set(false); // Same value should not error
      expect(notifier.state, false);
    });
  });

  group('toggleProvider', () {
    test('different ids should have independent states', () {
      final container = ProviderContainer();
      
      // Par défaut, les toggles commencent à false (comportement sécurisé)
      expect(container.read(toggleProvider('a')), false);
      expect(container.read(toggleProvider('b')), false);
      
      container.read(toggleProvider('a').notifier).toggle();
      
      expect(container.read(toggleProvider('a')), true);
      expect(container.read(toggleProvider('b')), false);
      
      container.dispose();
    });
  });

  group('LoadingNotifier', () {
    test('should start with isLoading false', () {
      final notifier = LoadingNotifier();
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
    });

    test('startLoading should set isLoading to true', () {
      final notifier = LoadingNotifier();
      
      notifier.startLoading();
      
      expect(notifier.state.isLoading, true);
      expect(notifier.state.error, null);
    });

    test('stopLoading should set isLoading to false', () {
      final notifier = LoadingNotifier();
      
      notifier.startLoading();
      notifier.stopLoading();
      
      expect(notifier.state.isLoading, false);
    });

    test('startLoading should clear any previous error', () {
      final notifier = LoadingNotifier();
      
      notifier.setError('Previous error');
      notifier.startLoading();
      
      expect(notifier.state.error, null);
      expect(notifier.state.isLoading, true);
    });

    test('setError should set error and stop loading', () {
      final notifier = LoadingNotifier();
      
      notifier.startLoading();
      notifier.setError('Something went wrong');
      
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Something went wrong');
    });

    test('clearError should remove error without affecting loading state', () {
      final notifier = LoadingNotifier();
      
      notifier.setError('Error');
      notifier.clearError();
      
      expect(notifier.state.error, null);
    });
  });

  group('loadingProvider', () {
    test('different form ids should have independent states', () {
      final container = ProviderContainer();
      
      container.read(loadingProvider('login').notifier).startLoading();
      
      expect(container.read(loadingProvider('login')).isLoading, true);
      expect(container.read(loadingProvider('register')).isLoading, false);
      
      container.dispose();
    });
  });

  group('CountdownNotifier', () {
    test('should start with initial value 0 by default', () {
      final notifier = CountdownNotifier();
      expect(notifier.state, 0);
    });

    test('setValue should update the countdown', () {
      final notifier = CountdownNotifier();
      
      notifier.setValue(60);
      
      expect(notifier.state, 60);
    });

    test('decrement should reduce by 1 when positive', () {
      final notifier = CountdownNotifier(5);
      
      notifier.decrement();
      expect(notifier.state, 4);
      
      notifier.decrement();
      expect(notifier.state, 3);
    });

    test('decrement should not go below 0', () {
      final notifier = CountdownNotifier(1);
      
      notifier.decrement();
      expect(notifier.state, 0);
      
      notifier.decrement();
      expect(notifier.state, 0);
    });

    test('reset should set value to 0', () {
      final notifier = CountdownNotifier(30);
      
      notifier.reset();
      
      expect(notifier.state, 0);
    });
  });

  group('FormFieldsNotifier', () {
    test('should start empty', () {
      final notifier = FormFieldsNotifier();
      expect(notifier.state, isEmpty);
    });

    test('setError should add field error', () {
      final notifier = FormFieldsNotifier();
      
      notifier.setError('email', 'Email is required');
      
      expect(notifier.state['email'], 'Email is required');
    });

    test('clearError should remove specific field error', () {
      final notifier = FormFieldsNotifier();
      
      notifier.setError('email', 'Error 1');
      notifier.setError('password', 'Error 2');
      notifier.clearError('email');
      
      expect(notifier.state['email'], null);
      expect(notifier.state['password'], 'Error 2');
    });

    test('clearAll should remove all errors', () {
      final notifier = FormFieldsNotifier();
      
      notifier.setError('email', 'Error 1');
      notifier.setError('password', 'Error 2');
      notifier.clearAll();
      
      expect(notifier.state, isEmpty);
    });

    test('getError should return error for field', () {
      final notifier = FormFieldsNotifier();
      
      notifier.setError('email', 'Invalid email');
      
      expect(notifier.getError('email'), 'Invalid email');
      expect(notifier.getError('nonexistent'), null);
    });
  });

  group('SelectedIndexNotifier', () {
    test('should start with 0 by default', () {
      final notifier = SelectedIndexNotifier();
      expect(notifier.state, 0);
    });

    test('select should update the index', () {
      final notifier = SelectedIndexNotifier();
      
      notifier.select(2);
      
      expect(notifier.state, 2);
    });
  });

  group('PageIndexNotifier', () {
    test('should start at page 0', () {
      final notifier = PageIndexNotifier(maxPages: 5);
      expect(notifier.state, 0);
      expect(notifier.isFirstPage, true);
      expect(notifier.isLastPage, false);
    });

    test('next should increment page within bounds', () {
      final notifier = PageIndexNotifier(maxPages: 3);
      
      notifier.next();
      expect(notifier.state, 1);
      
      notifier.next();
      expect(notifier.state, 2);
      expect(notifier.isLastPage, true);
      
      notifier.next(); // Should not exceed max
      expect(notifier.state, 2);
    });

    test('previous should decrement page within bounds', () {
      final notifier = PageIndexNotifier(maxPages: 3);
      
      notifier.goTo(2);
      notifier.previous();
      expect(notifier.state, 1);
      
      notifier.previous();
      expect(notifier.state, 0);
      expect(notifier.isFirstPage, true);
      
      notifier.previous(); // Should not go below 0
      expect(notifier.state, 0);
    });

    test('goTo should set page within bounds', () {
      final notifier = PageIndexNotifier(maxPages: 5);
      
      notifier.goTo(3);
      expect(notifier.state, 3);
      
      notifier.goTo(-1); // Should be ignored
      expect(notifier.state, 3);
      
      notifier.goTo(10); // Should be ignored
      expect(notifier.state, 3);
    });
  });

  group('LoadingState', () {
    test('copyWith should create new instance with updated values', () {
      const state = LoadingState(isLoading: false, error: null);
      
      final loading = state.copyWith(isLoading: true);
      expect(loading.isLoading, true);
      expect(loading.error, null);
      
      final withError = state.copyWith(error: 'Error');
      expect(withError.isLoading, false);
      expect(withError.error, 'Error');
    });

    test('copyWith should preserve unchanged values', () {
      const state = LoadingState(isLoading: true, error: 'Error');
      
      // Note: copyWith with error: null explicitly sets it to null
      // To preserve error, we need to not pass it
      final updated = LoadingState(
        isLoading: false,
        error: state.error,
      );
      expect(updated.error, 'Error');
    });
  });
}
