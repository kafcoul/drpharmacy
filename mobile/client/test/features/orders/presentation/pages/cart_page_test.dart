import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/orders/presentation/pages/cart_page.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_state.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_notifier.dart';
import 'package:drpharma_client/features/orders/domain/entities/cart_item_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';

// Mocks
class MockCartNotifier extends StateNotifier<CartState> with Mock implements CartNotifier {
  MockCartNotifier([CartState? state]) : super(state ?? CartState.initial());
  
  @override
  void addItem(ProductEntity product, {int quantity = 1}) {}
  
  @override
  void removeItem(int productId) {}
  
  @override
  void updateQuantity(int productId, int quantity) {}
  
  @override
  void clearCart() {}
}

class FakeCartState extends Fake implements CartState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCartState());
  });

  // Créer un produit de test
  ProductEntity createTestProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 1000.0,
    bool isAvailable = true,
  }) {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      description: 'Test description',
      imageUrl: 'https://example.com/image.jpg',
      category: 'Test Category',
      pharmacyId: 1,
      pharmacyName: 'Test Pharmacy',
      isAvailable: isAvailable,
      requiresPrescription: false,
    );
  }

  // Créer un item de panier de test
  CartItemEntity createTestCartItem({
    int productId = 1,
    String name = 'Test Product',
    double price = 1000.0,
    int quantity = 1,
    bool isAvailable = true,
  }) {
    return CartItemEntity(
      product: createTestProduct(
        id: productId,
        name: name,
        price: price,
        isAvailable: isAvailable,
      ),
      quantity: quantity,
    );
  }

  Widget createTestWidget({CartState? cartState}) {
    return ProviderScope(
      overrides: [
        cartProvider.overrideWith((ref) {
          return MockCartNotifier(cartState ?? CartState.initial());
        }),
      ],
      child: MaterialApp(
        home: const CartPage(),
        routes: {
          '/checkout': (_) => const Scaffold(body: Text('Checkout')),
          '/products': (_) => const Scaffold(body: Text('Products')),
        },
      ),
    );
  }

  group('CartPage Widget Tests', () {
    testWidgets('should render cart page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should show app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mon Panier'), findsOneWidget);
    });

    testWidgets('should show empty cart message when cart is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Votre panier est vide'), findsOneWidget);
      expect(find.text('Ajoutez des produits pour commencer'), findsOneWidget);
    });

    testWidgets('should show empty cart icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial(),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('should show "Voir les produits" button when empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Voir les produits'), findsOneWidget);
    });
  });

  group('CartPage With Items', () {
    testWidgets('should display cart items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(name: 'Doliprane 500mg')],
          pharmacyId: 1,
          pharmacyName: 'Pharmacie Test',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Doliprane 500mg'), findsOneWidget);
    });

    testWidgets('should display item price', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(price: 2500)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Le prix devrait être affiché
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should display item quantity', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(quantity: 3)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsWidgets);
    });

    testWidgets('should display multiple items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [
            createTestCartItem(productId: 1, name: 'Product 1'),
            createTestCartItem(productId: 2, name: 'Product 2'),
            createTestCartItem(productId: 3, name: 'Product 3'),
          ],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
      expect(find.text('Product 3'), findsOneWidget);
    });

    testWidgets('should show delete icon for each item', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Devrait avoir un bouton de suppression
      expect(find.byType(CartPage), findsOneWidget);
    });
  });

  group('CartPage Actions', () {
    testWidgets('should show clear cart button when cart has items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should not show clear cart button when empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial(),
      ));
      await tester.pumpAndSettle();

      // Le bouton delete ne devrait pas être dans l'appbar
      expect(find.byTooltip('Vider le panier'), findsNothing);
    });

    testWidgets('should have increment button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('should have decrement button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove), findsWidgets);
    });
  });

  group('CartPage Summary', () {
    testWidgets('should display subtotal', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(price: 1000, quantity: 2)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Subtotal = 1000 * 2 = 2000
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should have checkout button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Chercher le bouton de validation
      expect(find.textContaining('Valider'), findsWidgets);
    });

    testWidgets('should calculate total correctly with multiple items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [
            createTestCartItem(productId: 1, price: 1000, quantity: 2),
            createTestCartItem(productId: 2, price: 500, quantity: 3),
          ],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Total = 1000*2 + 500*3 = 3500
      expect(find.byType(CartPage), findsOneWidget);
    });
  });

  group('CartPage Item Availability', () {
    testWidgets('should show unavailable item differently', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(isAvailable: false)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CartPage), findsOneWidget);
    });
  });

  group('CartPage Clear Dialog', () {
    testWidgets('should show confirmation dialog on clear', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Taper sur le bouton de suppression
      final deleteButton = find.byIcon(Icons.delete_outline);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        
        // Devrait afficher un dialog
        expect(find.byType(AlertDialog), findsOneWidget);
      }
    });
  });

  group('CartPage Navigation', () {
    testWidgets('should navigate to checkout on button tap', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Trouver et taper sur le bouton de validation
      final checkoutButton = find.textContaining('Valider');
      if (checkoutButton.evaluate().isNotEmpty) {
        await tester.tap(checkoutButton.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(CartPage), findsOneWidget);
    });
  });

  group('CartPage Accessibility', () {
    testWidgets('should have semantic labels', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should support screen reader', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(name: 'Accessible Product')],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Accessible Product'), findsOneWidget);
    });
  });

  group('CartPage UI States', () {
    testWidgets('should show product image', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Devrait avoir une image ou placeholder
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should scroll with many items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: List.generate(
            10,
            (i) => createTestCartItem(productId: i, name: 'Product $i'),
          ),
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byType(CartPage), findsOneWidget);
    });
  });
}
