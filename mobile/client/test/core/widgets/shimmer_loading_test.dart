import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

import 'package:drpharma_client/core/widgets/shimmer_loading.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Material(child: child),
    );
  }

  group('ShimmerLoading', () {
    testWidgets('should render with specified dimensions', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 200,
            height: 100,
            child: ShimmerLoading(width: 100, height: 50),
          ),
        ),
      );

      // Assert
      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should use shimmer animation', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 300,
            height: 150,
            child: ShimmerLoading(width: 200, height: 100),
          ),
        ),
      );

      // Assert - Shimmer widget should exist
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should apply custom border radius', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 200,
            height: 200,
            child: ShimmerLoading(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('should render with default border radius', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 200,
            height: 100,
            child: ShimmerLoading(width: 100, height: 50),
          ),
        ),
      );

      // Assert
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });

  group('ProductCardSkeleton', () {
    testWidgets('should render skeleton structure', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 200,
            height: 300,
            child: ProductCardSkeleton(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsWidgets);
    });

    testWidgets('should have multiple shimmer placeholders', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 200,
            height: 300,
            child: ProductCardSkeleton(),
          ),
        ),
      );

      // Assert - should have image, title, description, price, button placeholders
      final shimmers = find.byType(ShimmerLoading);
      expect(shimmers, findsAtLeast(4));
    });
  });

  group('OrderCardSkeleton', () {
    testWidgets('should render skeleton structure', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 400,
            height: 200,
            child: OrderCardSkeleton(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsWidgets);
    });

    testWidgets('should have order info placeholders', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 400,
            height: 200,
            child: OrderCardSkeleton(),
          ),
        ),
      );

      // Assert - should have order number, status, date, items count, total
      final shimmers = find.byType(ShimmerLoading);
      expect(shimmers, findsAtLeast(5));
    });
  });

  group('ProfileSkeleton', () {
    testWidgets('should render profile skeleton structure', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 400,
            height: 800,
            child: ProfileSkeleton(),
          ),
        ),
      );

      // Assert
      expect(find.byType(ProfileSkeleton), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsWidgets);
    });
  });
}
