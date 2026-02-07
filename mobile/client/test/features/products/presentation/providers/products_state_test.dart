import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/products/presentation/providers/products_state.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';

void main() {
  group('ProductsStatus', () {
    test('should have all expected values', () {
      expect(ProductsStatus.values, [
        ProductsStatus.initial,
        ProductsStatus.loading,
        ProductsStatus.loaded,
        ProductsStatus.error,
        ProductsStatus.loadingMore,
      ]);
    });

    test('should have correct number of values', () {
      expect(ProductsStatus.values.length, 5);
    });
  });

  group('ProductsState', () {
    final tPharmacy = const PharmacyEntity(
      id: 1,
      name: 'Pharmacie',
      address: '123 Rue',
      phone: '+241 01 23 45 67',
      status: 'active',
      isOpen: true,
    );

    final tProduct = ProductEntity(
      id: 1,
      name: 'Doliprane 1000mg',
      price: 1500.0,
      stockQuantity: 50,
      requiresPrescription: false,
      pharmacy: tPharmacy,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    final tProduct2 = ProductEntity(
      id: 2,
      name: 'Advil 400mg',
      price: 2000.0,
      stockQuantity: 30,
      requiresPrescription: false,
      pharmacy: tPharmacy,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    group('Constructor', () {
      test('should create valid ProductsState with all fields', () {
        final state = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct],
          selectedProduct: tProduct,
          errorMessage: null,
          currentPage: 2,
          hasMore: true,
        );

        expect(state.status, ProductsStatus.loaded);
        expect(state.products, [tProduct]);
        expect(state.selectedProduct, tProduct);
        expect(state.errorMessage, isNull);
        expect(state.currentPage, 2);
        expect(state.hasMore, true);
      });

      test('should have default values for optional fields', () {
        final state = ProductsState(
          status: ProductsStatus.initial,
          products: const [],
        );

        expect(state.selectedProduct, isNull);
        expect(state.errorMessage, isNull);
        expect(state.currentPage, 1);
        expect(state.hasMore, true);
      });
    });

    group('initial factory', () {
      test('should create state with initial values', () {
        const state = ProductsState.initial();

        expect(state.status, ProductsStatus.initial);
        expect(state.products, isEmpty);
        expect(state.selectedProduct, isNull);
        expect(state.errorMessage, isNull);
        expect(state.currentPage, 1);
        expect(state.hasMore, true);
      });
    });

    group('loading factory', () {
      test('should create state with loading status', () {
        const state = ProductsState.loading();

        expect(state.status, ProductsStatus.loading);
        expect(state.products, isEmpty);
        expect(state.selectedProduct, isNull);
        expect(state.errorMessage, isNull);
        expect(state.currentPage, 1);
        expect(state.hasMore, true);
      });
    });

    group('copyWith', () {
      test('should copy state with new status', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(status: ProductsStatus.loading);

        expect(copied.status, ProductsStatus.loading);
        expect(copied.products, original.products);
        expect(copied.currentPage, original.currentPage);
        expect(copied.hasMore, original.hasMore);
      });

      test('should copy state with new products', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(products: [tProduct]);

        expect(copied.status, original.status);
        expect(copied.products, [tProduct]);
        expect(copied.products.length, 1);
      });

      test('should copy state with new selectedProduct', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(selectedProduct: tProduct);

        expect(copied.selectedProduct, tProduct);
      });

      test('should copy state with new errorMessage', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(errorMessage: 'Error occurred');

        expect(copied.errorMessage, 'Error occurred');
      });

      test('should copy state with new currentPage', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(currentPage: 5);

        expect(copied.currentPage, 5);
      });

      test('should copy state with new hasMore', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(hasMore: false);

        expect(copied.hasMore, false);
      });

      test('should copy state with multiple new values', () {
        const original = ProductsState.initial();
        final copied = original.copyWith(
          status: ProductsStatus.loaded,
          products: [tProduct, tProduct2],
          currentPage: 2,
          hasMore: false,
        );

        expect(copied.status, ProductsStatus.loaded);
        expect(copied.products.length, 2);
        expect(copied.currentPage, 2);
        expect(copied.hasMore, false);
      });

      test('should keep original values when not specified', () {
        final original = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct],
          selectedProduct: tProduct,
          errorMessage: 'Old error',
          currentPage: 3,
          hasMore: false,
        );

        final copied = original.copyWith(status: ProductsStatus.loadingMore);

        expect(copied.status, ProductsStatus.loadingMore);
        expect(copied.products, original.products);
        expect(copied.selectedProduct, original.selectedProduct);
        expect(copied.errorMessage, original.errorMessage);
        expect(copied.currentPage, original.currentPage);
        expect(copied.hasMore, original.hasMore);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal states', () {
        const state1 = ProductsState.initial();
        const state2 = ProductsState.initial();

        expect(state1, state2);
      });

      test('should return false when statuses are different', () {
        const state1 = ProductsState.initial();
        const state2 = ProductsState.loading();

        expect(state1, isNot(state2));
      });

      test('should return false when products are different', () {
        final state1 = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct],
        );

        final state2 = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct2],
        );

        expect(state1, isNot(state2));
      });

      test('should return false when currentPage is different', () {
        final state1 = ProductsState(
          status: ProductsStatus.loaded,
          products: const [],
          currentPage: 1,
        );

        final state2 = ProductsState(
          status: ProductsStatus.loaded,
          products: const [],
          currentPage: 2,
        );

        expect(state1, isNot(state2));
      });

      test('should return false when hasMore is different', () {
        final state1 = ProductsState(
          status: ProductsStatus.loaded,
          products: const [],
          hasMore: true,
        );

        final state2 = ProductsState(
          status: ProductsStatus.loaded,
          products: const [],
          hasMore: false,
        );

        expect(state1, isNot(state2));
      });

      test('should have same hashCode for equal states', () {
        const state1 = ProductsState.initial();
        const state2 = ProductsState.initial();

        expect(state1.hashCode, state2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields', () {
        final state = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct],
          selectedProduct: tProduct,
          errorMessage: 'Error',
          currentPage: 2,
          hasMore: false,
        );

        expect(state.props, [
          ProductsStatus.loaded,
          [tProduct],
          tProduct,
          'Error',
          2,
          false,
        ]);
      });

      test('should include null values in props', () {
        const state = ProductsState.initial();

        expect(state.props.contains(null), true);
      });
    });

    group('Use cases', () {
      test('should represent initial state correctly', () {
        const state = ProductsState.initial();

        expect(state.status, ProductsStatus.initial);
        expect(state.products, isEmpty);
      });

      test('should represent loading state correctly', () {
        const state = ProductsState.loading();

        expect(state.status, ProductsStatus.loading);
      });

      test('should represent loaded state with products', () {
        final state = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct, tProduct2],
          currentPage: 1,
          hasMore: true,
        );

        expect(state.status, ProductsStatus.loaded);
        expect(state.products.length, 2);
        expect(state.hasMore, true);
      });

      test('should represent error state correctly', () {
        const state = ProductsState(
          status: ProductsStatus.error,
          products: [],
          errorMessage: 'Failed to load products',
        );

        expect(state.status, ProductsStatus.error);
        expect(state.errorMessage, 'Failed to load products');
      });

      test('should represent loading more state for pagination', () {
        final state = ProductsState(
          status: ProductsStatus.loadingMore,
          products: [tProduct],
          currentPage: 2,
          hasMore: true,
        );

        expect(state.status, ProductsStatus.loadingMore);
        expect(state.products, isNotEmpty);
        expect(state.currentPage, 2);
      });

      test('should represent last page state', () {
        final state = ProductsState(
          status: ProductsStatus.loaded,
          products: [tProduct, tProduct2],
          currentPage: 5,
          hasMore: false,
        );

        expect(state.status, ProductsStatus.loaded);
        expect(state.hasMore, false);
      });
    });
  });
}
