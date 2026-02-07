import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/category_entity.dart';

void main() {
  group('ProductEntity', () {
    final tPharmacy = const PharmacyEntity(
      id: 1,
      name: 'Pharmacie du Centre',
      address: '123 Rue Principale',
      phone: '+241 01 23 45 67',
      status: 'active',
      isOpen: true,
    );

    final tCategory = const CategoryEntity(
      id: 1,
      name: 'Médicaments',
      description: 'Catégorie médicaments',
    );

    final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
    final tUpdatedAt = DateTime(2024, 1, 15, 12, 0);

    final tProduct = ProductEntity(
      id: 1,
      name: 'Doliprane 1000mg',
      description: 'Paracétamol 1000mg',
      price: 1500.0,
      imageUrl: 'https://example.com/doliprane.jpg',
      stockQuantity: 50,
      manufacturer: 'Sanofi',
      requiresPrescription: false,
      pharmacy: tPharmacy,
      category: tCategory,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    group('Constructor', () {
      test('should create a valid ProductEntity with all required fields', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test Product',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.id, 1);
        expect(product.name, 'Test Product');
        expect(product.price, 1000.0);
        expect(product.stockQuantity, 10);
        expect(product.requiresPrescription, false);
        expect(product.pharmacy, tPharmacy);
      });

      test('should have null optional fields by default', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 500.0,
          stockQuantity: 5,
          requiresPrescription: true,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.description, isNull);
        expect(product.imageUrl, isNull);
        expect(product.manufacturer, isNull);
        expect(product.category, isNull);
      });

      test('should create entity with all fields', () {
        expect(tProduct.id, 1);
        expect(tProduct.name, 'Doliprane 1000mg');
        expect(tProduct.description, 'Paracétamol 1000mg');
        expect(tProduct.price, 1500.0);
        expect(tProduct.imageUrl, 'https://example.com/doliprane.jpg');
        expect(tProduct.stockQuantity, 50);
        expect(tProduct.manufacturer, 'Sanofi');
        expect(tProduct.requiresPrescription, false);
        expect(tProduct.pharmacy, tPharmacy);
        expect(tProduct.category, tCategory);
        expect(tProduct.createdAt, tCreatedAt);
        expect(tProduct.updatedAt, tUpdatedAt);
      });
    });

    group('isAvailable', () {
      test('should return true when stockQuantity > 0', () {
        expect(tProduct.isAvailable, true);
      });

      test('should return false when stockQuantity is 0', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isAvailable, false);
      });

      test('should return true when stockQuantity is 1', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 1,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isAvailable, true);
      });
    });

    group('isLowStock', () {
      test('should return true when stockQuantity is between 1 and 10', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 5,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isLowStock, true);
      });

      test('should return true when stockQuantity is exactly 10', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isLowStock, true);
      });

      test('should return true when stockQuantity is exactly 1', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 1,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isLowStock, true);
      });

      test('should return false when stockQuantity is 0', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isLowStock, false);
      });

      test('should return false when stockQuantity is greater than 10', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 11,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isLowStock, false);
      });

      test('should return false when stockQuantity is 50', () {
        expect(tProduct.isLowStock, false);
      });
    });

    group('isOutOfStock', () {
      test('should return true when stockQuantity is 0', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isOutOfStock, true);
      });

      test('should return false when stockQuantity > 0', () {
        expect(tProduct.isOutOfStock, false);
      });

      test('should return false when stockQuantity is 1', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 1,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isOutOfStock, false);
      });
    });

    group('Stock status combinations', () {
      test('should be available and not low stock when stock is high', () {
        expect(tProduct.stockQuantity, 50);
        expect(tProduct.isAvailable, true);
        expect(tProduct.isLowStock, false);
        expect(tProduct.isOutOfStock, false);
      });

      test('should be available and low stock when stock is between 1-10', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 5,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isAvailable, true);
        expect(product.isLowStock, true);
        expect(product.isOutOfStock, false);
      });

      test('should not be available and be out of stock when stock is 0', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 0,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.isAvailable, false);
        expect(product.isLowStock, false);
        expect(product.isOutOfStock, true);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        final product1 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final product2 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product1, product2);
      });

      test('should return false when ids are different', () {
        final product1 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final product2 = ProductEntity(
          id: 2,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product1, isNot(product2));
      });

      test('should return false when prices are different', () {
        final product1 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final product2 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1500.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product1, isNot(product2));
      });

      test('should return false when requiresPrescription is different', () {
        final product1 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final product2 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: true,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product1, isNot(product2));
      });

      test('should have same hashCode for equal entities', () {
        final product1 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        final product2 = ProductEntity(
          id: 1,
          name: 'Test',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product1.hashCode, product2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields', () {
        expect(tProduct.props.length, 12);
        expect(tProduct.props[0], 1); // id
        expect(tProduct.props[1], 'Doliprane 1000mg'); // name
        expect(tProduct.props[2], 'Paracétamol 1000mg'); // description
        expect(tProduct.props[3], 1500.0); // price
        expect(tProduct.props[4], 'https://example.com/doliprane.jpg'); // imageUrl
        expect(tProduct.props[5], 50); // stockQuantity
        expect(tProduct.props[6], 'Sanofi'); // manufacturer
        expect(tProduct.props[7], false); // requiresPrescription
        expect(tProduct.props[8], tPharmacy); // pharmacy
        expect(tProduct.props[9], tCategory); // category
        expect(tProduct.props[10], tCreatedAt); // createdAt
        expect(tProduct.props[11], tUpdatedAt); // updatedAt
      });
    });

    group('Edge cases', () {
      test('should handle zero price', () {
        final product = ProductEntity(
          id: 1,
          name: 'Free Sample',
          price: 0.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.price, 0.0);
      });

      test('should handle very high price', () {
        final product = ProductEntity(
          id: 1,
          name: 'Expensive Medicine',
          price: 999999.99,
          stockQuantity: 1,
          requiresPrescription: true,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.price, 999999.99);
      });

      test('should handle product requiring prescription', () {
        final product = ProductEntity(
          id: 1,
          name: 'Prescription Drug',
          price: 5000.0,
          stockQuantity: 20,
          requiresPrescription: true,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.requiresPrescription, true);
      });

      test('should handle very long product name', () {
        final product = ProductEntity(
          id: 1,
          name: 'Very Long Product Name With Many Words And Details About The Medication Including Dosage And Form',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.name.length, greaterThan(50));
      });

      test('should handle large stock quantity', () {
        final product = ProductEntity(
          id: 1,
          name: 'Popular Product',
          price: 500.0,
          stockQuantity: 10000,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.stockQuantity, 10000);
        expect(product.isAvailable, true);
        expect(product.isLowStock, false);
      });

      test('should handle product with empty description', () {
        final product = ProductEntity(
          id: 1,
          name: 'Test',
          description: '',
          price: 1000.0,
          stockQuantity: 10,
          requiresPrescription: false,
          pharmacy: tPharmacy,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        expect(product.description, '');
      });
    });
  });
}
