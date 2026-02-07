import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/products/data/models/category_model.dart';
import 'package:drpharma_client/features/products/domain/entities/category_entity.dart';

void main() {
  group('CategoryModel', () {
    late Map<String, dynamic> validJson;

    setUp(() {
      validJson = {
        'id': 1,
        'name': 'Médicaments',
        'description': 'Tous les médicaments disponibles',
      };
    });

    group('fromJson', () {
      test('should create CategoryModel from valid JSON', () {
        // Act
        final result = CategoryModel.fromJson(validJson);

        // Assert
        expect(result.id, 1);
        expect(result.name, 'Médicaments');
        expect(result.description, 'Tous les médicaments disponibles');
      });

      test('should handle null description', () {
        // Arrange
        final json = Map<String, dynamic>.from(validJson);
        json['description'] = null;

        // Act
        final result = CategoryModel.fromJson(json);

        // Assert
        expect(result.description, isNull);
      });

      test('should handle missing description', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test',
        };

        // Act
        final result = CategoryModel.fromJson(json);

        // Assert
        expect(result.id, 1);
        expect(result.name, 'Test');
        expect(result.description, isNull);
      });
    });

    group('toJson', () {
      test('should convert CategoryModel to JSON', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Médicaments',
          description: 'Tous les médicaments',
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], 1);
        expect(result['name'], 'Médicaments');
        expect(result['description'], 'Tous les médicaments');
      });

      test('should include null description in JSON', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Test',
          description: null,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result.containsKey('description'), isTrue);
        expect(result['description'], isNull);
      });
    });

    group('toEntity', () {
      test('should convert CategoryModel to CategoryEntity', () {
        // Arrange
        final model = CategoryModel.fromJson(validJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<CategoryEntity>());
        expect(entity.id, 1);
        expect(entity.name, 'Médicaments');
        expect(entity.description, 'Tous les médicaments disponibles');
      });

      test('should preserve null description in entity', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Test',
          description: null,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.description, isNull);
      });
    });
  });

  group('CategoryEntity', () {
    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const entity1 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Description',
        );
        const entity2 = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Description',
        );

        // Assert
        expect(entity1, equals(entity2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const entity1 = CategoryEntity(id: 1, name: 'Test');
        const entity2 = CategoryEntity(id: 2, name: 'Test');

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when name differs', () {
        // Arrange
        const entity1 = CategoryEntity(id: 1, name: 'Test1');
        const entity2 = CategoryEntity(id: 1, name: 'Test2');

        // Assert
        expect(entity1, isNot(equals(entity2)));
      });

      test('should have props list with all properties', () {
        // Arrange
        const entity = CategoryEntity(
          id: 1,
          name: 'Test',
          description: 'Desc',
        );

        // Assert
        expect(entity.props.length, 3);
      });

      test('should handle null description in equality', () {
        // Arrange
        const entity1 = CategoryEntity(id: 1, name: 'Test', description: null);
        const entity2 = CategoryEntity(id: 1, name: 'Test', description: null);

        // Assert
        expect(entity1, equals(entity2));
      });
    });
  });
}
