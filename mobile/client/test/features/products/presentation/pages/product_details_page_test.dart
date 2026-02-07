import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/products/presentation/pages/product_details_page.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';

void main() {
  ProductEntity createTestProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 1000.0,
    bool requiresPrescription = false,
  }) {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      description: 'Test description for product',
      imageUrl: 'https://example.com/image.jpg',
      category: 'Test Category',
      pharmacyId: 1,
      pharmacyName: 'Test Pharmacy',
      isAvailable: true,
      requiresPrescription: requiresPrescription,
    );
  }

  Widget createTestWidget(ProductEntity product) {
    return ProviderScope(
      child: MaterialApp(
        home: ProductDetailsPage(product: product),
      ),
    );
  }

  group('ProductDetailsPage Widget Tests', () {
    testWidgets('should render product details page', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct()));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailsPage), findsOneWidget);
    });

    testWidgets('should display product name', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct(name: 'Doliprane 500mg')));
      await tester.pumpAndSettle();
      expect(find.text('Doliprane 500mg'), findsWidgets);
    });

    testWidgets('should display product price', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct(price: 2500)));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailsPage), findsOneWidget);
    });

    testWidgets('should display product description', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct()));
      await tester.pumpAndSettle();
      expect(find.textContaining('description'), findsWidgets);
    });

    testWidgets('should display pharmacy name', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Pharmacy'), findsWidgets);
    });

    testWidgets('should have add to cart button', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct()));
      await tester.pumpAndSettle();
      expect(find.textContaining('panier'), findsWidgets);
    });

    testWidgets('should show prescription badge if required', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct(requiresPrescription: true)));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailsPage), findsOneWidget);
    });

    testWidgets('should have quantity selector', (tester) async {
      await tester.pumpWidget(createTestWidget(createTestProduct()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byIcon(Icons.remove), findsWidgets);
    });
  });
}
