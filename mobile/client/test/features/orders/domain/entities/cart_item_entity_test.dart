import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/domain/entities/cart_item_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/category_entity.dart';

void main() {
  const testPharmacy = PharmacyEntity(
    id: 1,
    name: 'Test Pharmacy',
    address: '123 Test Street',
    phone: '+2251234567890',
    status: 'active',
    isOpen: true,
  );

  const testCategory = CategoryEntity(
    id: 1,
    name: 'Test Category',
    description: 'A test category',
  );

  ProductEntity createProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 1000.0,
    int stockQuantity = 100,
    bool requiresPrescription = false,
  }) {
    return ProductEntity(
      id: id,
      name: name,
      description: 'Test description',
      price: price,
      stockQuantity: stockQuantity,
      requiresPrescription: requiresPrescription,
      pharmacy: testPharmacy,
      category: testCategory,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  group('CartItemEntity', () {
    group('constructor', () {
      test('should create instance with required parameters', () {
        final product = createProduct();
        final cartItem = CartItemEntity(product: product, quantity: 2);

        expect(cartItem.product, product);
        expect(cartItem.quantity, 2);
      });
    });

    group('totalPrice', () {
      test('should calculate correct total price', () {
        final product = createProduct(price: 500.0);
        final cartItem = CartItemEntity(product: product, quantity: 3);

        expect(cartItem.totalPrice, 1500.0);
      });

      test('should return 0 when quantity is 0', () {
        final product = createProduct(price: 500.0);
        final cartItem = CartItemEntity(product: product, quantity: 0);

        expect(cartItem.totalPrice, 0.0);
      });

      test('should handle large quantities', () {
        final product = createProduct(price: 100.0);
        final cartItem = CartItemEntity(product: product, quantity: 1000);

        expect(cartItem.totalPrice, 100000.0);
      });
    });

    group('isAvailable', () {
      test('should return true when product is available and stock is sufficient', () {
        final product = createProduct(stockQuantity: 10);
        final cartItem = CartItemEntity(product: product, quantity: 5);

        expect(cartItem.isAvailable, isTrue);
      });

      test('should return false when stock is insufficient', () {
        final product = createProduct(stockQuantity: 3);
        final cartItem = CartItemEntity(product: product, quantity: 5);

        expect(cartItem.isAvailable, isFalse);
      });

      test('should return false when product is out of stock', () {
        final product = createProduct(stockQuantity: 0);
        final cartItem = CartItemEntity(product: product, quantity: 1);

        expect(cartItem.isAvailable, isFalse);
      });

      test('should return true when quantity equals stock', () {
        final product = createProduct(stockQuantity: 5);
        final cartItem = CartItemEntity(product: product, quantity: 5);

        expect(cartItem.isAvailable, isTrue);
      });
    });

    group('copyWith', () {
      test('should copy with new quantity', () {
        final product = createProduct();
        final cartItem = CartItemEntity(product: product, quantity: 2);
        final copied = cartItem.copyWith(quantity: 5);

        expect(copied.quantity, 5);
        expect(copied.product, product);
      });

      test('should copy with new product', () {
        final product1 = createProduct(id: 1, name: 'Product 1');
        final product2 = createProduct(id: 2, name: 'Product 2');
        final cartItem = CartItemEntity(product: product1, quantity: 2);
        final copied = cartItem.copyWith(product: product2);

        expect(copied.product.name, 'Product 2');
        expect(copied.quantity, 2);
      });

      test('should keep original values when no parameters', () {
        final product = createProduct();
        final cartItem = CartItemEntity(product: product, quantity: 2);
        final copied = cartItem.copyWith();

        expect(copied.product, product);
        expect(copied.quantity, 2);
      });
    });

    group('equality', () {
      test('should be equal when product id and quantity match', () {
        final product = createProduct(id: 1);
        final cartItem1 = CartItemEntity(product: product, quantity: 2);
        final cartItem2 = CartItemEntity(product: product, quantity: 2);

        expect(cartItem1, equals(cartItem2));
      });

      test('should not be equal when quantity differs', () {
        final product = createProduct(id: 1);
        final cartItem1 = CartItemEntity(product: product, quantity: 2);
        final cartItem2 = CartItemEntity(product: product, quantity: 3);

        expect(cartItem1, isNot(equals(cartItem2)));
      });

      test('should not be equal when product id differs', () {
        final product1 = createProduct(id: 1);
        final product2 = createProduct(id: 2);
        final cartItem1 = CartItemEntity(product: product1, quantity: 2);
        final cartItem2 = CartItemEntity(product: product2, quantity: 2);

        expect(cartItem1, isNot(equals(cartItem2)));
      });
    });

    group('props', () {
      test('should include product id and quantity', () {
        final product = createProduct(id: 5);
        final cartItem = CartItemEntity(product: product, quantity: 3);

        expect(cartItem.props, contains(5)); // product.id
        expect(cartItem.props, contains(3)); // quantity
      });
    });
  });

  group('ProductEntity', () {
    group('isAvailable', () {
      test('should return true when stockQuantity > 0', () {
        final product = createProduct(stockQuantity: 1);
        expect(product.isAvailable, isTrue);
      });

      test('should return false when stockQuantity is 0', () {
        final product = createProduct(stockQuantity: 0);
        expect(product.isAvailable, isFalse);
      });
    });

    group('isLowStock', () {
      test('should return true when stock is between 1 and 10', () {
        final product = createProduct(stockQuantity: 5);
        expect(product.isLowStock, isTrue);
      });

      test('should return false when stock is 0', () {
        final product = createProduct(stockQuantity: 0);
        expect(product.isLowStock, isFalse);
      });

      test('should return false when stock is more than 10', () {
        final product = createProduct(stockQuantity: 15);
        expect(product.isLowStock, isFalse);
      });

      test('should return true when stock is exactly 10', () {
        final product = createProduct(stockQuantity: 10);
        expect(product.isLowStock, isTrue);
      });

      test('should return true when stock is exactly 1', () {
        final product = createProduct(stockQuantity: 1);
        expect(product.isLowStock, isTrue);
      });
    });

    group('isOutOfStock', () {
      test('should return true when stockQuantity is 0', () {
        final product = createProduct(stockQuantity: 0);
        expect(product.isOutOfStock, isTrue);
      });

      test('should return false when stockQuantity > 0', () {
        final product = createProduct(stockQuantity: 1);
        expect(product.isOutOfStock, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final product1 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: testPharmacy,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        final product2 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 100.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: testPharmacy,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(product1, equals(product2));
      });

      test('should not be equal when id differs', () {
        final product1 = createProduct(id: 1);
        final product2 = createProduct(id: 2);

        expect(product1, isNot(equals(product2)));
      });
    });
  });

  group('PharmacyEntity', () {
    group('constructor', () {
      test('should create with required parameters', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test Pharmacy',
          address: '123 Main St',
          phone: '+225123456',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.id, 1);
        expect(pharmacy.name, 'Test Pharmacy');
        expect(pharmacy.address, '123 Main St');
        expect(pharmacy.phone, '+225123456');
        expect(pharmacy.status, 'active');
        expect(pharmacy.isOpen, true);
      });

      test('should create with optional parameters', () {
        const pharmacy = PharmacyEntity(
          id: 1,
          name: 'Test Pharmacy',
          address: '123 Main St',
          phone: '+225123456',
          email: 'test@pharmacy.com',
          latitude: 5.3364,
          longitude: -4.0266,
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy.email, 'test@pharmacy.com');
        expect(pharmacy.latitude, 5.3364);
        expect(pharmacy.longitude, -4.0266);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        const pharmacy1 = PharmacyEntity(
          id: 1,
          name: 'Pharmacy',
          address: 'Address',
          phone: '123',
          status: 'active',
          isOpen: true,
        );
        const pharmacy2 = PharmacyEntity(
          id: 1,
          name: 'Pharmacy',
          address: 'Address',
          phone: '123',
          status: 'active',
          isOpen: true,
        );

        expect(pharmacy1, equals(pharmacy2));
      });
    });
  });

  group('CategoryEntity', () {
    group('constructor', () {
      test('should create with required parameters', () {
        const category = CategoryEntity(id: 1, name: 'Medicines');

        expect(category.id, 1);
        expect(category.name, 'Medicines');
        expect(category.description, isNull);
      });

      test('should create with description', () {
        const category = CategoryEntity(
          id: 1,
          name: 'Medicines',
          description: 'All medicines',
        );

        expect(category.description, 'All medicines');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        const category1 = CategoryEntity(id: 1, name: 'Cat');
        const category2 = CategoryEntity(id: 1, name: 'Cat');

        expect(category1, equals(category2));
      });

      test('should not be equal when description differs', () {
        const category1 = CategoryEntity(id: 1, name: 'Cat', description: 'A');
        const category2 = CategoryEntity(id: 1, name: 'Cat', description: 'B');

        expect(category1, isNot(equals(category2)));
      });
    });
  });
}
