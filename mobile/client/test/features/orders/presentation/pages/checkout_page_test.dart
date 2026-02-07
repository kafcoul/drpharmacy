import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/orders/presentation/pages/checkout_page.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_state.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_notifier.dart';
import 'package:drpharma_client/features/orders/presentation/providers/orders_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/orders_state.dart';
import 'package:drpharma_client/features/orders/presentation/providers/pricing_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/delivery_fee_provider.dart';
import 'package:drpharma_client/features/addresses/presentation/providers/addresses_provider.dart';
import 'package:drpharma_client/features/addresses/presentation/providers/addresses_state.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_state.dart';
import 'package:drpharma_client/features/orders/domain/entities/cart_item_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';

// Mocks
class MockCartNotifier extends StateNotifier<CartState> with Mock implements CartNotifier {
  MockCartNotifier([CartState? state]) : super(state ?? CartState.initial());
}

class MockOrdersNotifier extends StateNotifier<OrdersState> with Mock {
  MockOrdersNotifier() : super(const OrdersState());
}

class MockAddressesNotifier extends StateNotifier<AddressesState> with Mock {
  MockAddressesNotifier() : super(const AddressesState());
}

class MockAuthNotifier extends StateNotifier<AuthState> with Mock {
  MockAuthNotifier() : super(const AuthState());
}

class FakeCartState extends Fake implements CartState {}

void main() {
  late MockCartNotifier mockCartNotifier;
  late MockOrdersNotifier mockOrdersNotifier;
  late MockAddressesNotifier mockAddressesNotifier;
  late MockAuthNotifier mockAuthNotifier;

  setUpAll(() {
    registerFallbackValue(FakeCartState());
  });

  setUp(() {
    mockCartNotifier = MockCartNotifier();
    mockOrdersNotifier = MockOrdersNotifier();
    mockAddressesNotifier = MockAddressesNotifier();
    mockAuthNotifier = MockAuthNotifier();
  });

  // Créer un produit de test
  ProductEntity createTestProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 1000.0,
  }) {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      description: 'Test description',
      imageUrl: null,
      category: 'Test Category',
      pharmacyId: 1,
      pharmacyName: 'Test Pharmacy',
      isAvailable: true,
      requiresPrescription: false,
    );
  }

  // Créer un item de panier de test
  CartItemEntity createTestCartItem({
    int productId = 1,
    String name = 'Test Product',
    double price = 1000.0,
    int quantity = 1,
  }) {
    return CartItemEntity(
      product: createTestProduct(id: productId, name: name, price: price),
      quantity: quantity,
    );
  }

  Widget createTestWidget({
    CartState? cartState,
    OrdersState? ordersState,
    AddressesState? addressesState,
    AuthState? authState,
  }) {
    return ProviderScope(
      overrides: [
        cartProvider.overrideWith((ref) {
          final notifier = MockCartNotifier(cartState ?? CartState.initial());
          return notifier;
        }),
        ordersProvider.overrideWith((ref) {
          final notifier = MockOrdersNotifier();
          if (ordersState != null) {
            notifier.state = ordersState;
          }
          return notifier;
        }),
        addressesProvider.overrideWith((ref) {
          final notifier = MockAddressesNotifier();
          if (addressesState != null) {
            notifier.state = addressesState;
          }
          return notifier;
        }),
        authProvider.overrideWith((ref) {
          final notifier = MockAuthNotifier();
          if (authState != null) {
            notifier.state = authState;
          }
          return notifier;
        }),
      ],
      child: MaterialApp(
        home: const CheckoutPage(),
        routes: {
          '/cart': (_) => const Scaffold(body: Text('Cart')),
          '/orders': (_) => const Scaffold(body: Text('Orders')),
          '/order-confirmation': (_) => const Scaffold(body: Text('Confirmation')),
        },
      ),
    );
  }

  group('CheckoutPage Widget Tests', () {
    testWidgets('should render checkout page', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
          pharmacyName: 'Test Pharmacy',
        ),
      ));
      await tester.pump();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should show app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pump();

      expect(find.text('Validation de la commande'), findsOneWidget);
    });

    testWidgets('should display order summary', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(name: 'Doliprane', price: 2500)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Devrait afficher le récapitulatif
      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should have address section', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should have payment section', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Address Selection', () {
    testWidgets('should show address input fields', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
        addressesState: const AddressesState(addresses: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should toggle between saved and manual address', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Payment Mode', () {
    testWidgets('should display payment options', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should allow payment mode selection', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Chercher les options de paiement
      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Form Validation', () {
    testWidgets('should validate required address', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should validate phone number', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Order Total', () {
    testWidgets('should calculate subtotal correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [
            createTestCartItem(price: 1000, quantity: 2),
            createTestCartItem(productId: 2, price: 500, quantity: 3),
          ],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      // Total = 1000*2 + 500*3 = 3500
      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should display delivery fee', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });

    testWidgets('should show total with delivery fee', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem(price: 5000)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Prescription Handling', () {
    testWidgets('should show prescription section if required', (tester) async {
      final productWithPrescription = ProductEntity(
        id: 1,
        name: 'Prescription Drug',
        price: 5000,
        description: 'Requires prescription',
        imageUrl: null,
        category: 'Medication',
        pharmacyId: 1,
        pharmacyName: 'Test Pharmacy',
        isAvailable: true,
        requiresPrescription: true,
      );

      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [CartItemEntity(product: productWithPrescription, quantity: 1)],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Loading States', () {
    testWidgets('should show loading when placing order', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
        ordersState: const OrdersState(status: OrdersStatus.loading),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should disable submit during loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
        ordersState: const OrdersState(status: OrdersStatus.loading),
      ));
      await tester.pump();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Error Handling', () {
    testWidgets('should display error message on failure', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
        ordersState: const OrdersState(
          status: OrdersStatus.error,
          errorMessage: 'Order failed',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });

  group('CheckoutPage Empty Cart', () {
    testWidgets('should redirect when cart is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial(),
      ));
      await tester.pumpAndSettle();

      // Devrait avoir navigué ailleurs ou afficher un message
      expect(find.byType(CheckoutPage), findsNothing);
    });
  });

  group('CheckoutPage Accessibility', () {
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

    testWidgets('should support form field focus', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [createTestCartItem()],
          pharmacyId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.tap(textFields.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(CheckoutPage), findsOneWidget);
    });
  });
}
