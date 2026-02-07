import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/orders/presentation/providers/cart_state.dart';
import 'package:drpharma_client/features/orders/domain/entities/cart_item_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';

void main() {
  group('CartStatus', () {
    test('should have all expected values', () {
      expect(CartStatus.values.length, 4);
      expect(CartStatus.values, contains(CartStatus.initial));
      expect(CartStatus.values, contains(CartStatus.loading));
      expect(CartStatus.values, contains(CartStatus.loaded));
      expect(CartStatus.values, contains(CartStatus.error));
    });
  });

  group('CartState', () {
    late PharmacyEntity testPharmacy;
    late ProductEntity testProduct;
    late CartItemEntity testCartItem;

    setUp(() {
      testPharmacy = const PharmacyEntity(
        id: 1,
        name: 'Pharmacie Test',
        address: '123 Rue Test',
        phone: '+24112345678',
        status: 'active',
        isOpen: true,
      );

      testProduct = ProductEntity(
        id: 1,
        name: 'Doliprane 1000mg',
        price: 2500.0,
        stockQuantity: 50,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      testCartItem = CartItemEntity(
        product: testProduct,
        quantity: 2,
      );
    });

    group('CartState.initial', () {
      test('should create initial state with default values', () {
        // Act
        const state = CartState.initial();

        // Assert
        expect(state.status, CartStatus.initial);
        expect(state.items, isEmpty);
        expect(state.errorMessage, isNull);
        expect(state.selectedPharmacyId, isNull);
        expect(state.calculatedDeliveryFee, isNull);
        expect(state.deliveryDistanceKm, isNull);
        expect(state.pricingConfig, isNull);
        expect(state.paymentMode, 'cash');
      });
    });

    group('copyWith', () {
      test('should copy with new status', () {
        // Arrange
        const initialState = CartState.initial();

        // Act
        final newState = initialState.copyWith(status: CartStatus.loading);

        // Assert
        expect(newState.status, CartStatus.loading);
      });

      test('should copy with new items', () {
        // Arrange
        const initialState = CartState.initial();

        // Act
        final newState = initialState.copyWith(items: [testCartItem]);

        // Assert
        expect(newState.items.length, 1);
        expect(newState.items.first, testCartItem);
      });

      test('should copy with selected pharmacy id', () {
        // Arrange
        const initialState = CartState.initial();

        // Act
        final newState = initialState.copyWith(selectedPharmacyId: 5);

        // Assert
        expect(newState.selectedPharmacyId, 5);
      });

      test('should clear pharmacy id when flag is set', () {
        // Arrange
        final stateWithPharmacy = const CartState.initial().copyWith(
          selectedPharmacyId: 5,
        );

        // Act
        final newState = stateWithPharmacy.copyWith(clearPharmacyId: true);

        // Assert
        expect(newState.selectedPharmacyId, isNull);
      });

      test('should copy with calculated delivery fee', () {
        // Arrange
        const initialState = CartState.initial();

        // Act
        final newState = initialState.copyWith(calculatedDeliveryFee: 1000.0);

        // Assert
        expect(newState.calculatedDeliveryFee, 1000.0);
      });

      test('should clear delivery fee when flag is set', () {
        // Arrange
        final stateWithFee = const CartState.initial().copyWith(
          calculatedDeliveryFee: 1000.0,
          deliveryDistanceKm: 5.5,
        );

        // Act
        final newState = stateWithFee.copyWith(clearDeliveryFee: true);

        // Assert
        expect(newState.calculatedDeliveryFee, isNull);
        expect(newState.deliveryDistanceKm, isNull);
      });

      test('should copy with payment mode', () {
        // Arrange
        const initialState = CartState.initial();

        // Act
        final newState = initialState.copyWith(paymentMode: 'platform');

        // Assert
        expect(newState.paymentMode, 'platform');
      });
    });

    group('isEmpty / isNotEmpty', () {
      test('should return true for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.isEmpty, isTrue);
        expect(state.isNotEmpty, isFalse);
      });

      test('should return false for non-empty cart', () {
        // Arrange
        final state = const CartState.initial().copyWith(
          items: [testCartItem],
        );

        // Assert
        expect(state.isEmpty, isFalse);
        expect(state.isNotEmpty, isTrue);
      });
    });

    group('itemCount / totalQuantity', () {
      test('should return 0 for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.itemCount, 0);
        expect(state.totalQuantity, 0);
      });

      test('should sum quantities of all items', () {
        // Arrange
        final item1 = CartItemEntity(product: testProduct, quantity: 2);
        final item2 = CartItemEntity(
          product: ProductEntity(
            id: 2,
            name: 'Other Product',
            price: 1000.0,
            stockQuantity: 10,
            requiresPrescription: false,
            pharmacy: testPharmacy,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          quantity: 3,
        );
        final state = const CartState.initial().copyWith(items: [item1, item2]);

        // Assert
        expect(state.itemCount, 5); // 2 + 3
        expect(state.totalQuantity, 5);
      });
    });

    group('uniqueProductCount', () {
      test('should return number of different products', () {
        // Arrange
        final item1 = CartItemEntity(product: testProduct, quantity: 5);
        final item2 = CartItemEntity(
          product: ProductEntity(
            id: 2,
            name: 'Other Product',
            price: 1000.0,
            stockQuantity: 10,
            requiresPrescription: false,
            pharmacy: testPharmacy,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          quantity: 1,
        );
        final state = const CartState.initial().copyWith(items: [item1, item2]);

        // Assert
        expect(state.uniqueProductCount, 2);
      });
    });

    group('subtotal', () {
      test('should return 0 for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.subtotal, 0.0);
      });

      test('should calculate subtotal correctly', () {
        // Arrange - testCartItem: 2500 * 2 = 5000
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.subtotal, 5000.0);
      });

      test('should sum multiple items', () {
        // Arrange
        final item1 = CartItemEntity(product: testProduct, quantity: 2); // 2500 * 2 = 5000
        final item2 = CartItemEntity(
          product: ProductEntity(
            id: 2,
            name: 'Other',
            price: 1000.0,
            stockQuantity: 10,
            requiresPrescription: false,
            pharmacy: testPharmacy,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          quantity: 3, // 1000 * 3 = 3000
        );
        final state = const CartState.initial().copyWith(items: [item1, item2]);

        // Assert
        expect(state.subtotal, 8000.0);
      });
    });

    group('deliveryFee', () {
      test('should return 0 for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.deliveryFee, 0.0);
      });

      test('should return default fee when not calculated', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.deliveryFee, CartState.defaultMinDeliveryFee);
        expect(state.deliveryFee, 300.0);
      });

      test('should return calculated fee when available', () {
        // Arrange
        final state = const CartState.initial().copyWith(
          items: [testCartItem],
          calculatedDeliveryFee: 1500.0,
        );

        // Assert
        expect(state.deliveryFee, 1500.0);
      });
    });

    group('hasCalculatedDeliveryFee', () {
      test('should return false when not calculated', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.hasCalculatedDeliveryFee, isFalse);
      });

      test('should return true when calculated', () {
        // Arrange
        final state = const CartState.initial().copyWith(
          calculatedDeliveryFee: 500.0,
        );

        // Assert
        expect(state.hasCalculatedDeliveryFee, isTrue);
      });
    });

    group('serviceFee', () {
      test('should return 0 for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.serviceFee, 0.0);
      });

      test('should return 0 when no pricing config', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.serviceFee, 0.0);
      });
    });

    group('paymentFee', () {
      test('should return 0 for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.paymentFee, 0.0);
      });

      test('should return 0 when no pricing config', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.paymentFee, 0.0);
      });
    });

    group('hasPricingConfig', () {
      test('should return false when no config', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.hasPricingConfig, isFalse);
      });
    });

    group('total', () {
      test('should be 0 for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.total, 0.0);
      });

      test('should calculate total with delivery fee', () {
        // Arrange
        final state = const CartState.initial().copyWith(
          items: [testCartItem], // 5000
          calculatedDeliveryFee: 500.0,
        );

        // Assert - 5000 + 500 + 0 (service) + 0 (payment)
        expect(state.total, 5500.0);
      });
    });

    group('hasPharmacyItems', () {
      test('should return true when cart has items from pharmacy', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.hasPharmacyItems(1), isTrue);
      });

      test('should return false when cart has no items from pharmacy', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.hasPharmacyItems(999), isFalse);
      });

      test('should return false for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.hasPharmacyItems(1), isFalse);
      });
    });

    group('getItem', () {
      test('should return item when found', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Act
        final item = state.getItem(1);

        // Assert
        expect(item, testCartItem);
      });

      test('should return null when not found', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Act
        final item = state.getItem(999);

        // Assert
        expect(item, isNull);
      });

      test('should return null for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Act
        final item = state.getItem(1);

        // Assert
        expect(item, isNull);
      });
    });

    group('hasPrescriptionRequiredItems', () {
      test('should return false for empty cart', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.hasPrescriptionRequiredItems, isFalse);
      });

      test('should return false when no prescription required', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.hasPrescriptionRequiredItems, isFalse);
      });

      test('should return true when prescription required', () {
        // Arrange
        final prescriptionProduct = ProductEntity(
          id: 2,
          name: 'Antibiotique',
          price: 5000.0,
          stockQuantity: 10,
          requiresPrescription: true,
          pharmacy: testPharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final prescriptionItem = CartItemEntity(
          product: prescriptionProduct,
          quantity: 1,
        );
        final state = const CartState.initial().copyWith(
          items: [testCartItem, prescriptionItem],
        );

        // Assert
        expect(state.hasPrescriptionRequiredItems, isTrue);
      });
    });

    group('prescriptionRequiredItems', () {
      test('should return empty list when none required', () {
        // Arrange
        final state = const CartState.initial().copyWith(items: [testCartItem]);

        // Assert
        expect(state.prescriptionRequiredItems, isEmpty);
      });

      test('should return only prescription items', () {
        // Arrange
        final prescriptionProduct = ProductEntity(
          id: 2,
          name: 'Antibiotique',
          price: 5000.0,
          stockQuantity: 10,
          requiresPrescription: true,
          pharmacy: testPharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final prescriptionItem = CartItemEntity(
          product: prescriptionProduct,
          quantity: 1,
        );
        final state = const CartState.initial().copyWith(
          items: [testCartItem, prescriptionItem],
        );

        // Assert
        expect(state.prescriptionRequiredItems.length, 1);
        expect(state.prescriptionRequiredItems.first, prescriptionItem);
      });
    });

    group('prescriptionRequiredProductNames', () {
      test('should return names of prescription products', () {
        // Arrange
        final prescriptionProduct = ProductEntity(
          id: 2,
          name: 'Antibiotique XYZ',
          price: 5000.0,
          stockQuantity: 10,
          requiresPrescription: true,
          pharmacy: testPharmacy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final prescriptionItem = CartItemEntity(
          product: prescriptionProduct,
          quantity: 1,
        );
        final state = const CartState.initial().copyWith(
          items: [prescriptionItem],
        );

        // Assert
        expect(state.prescriptionRequiredProductNames, ['Antibiotique XYZ']);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const state1 = CartState.initial();
        const state2 = CartState.initial();

        // Assert
        expect(state1, equals(state2));
      });

      test('should not be equal when status differs', () {
        // Arrange
        const state1 = CartState.initial();
        final state2 = const CartState.initial().copyWith(
          status: CartStatus.loading,
        );

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should have correct props count', () {
        // Arrange
        const state = CartState.initial();

        // Assert
        expect(state.props.length, 8);
      });
    });

    group('defaultMinDeliveryFee constant', () {
      test('should be 300.0', () {
        expect(CartState.defaultMinDeliveryFee, 300.0);
      });
    });
  });
}
