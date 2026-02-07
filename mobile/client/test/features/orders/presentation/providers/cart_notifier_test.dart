import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_notifier.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_state.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/category_entity.dart';

@GenerateMocks([SharedPreferences])
import 'cart_notifier_test.mocks.dart';

void main() {
  late CartNotifier cartNotifier;
  late MockSharedPreferences mockSharedPreferences;

  // Test fixtures
  final testPharmacy = const PharmacyEntity(
    id: 1,
    name: 'Pharmacie Test',
    address: '123 Test St',
    phone: '0123456789',
    email: 'test@pharmacy.com',
    status: 'active',
    isOpen: true,
  );

  final testPharmacy2 = const PharmacyEntity(
    id: 2,
    name: 'Pharmacie Autre',
    address: '456 Autre St',
    phone: '9876543210',
    status: 'active',
    isOpen: true,
  );

  final testCategory = const CategoryEntity(
    id: 1,
    name: 'Médicaments',
    description: 'Tous les médicaments',
  );

  final testProduct = ProductEntity(
    id: 1,
    name: 'Paracétamol 500mg',
    description: 'Antidouleur',
    price: 1500.0,
    stockQuantity: 10,
    requiresPrescription: false,
    pharmacy: testPharmacy,
    category: testCategory,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testProduct2 = ProductEntity(
    id: 2,
    name: 'Ibuprofène 400mg',
    description: 'Anti-inflammatoire',
    price: 2000.0,
    stockQuantity: 5,
    requiresPrescription: false,
    pharmacy: testPharmacy,
    category: testCategory,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final productFromOtherPharmacy = ProductEntity(
    id: 3,
    name: 'Aspirine',
    description: 'Antidouleur',
    price: 1000.0,
    stockQuantity: 20,
    requiresPrescription: false,
    pharmacy: testPharmacy2,
    category: testCategory,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final outOfStockProduct = ProductEntity(
    id: 4,
    name: 'Produit Epuisé',
    description: 'Pas de stock',
    price: 500.0,
    stockQuantity: 0,
    requiresPrescription: false,
    pharmacy: testPharmacy,
    category: testCategory,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    
    // Default: empty cart
    when(mockSharedPreferences.getString(any)).thenReturn(null);
    when(mockSharedPreferences.setString(any, any))
        .thenAnswer((_) async => true);
    when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);

    cartNotifier = CartNotifier(mockSharedPreferences);
  });

  group('CartNotifier initialization', () {
    test('should start with initial empty state', () {
      expect(cartNotifier.state.status, CartStatus.initial);
      expect(cartNotifier.state.items, isEmpty);
      expect(cartNotifier.state.selectedPharmacyId, isNull);
    });
  });

  group('CartNotifier.addItem', () {
    test('should add item to empty cart', () async {
      await cartNotifier.addItem(testProduct);

      expect(cartNotifier.state.status, CartStatus.loaded);
      expect(cartNotifier.state.items.length, 1);
      expect(cartNotifier.state.items.first.product.id, testProduct.id);
      expect(cartNotifier.state.items.first.quantity, 1);
      expect(cartNotifier.state.selectedPharmacyId, testPharmacy.id);
    });

    test('should add item with custom quantity', () async {
      await cartNotifier.addItem(testProduct, quantity: 3);

      expect(cartNotifier.state.items.first.quantity, 3);
    });

    test('should increase quantity when adding existing product', () async {
      await cartNotifier.addItem(testProduct, quantity: 2);
      await cartNotifier.addItem(testProduct, quantity: 3);

      expect(cartNotifier.state.items.length, 1);
      expect(cartNotifier.state.items.first.quantity, 5);
    });

    test('should add multiple different products', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.addItem(testProduct2);

      expect(cartNotifier.state.items.length, 2);
    });

    test('should fail when adding product from different pharmacy', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.addItem(productFromOtherPharmacy);

      expect(cartNotifier.state.status, CartStatus.error);
      expect(cartNotifier.state.errorMessage, contains('une seule pharmacie'));
      // Cart should still have only the first item
      expect(cartNotifier.state.items.length, 1);
    });

    test('should fail when product is out of stock', () async {
      await cartNotifier.addItem(outOfStockProduct);

      expect(cartNotifier.state.status, CartStatus.error);
      expect(cartNotifier.state.errorMessage, contains('plus disponible'));
    });

    test('should fail when requested quantity exceeds stock', () async {
      await cartNotifier.addItem(testProduct, quantity: 100);

      expect(cartNotifier.state.status, CartStatus.error);
      expect(cartNotifier.state.errorMessage, contains('Stock insuffisant'));
    });

    test('should fail when cumulative quantity exceeds stock', () async {
      await cartNotifier.addItem(testProduct, quantity: 8);
      await cartNotifier.addItem(testProduct, quantity: 5);

      expect(cartNotifier.state.status, CartStatus.error);
      expect(cartNotifier.state.errorMessage, contains('Stock insuffisant'));
    });

    test('should not add item with zero quantity', () async {
      await cartNotifier.addItem(testProduct, quantity: 0);

      expect(cartNotifier.state.items, isEmpty);
    });

    test('should persist cart after adding item', () async {
      await cartNotifier.addItem(testProduct);

      verify(mockSharedPreferences.setString(any, any)).called(1);
    });
  });

  group('CartNotifier.removeItem', () {
    test('should remove item from cart', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.addItem(testProduct2);

      await cartNotifier.removeItem(testProduct.id);

      expect(cartNotifier.state.items.length, 1);
      expect(cartNotifier.state.items.first.product.id, testProduct2.id);
    });

    test('should clear pharmacy when removing last item', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.removeItem(testProduct.id);

      expect(cartNotifier.state.items, isEmpty);
      expect(cartNotifier.state.selectedPharmacyId, isNull);
    });

    test('should do nothing when removing non-existent item', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.removeItem(999);

      expect(cartNotifier.state.items.length, 1);
    });
  });

  group('CartNotifier.updateQuantity', () {
    test('should update item quantity', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.updateQuantity(testProduct.id, 5);

      expect(cartNotifier.state.items.first.quantity, 5);
    });

    test('should remove item when quantity set to zero', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.updateQuantity(testProduct.id, 0);

      expect(cartNotifier.state.items, isEmpty);
    });

    test('should remove item when quantity set to negative', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.updateQuantity(testProduct.id, -1);

      expect(cartNotifier.state.items, isEmpty);
    });

    test('should fail when new quantity exceeds stock', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.updateQuantity(testProduct.id, 100);

      expect(cartNotifier.state.status, CartStatus.error);
      expect(cartNotifier.state.errorMessage, contains('Stock insuffisant'));
    });

    test('should do nothing when updating non-existent item', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.updateQuantity(999, 5);

      expect(cartNotifier.state.items.first.quantity, 1);
    });
  });

  group('CartNotifier.clearCart', () {
    test('should empty cart completely', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.addItem(testProduct2);
      await cartNotifier.clearCart();

      expect(cartNotifier.state.status, CartStatus.initial);
      expect(cartNotifier.state.items, isEmpty);
      expect(cartNotifier.state.selectedPharmacyId, isNull);
    });

    test('should remove persisted cart', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.clearCart();

      verify(mockSharedPreferences.remove(any)).called(1);
    });
  });

  group('CartNotifier.clearError', () {
    test('should clear error message', () async {
      await cartNotifier.addItem(outOfStockProduct);
      expect(cartNotifier.state.status, CartStatus.error);

      cartNotifier.clearError();

      expect(cartNotifier.state.errorMessage, isNull);
      expect(cartNotifier.state.status, CartStatus.initial);
    });

    test('should set status to loaded if cart has items', () async {
      await cartNotifier.addItem(testProduct);
      await cartNotifier.addItem(testProduct, quantity: 100); // Exceeds stock
      expect(cartNotifier.state.status, CartStatus.error);

      cartNotifier.clearError();

      expect(cartNotifier.state.status, CartStatus.loaded);
    });
  });

  group('CartState calculations', () {
    test('should calculate correct subtotal', () async {
      await cartNotifier.addItem(testProduct, quantity: 2); // 1500 * 2 = 3000
      await cartNotifier.addItem(testProduct2, quantity: 1); // 2000 * 1 = 2000

      expect(cartNotifier.state.subtotal, 5000.0);
    });

    test('should calculate correct total quantity', () async {
      await cartNotifier.addItem(testProduct, quantity: 2);
      await cartNotifier.addItem(testProduct2, quantity: 3);

      expect(cartNotifier.state.totalQuantity, 5);
    });

    test('should calculate delivery fee when cart has items', () async {
      await cartNotifier.addItem(testProduct);

      expect(cartNotifier.state.deliveryFee, 300.0); // defaultMinDeliveryFee
    });

    test('should have zero delivery fee for empty cart', () {
      expect(cartNotifier.state.deliveryFee, 0.0);
    });

    test('should calculate correct total with delivery', () async {
      await cartNotifier.addItem(testProduct, quantity: 2); // 3000
      // Total = 3000 + 300 (delivery) = 3300

      expect(cartNotifier.state.total, 3300.0);
    });
  });
}
