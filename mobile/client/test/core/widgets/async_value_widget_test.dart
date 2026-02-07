import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/widgets/async_value_widget.dart';

void main() {
  group('AsyncValueWidget', () {
    Widget buildTestWidget({
      required AsyncValue<String> value,
      Widget Function(String)? data,
      Widget Function()? loading,
      Widget Function(Object, StackTrace?)? error,
      Widget Function()? empty,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AsyncValueWidget<String>(
            value: value,
            data: data ?? (d) => Text('Data: $d'),
            loading: loading,
            error: error,
            empty: empty,
          ),
        ),
      );
    }

    group('data state', () {
      testWidgets('should display data when AsyncValue has data', (tester) async {
        // Arrange
        const value = AsyncValue.data('Hello World');

        // Act
        await tester.pumpWidget(buildTestWidget(value: value));

        // Assert
        expect(find.text('Data: Hello World'), findsOneWidget);
      });

      testWidgets('should use custom data builder', (tester) async {
        // Arrange
        const value = AsyncValue.data('Custom');

        // Act
        await tester.pumpWidget(buildTestWidget(
          value: value,
          data: (d) => Container(
            key: const Key('custom-data'),
            child: Text('Custom: $d'),
          ),
        ));

        // Assert
        expect(find.byKey(const Key('custom-data')), findsOneWidget);
        expect(find.text('Custom: Custom'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show default loading indicator', (tester) async {
        // Arrange
        const value = AsyncValue<String>.loading();

        // Act
        await tester.pumpWidget(buildTestWidget(value: value));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should use custom loading widget', (tester) async {
        // Arrange
        const value = AsyncValue<String>.loading();

        // Act
        await tester.pumpWidget(buildTestWidget(
          value: value,
          loading: () => const Text('Loading...'),
        ));

        // Assert
        expect(find.text('Loading...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('error state', () {
      testWidgets('should show default error widget', (tester) async {
        // Arrange
        final value = AsyncValue<String>.error(Exception('Test error'), StackTrace.current);

        // Act
        await tester.pumpWidget(buildTestWidget(value: value));

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Une erreur est survenue'), findsOneWidget);
      });

      testWidgets('should use custom error widget', (tester) async {
        // Arrange
        final value = AsyncValue<String>.error(Exception('Custom error'), StackTrace.current);

        // Act
        await tester.pumpWidget(buildTestWidget(
          value: value,
          error: (e, st) => Text('Error: ${e.toString()}'),
        ));

        // Assert
        expect(find.textContaining('Error:'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsNothing);
      });
    });

    group('empty state', () {
      testWidgets('should show default empty widget for null data', (tester) async {
        // Arrange
        const value = AsyncValue<String?>.data(null);

        // Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String?>(
              value: value,
              data: (d) => Text('Data: $d'),
            ),
          ),
        ));

        // Assert
        // Default empty widget shows "Aucune donnée" or similar
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('should show default empty widget for empty list', (tester) async {
        // Arrange
        const value = AsyncValue<List<String>>.data([]);

        // Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<List<String>>(
              value: value,
              data: (d) => Text('Items: ${d.length}'),
            ),
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('should use custom empty widget', (tester) async {
        // Arrange
        const value = AsyncValue<List<String>>.data([]);

        // Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<List<String>>(
              value: value,
              data: (d) => Text('Items: ${d.length}'),
              empty: () => const Text('No items found'),
            ),
          ),
        ));

        // Assert
        expect(find.text('No items found'), findsOneWidget);
      });
    });

    group('skipLoadingOnRefresh', () {
      testWidgets('should respect skipLoadingOnRefresh setting', (tester) async {
        // Arrange - create a widget with skipLoadingOnRefresh = false
        const value = AsyncValue<String>.loading();

        // Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: value,
              data: (d) => Text('Data: $d'),
              skipLoadingOnRefresh: false,
            ),
          ),
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });

  group('AsyncValueSliverWidget', () {
    testWidgets('should work in a CustomScrollView', (tester) async {
      // Arrange
      const value = AsyncValue.data('Sliver Data');

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              AsyncValueSliverWidget<String>(
                value: value,
                data: (d) => SliverToBoxAdapter(
                  child: Text('Data: $d'),
                ),
              ),
            ],
          ),
        ),
      ));

      // Assert
      expect(find.text('Data: Sliver Data'), findsOneWidget);
    });

    testWidgets('should show sliver loading', (tester) async {
      // Arrange
      const value = AsyncValue<String>.loading();

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              AsyncValueSliverWidget<String>(
                value: value,
                data: (d) => SliverToBoxAdapter(child: Text('Data: $d')),
              ),
            ],
          ),
        ),
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show sliver error', (tester) async {
      // Arrange
      final value = AsyncValue<String>.error(Exception('Sliver error'), StackTrace.current);

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              AsyncValueSliverWidget<String>(
                value: value,
                data: (d) => SliverToBoxAdapter(child: Text('Data: $d')),
              ),
            ],
          ),
        ),
      ));

      // Assert - default sliver error shows text
      expect(find.textContaining('Erreur:'), findsOneWidget);
    });
  });
}
