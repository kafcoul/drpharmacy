import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/products/domain/entities/category_entity.dart';

void main() {
  group('CategoryEntity', () {
    const tCategory = CategoryEntity(
      id: 1,
      name: 'Médicaments',
      description: 'Tous les médicaments disponibles',
    );

    group('Constructor', () {
      test('should create a valid CategoryEntity with all fields', () {
        expect(tCategory.id, 1);
        expect(tCategory.name, 'Médicaments');
        expect(tCategory.description, 'Tous les médicaments disponibles');
      });

      test('should create entity with null description', () {
        const category = CategoryEntity(
          id: 1,
          name: 'Test',
        );

        expect(category.id, 1);
        expect(category.name, 'Test');
        expect(category.description, isNull);
      });

      test('should create entity with required fields only', () {
        const category = CategoryEntity(
          id: 42,
          name: 'Cosmétiques',
        );

        expect(category.id, 42);
        expect(category.name, 'Cosmétiques');
        expect(category.description, isNull);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const category1 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Description',
        );

        const category2 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Description',
        );

        expect(category1, category2);
      });

      test('should return false when ids are different', () {
        const category1 = CategoryEntity(
          id: 1,
          name: 'Test',
        );

        const category2 = CategoryEntity(
          id: 2,
          name: 'Test',
        );

        expect(category1, isNot(category2));
      });

      test('should return false when names are different', () {
        const category1 = CategoryEntity(
          id: 1,
          name: 'Test1',
        );

        const category2 = CategoryEntity(
          id: 1,
          name: 'Test2',
        );

        expect(category1, isNot(category2));
      });

      test('should return false when descriptions are different', () {
        const category1 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Desc 1',
        );

        const category2 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Desc 2',
        );

        expect(category1, isNot(category2));
      });

      test('should return false when one has description and other does not', () {
        const category1 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Description',
        );

        const category2 = CategoryEntity(
          id: 1,
          name: 'Test',
        );

        expect(category1, isNot(category2));
      });

      test('should have same hashCode for equal entities', () {
        const category1 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Desc',
        );

        const category2 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Desc',
        );

        expect(category1.hashCode, category2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields', () {
        expect(tCategory.props, [1, 'Médicaments', 'Tous les médicaments disponibles']);
      });

      test('should include null description in props', () {
        const category = CategoryEntity(
          id: 1,
          name: 'Test',
        );

        expect(category.props, [1, 'Test', null]);
      });
    });

    group('Edge cases', () {
      test('should handle empty name', () {
        const category = CategoryEntity(
          id: 1,
          name: '',
        );

        expect(category.name, '');
      });

      test('should handle very long name', () {
        const longName = 'Very Long Category Name That Might Be Used In The Application For Some Reason';
        const category = CategoryEntity(
          id: 1,
          name: longName,
        );

        expect(category.name, longName);
        expect(category.name.length, greaterThan(50));
      });

      test('should handle very long description', () {
        const longDescription = 'This is a very long description that contains multiple sentences. '
            'It describes the category in great detail. '
            'This could be used for SEO or user information purposes.';
        const category = CategoryEntity(
          id: 1,
          name: 'Test',
          description: longDescription,
        );

        expect(category.description, longDescription);
        expect(category.description!.length, greaterThan(100));
      });

      test('should handle special characters in name', () {
        const category = CategoryEntity(
          id: 1,
          name: 'Médicaments & Soins',
        );

        expect(category.name, 'Médicaments & Soins');
      });

      test('should handle unicode characters', () {
        const category = CategoryEntity(
          id: 1,
          name: '药品类别',
          description: '所有药品',
        );

        expect(category.name, '药品类别');
        expect(category.description, '所有药品');
      });

      test('should handle zero id', () {
        const category = CategoryEntity(
          id: 0,
          name: 'Test',
        );

        expect(category.id, 0);
      });

      test('should handle negative id', () {
        const category = CategoryEntity(
          id: -1,
          name: 'Test',
        );

        expect(category.id, -1);
      });

      test('should handle large id', () {
        const category = CategoryEntity(
          id: 999999999,
          name: 'Test',
        );

        expect(category.id, 999999999);
      });
    });
  });
}
