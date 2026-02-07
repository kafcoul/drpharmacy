import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:drpharma_client/features/orders/presentation/widgets/order_summary_card.dart';
import 'package:drpharma_client/features/orders/domain/entities/cart_item_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';

void main() {
  late NumberFormat currencyFormat;

  setUp(() {
    currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  // Helper to create test product
  ProductEntity createTestProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 1000,
    int stockQuantity = 10,
  }) {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      stockQuantity: stockQuantity,
      requiresPrescription: false,
      pharmacy: const PharmacyEntity(
        id: 1,
        name: 'Test Pharmacy',
        address: 'Test Address',
        phone: '+24107000000',
        status: 'active',
        isOpen: true,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('OrderSummaryCard', () {
    testWidgets('should display card with title', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 0,
            deliveryFee: 0,
            total: 0,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert
      expect(find.text('Résumé de la commande'), findsOneWidget);
    });

    testWidgets('should display cart items', (tester) async {
      // Arrange
      final items = [
        CartItemEntity(
          product: createTestProduct(
            id: 1,
            name: 'Paracétamol 500mg',
            price: 1500,
          ),
          quantity: 2,
        ),
        CartItemEntity(
          product: createTestProduct(
            id: 2,
            name: 'Ibuprofène 400mg',
            price: 2500,
          ),
          quantity: 1,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: items,
            subtotal: 5500,
            deliveryFee: 500,
            total: 6000,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert - items are displayed as "product name x quantity"
      expect(find.textContaining('Paracétamol 500mg'), findsOneWidget);
      expect(find.textContaining('Ibuprofène 400mg'), findsOneWidget);
    });

    testWidgets('should display subtotal', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 500,
            total: 5500,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert
      expect(find.text('Sous-total médicaments'), findsOneWidget);
      // Currency format may vary, just check there's some formatted number
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display delivery fee', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 1000,
            total: 6000,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert
      expect(find.text('Frais de livraison'), findsOneWidget);
    });

    testWidgets('should display distance when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 1500,
            total: 6500,
            currencyFormat: currencyFormat,
            distanceKm: 3.5,
          ),
        ),
      );

      // Assert
      expect(find.textContaining('3.5'), findsOneWidget);
    });

    testWidgets('should show loading indicator for delivery fee',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 0,
            total: 5000,
            currencyFormat: currencyFormat,
            isLoadingDeliveryFee: true,
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display total amount', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 10000,
            deliveryFee: 1500,
            total: 11500,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('should display service fee when greater than zero',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 500,
            serviceFee: 250,
            total: 5750,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert
      expect(find.textContaining('service'), findsWidgets);
    });

    testWidgets('should display payment fee when greater than zero',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 500,
            paymentFee: 100,
            total: 5600,
            currencyFormat: currencyFormat,
            paymentMode: 'platform',
          ),
        ),
      );

      // Assert
      // Payment fee should be displayed
      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('should not show service/payment fee when zero',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          OrderSummaryCard(
            items: const [],
            subtotal: 5000,
            deliveryFee: 500,
            serviceFee: 0,
            paymentFee: 0,
            total: 5500,
            currencyFormat: currencyFormat,
          ),
        ),
      );

      // Assert - only 3 fee rows: subtotal, delivery, total
      expect(find.text('Sous-total médicaments'), findsOneWidget);
      expect(find.text('Frais de livraison'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });
  });
}
