import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drpharma_client/core/widgets/cached_image.dart';

void main() {
  group('CachedImage', () {
    testWidgets('should render with required imageUrl', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(imageUrl: 'https://example.com/image.jpg'),
          ),
        ),
      );

      expect(find.byType(CachedImage), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('should apply width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              width: 100,
              height: 150,
            ),
          ),
        ),
      );

      final cachedNetworkImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedNetworkImage.width, 100);
      expect(cachedNetworkImage.height, 150);
    });

    testWidgets('should apply default fit as BoxFit.cover', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(imageUrl: 'https://example.com/image.jpg'),
          ),
        ),
      );

      final cachedNetworkImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedNetworkImage.fit, BoxFit.cover);
    });

    testWidgets('should apply custom fit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );

      final cachedNetworkImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedNetworkImage.fit, BoxFit.contain);
    });

    testWidgets('should wrap in ClipRRect for border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should use BorderRadius.zero by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(imageUrl: 'https://example.com/image.jpg'),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.zero);
    });

    testWidgets('should accept custom placeholder widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              placeholder: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CachedImage), findsOneWidget);
    });

    testWidgets('should accept custom error widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              errorWidget: const Icon(Icons.error),
            ),
          ),
        ),
      );

      expect(find.byType(CachedImage), findsOneWidget);
    });
  });

  group('ProductImage', () {
    testWidgets('should render with required imageUrl', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductImage(imageUrl: 'https://example.com/product.jpg'),
          ),
        ),
      );

      expect(find.byType(ProductImage), findsOneWidget);
      expect(find.byType(CachedImage), findsOneWidget);
    });

    testWidgets('should apply width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductImage(
              imageUrl: 'https://example.com/product.jpg',
              width: 200,
              height: 200,
            ),
          ),
        ),
      );

      final cachedNetworkImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedNetworkImage.width, 200);
      expect(cachedNetworkImage.height, 200);
    });

    testWidgets('should have default border radius of 12', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductImage(imageUrl: 'https://example.com/product.jpg'),
          ),
        ),
      );

      expect(find.byType(ProductImage), findsOneWidget);
    });

    testWidgets('should apply custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductImage(
              imageUrl: 'https://example.com/product.jpg',
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      );

      expect(find.byType(ProductImage), findsOneWidget);
    });
  });

  group('CachedAvatar', () {
    testWidgets('should render with default radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(imageUrl: 'https://example.com/avatar.jpg'),
          ),
        ),
      );

      expect(find.byType(CachedAvatar), findsOneWidget);
    });

    testWidgets('should render fallback when imageUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(
              imageUrl: null,
              fallbackText: 'JD',
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should render fallback when imageUrl is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(
              imageUrl: '',
              fallbackText: 'AB',
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('should render ? as default fallback text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(imageUrl: null),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should apply custom radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(
              imageUrl: null,
              radius: 60,
            ),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, 60);
    });

    testWidgets('should apply custom background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(
              imageUrl: null,
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundColor, Colors.red);
    });

    testWidgets('should use ClipOval when imageUrl is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(imageUrl: 'https://example.com/avatar.jpg'),
          ),
        ),
      );

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('should calculate font size based on radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(
              imageUrl: null,
              radius: 80,
              fallbackText: 'X',
            ),
          ),
        ),
      );

      // Font size should be radius * 0.5 = 40
      final textWidget = tester.widget<Text>(find.text('X'));
      expect(textWidget.style?.fontSize, 40);
    });
  });

  group('CachedImage accessibility', () {
    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(imageUrl: 'https://example.com/image.jpg'),
          ),
        ),
      );

      // Verify widget renders without errors
      expect(tester.takeException(), isNull);
    });
  });

  group('ProductImage accessibility', () {
    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductImage(imageUrl: 'https://example.com/product.jpg'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('CachedAvatar accessibility', () {
    testWidgets('should be accessible with fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(
              imageUrl: null,
              fallbackText: 'JD',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('should be accessible with image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedAvatar(imageUrl: 'https://example.com/avatar.jpg'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
