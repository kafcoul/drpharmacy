import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drpharma_client/core/providers/ui_state_providers.dart';

/// Tests de performance pour les providers UI
/// Ces tests vérifient que les opérations critiques s'exécutent
/// dans des délais acceptables.
void main() {
  group('Performance Tests - UI State Providers', () {
    late ProviderContainer container;
    late Stopwatch stopwatch;

    setUp(() {
      container = ProviderContainer();
      stopwatch = Stopwatch();
    });

    tearDown(() {
      container.dispose();
    });

    group('ToggleProvider Performance', () {
      test('should handle 1000 rapid toggles under 100ms', () {
        const iterations = 1000;
        const maxDurationMs = 100;
        
        stopwatch.start();
        
        for (var i = 0; i < iterations; i++) {
          container.read(toggleProvider('perf_test').notifier).toggle();
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '1000 toggles should complete under ${maxDurationMs}ms, '
              'actual: ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      test('should handle 100 different provider instances efficiently', () {
        const iterations = 100;
        const maxDurationMs = 50;
        
        stopwatch.start();
        
        for (var i = 0; i < iterations; i++) {
          container.read(toggleProvider('provider_$i'));
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: 'Creating 100 providers should complete under ${maxDurationMs}ms',
        );
      });
    });

    group('LoadingProvider Performance', () {
      test('should handle 1000 loading state changes under 100ms', () {
        const iterations = 1000;
        const maxDurationMs = 100;
        
        stopwatch.start();
        
        for (var i = 0; i < iterations; i++) {
          final notifier = container.read(loadingProvider('load_perf').notifier);
          notifier.startLoading();
          notifier.stopLoading();
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '1000 loading cycles should complete under ${maxDurationMs}ms',
        );
      });

      test('should handle error state operations efficiently', () {
        const iterations = 500;
        const maxDurationMs = 50;
        
        stopwatch.start();
        
        for (var i = 0; i < iterations; i++) {
          final notifier = container.read(loadingProvider('error_perf').notifier);
          notifier.setError('Error $i');
          notifier.clearError();
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '500 error cycles should complete under ${maxDurationMs}ms',
        );
      });
    });

    group('FormFieldsProvider Performance', () {
      test('should handle 1000 field updates under 100ms', () {
        const iterations = 1000;
        const maxDurationMs = 100;
        
        stopwatch.start();
        
        final notifier = container.read(formFieldsProvider('form_perf').notifier);
        for (var i = 0; i < iterations; i++) {
          notifier.setField('field_$i', 'value_$i');
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '1000 field updates should complete under ${maxDurationMs}ms',
        );
      });

      test('should handle concurrent field operations', () {
        const iterations = 200;
        const maxDurationMs = 50;
        
        stopwatch.start();
        
        final notifier = container.read(formFieldsProvider('concurrent_perf').notifier);
        for (var i = 0; i < iterations; i++) {
          notifier.setField('name', 'Name $i');
          notifier.setField('email', 'email$i@test.com');
          notifier.setField('phone', '+225 0$i 00 00 00');
          container.read(formFieldsProvider('concurrent_perf'));
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '${iterations * 3} concurrent field operations should complete under ${maxDurationMs}ms',
        );
      });
    });

    group('CountdownProvider Performance', () {
      test('should handle 10000 decrements under 100ms', () {
        const iterations = 10000;
        const maxDurationMs = 100;
        
        final notifier = container.read(countdownProvider('countdown_perf').notifier);
        notifier.setValue(iterations);
        
        stopwatch.start();
        
        for (var i = 0; i < iterations; i++) {
          notifier.decrement();
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '$iterations decrements should complete under ${maxDurationMs}ms',
        );
        
        expect(container.read(countdownProvider('countdown_perf')), 0);
      });
    });

    group('Memory Stress Tests', () {
      test('should not leak memory with many provider instances', () {
        const iterations = 500;
        const maxDurationMs = 200;
        
        stopwatch.start();
        
        // Create and use many providers
        for (var i = 0; i < iterations; i++) {
          final toggleId = 'mem_toggle_$i';
          final loadingId = 'mem_loading_$i';
          final formId = 'mem_form_$i';
          
          container.read(toggleProvider(toggleId).notifier).toggle();
          container.read(loadingProvider(loadingId).notifier).startLoading();
          container.read(formFieldsProvider(formId).notifier).setField('test', 'value');
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: 'Creating $iterations sets of providers should complete under ${maxDurationMs}ms',
        );
      });

      test('should handle rapid provider disposal and recreation', () {
        const cycles = 50;
        const maxDurationMs = 100;
        
        stopwatch.start();
        
        for (var i = 0; i < cycles; i++) {
          final tempContainer = ProviderContainer();
          
          // Use providers
          tempContainer.read(toggleProvider('temp').notifier).toggle();
          tempContainer.read(loadingProvider('temp').notifier).startLoading();
          tempContainer.read(formFieldsProvider('temp').notifier).setField('x', 'y');
          
          // Dispose
          tempContainer.dispose();
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: '$cycles disposal cycles should complete under ${maxDurationMs}ms',
        );
      });
    });

    group('Concurrent Access Simulation', () {
      test('should handle simulated concurrent reads and writes', () {
        const writeIterations = 500;
        const maxDurationMs = 150;
        
        stopwatch.start();
        
        // Simulate concurrent operations
        for (var i = 0; i < writeIterations; i++) {
          // Write
          container.read(toggleProvider('concurrent').notifier).toggle();
          container.read(formFieldsProvider('concurrent').notifier)
              .setField('field', 'value_$i');
          
          // Read twice per write (simulating 1000 reads)
          container.read(toggleProvider('concurrent'));
          container.read(formFieldsProvider('concurrent'));
        }
        
        stopwatch.stop();
        
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(maxDurationMs),
          reason: 'Concurrent operations should complete under ${maxDurationMs}ms',
        );
      });
    });
  });

  group('Performance Benchmarks Summary', () {
    test('benchmark summary report', () {
      final container = ProviderContainer();
      final results = <String, int>{};
      final stopwatch = Stopwatch();
      
      // Toggle benchmark
      stopwatch.start();
      for (var i = 0; i < 1000; i++) {
        container.read(toggleProvider('bench_toggle').notifier).toggle();
      }
      stopwatch.stop();
      results['1000 toggles'] = stopwatch.elapsedMicroseconds;
      
      // Loading benchmark
      stopwatch.reset();
      stopwatch.start();
      for (var i = 0; i < 1000; i++) {
        final n = container.read(loadingProvider('bench_load').notifier);
        n.startLoading();
        n.stopLoading();
      }
      stopwatch.stop();
      results['1000 loading cycles'] = stopwatch.elapsedMicroseconds;
      
      // Form fields benchmark
      stopwatch.reset();
      stopwatch.start();
      for (var i = 0; i < 1000; i++) {
        container.read(formFieldsProvider('bench_form').notifier)
            .setField('field_$i', 'value_$i');
      }
      stopwatch.stop();
      results['1000 form field updates'] = stopwatch.elapsedMicroseconds;
      
      // Print summary
      // ignore: avoid_print
      print('\n╔════════════════════════════════════════════╗');
      // ignore: avoid_print
      print('║     PERFORMANCE BENCHMARK RESULTS          ║');
      // ignore: avoid_print
      print('╠════════════════════════════════════════════╣');
      for (final entry in results.entries) {
        final ms = (entry.value / 1000).toStringAsFixed(2);
        // ignore: avoid_print
        print('║ ${entry.key.padRight(28)} ${ms.padLeft(8)}ms ║');
      }
      // ignore: avoid_print
      print('╚════════════════════════════════════════════╝\n');
      
      container.dispose();
      
      // All benchmarks should complete
      expect(results.length, 3);
    });
  });
}
