import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/profile/domain/entities/update_profile_entity.dart';

void main() {
  group('UpdateProfileEntity', () {
    group('Constructor', () {
      test('should create entity with all fields', () {
        const entity = UpdateProfileEntity(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+241 01 23 45 67',
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
          newPasswordConfirmation: 'newPass456',
        );

        expect(entity.name, 'John Doe');
        expect(entity.email, 'john@example.com');
        expect(entity.phone, '+241 01 23 45 67');
        expect(entity.currentPassword, 'oldPass123');
        expect(entity.newPassword, 'newPass456');
        expect(entity.newPasswordConfirmation, 'newPass456');
      });

      test('should create entity with only name', () {
        const entity = UpdateProfileEntity(
          name: 'John Doe',
        );

        expect(entity.name, 'John Doe');
        expect(entity.email, isNull);
        expect(entity.phone, isNull);
        expect(entity.currentPassword, isNull);
        expect(entity.newPassword, isNull);
        expect(entity.newPasswordConfirmation, isNull);
      });

      test('should create entity with no fields', () {
        const entity = UpdateProfileEntity();

        expect(entity.name, isNull);
        expect(entity.email, isNull);
        expect(entity.phone, isNull);
        expect(entity.currentPassword, isNull);
        expect(entity.newPassword, isNull);
        expect(entity.newPasswordConfirmation, isNull);
      });

      test('should create entity with only email', () {
        const entity = UpdateProfileEntity(
          email: 'test@example.com',
        );

        expect(entity.name, isNull);
        expect(entity.email, 'test@example.com');
        expect(entity.phone, isNull);
      });

      test('should create entity with only phone', () {
        const entity = UpdateProfileEntity(
          phone: '+241 01 00 00 00',
        );

        expect(entity.name, isNull);
        expect(entity.email, isNull);
        expect(entity.phone, '+241 01 00 00 00');
      });

      test('should create entity with only password fields', () {
        const entity = UpdateProfileEntity(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
          newPasswordConfirmation: 'newPass',
        );

        expect(entity.name, isNull);
        expect(entity.email, isNull);
        expect(entity.currentPassword, 'oldPass');
        expect(entity.newPassword, 'newPass');
        expect(entity.newPasswordConfirmation, 'newPass');
      });
    });

    group('hasPasswordChange', () {
      test('should return true when currentPassword and newPassword are set', () {
        const entity = UpdateProfileEntity(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
        );

        expect(entity.hasPasswordChange, true);
      });

      test('should return false when only currentPassword is set', () {
        const entity = UpdateProfileEntity(
          currentPassword: 'oldPass',
        );

        expect(entity.hasPasswordChange, false);
      });

      test('should return false when only newPassword is set', () {
        const entity = UpdateProfileEntity(
          newPassword: 'newPass',
        );

        expect(entity.hasPasswordChange, false);
      });

      test('should return false when neither is set', () {
        const entity = UpdateProfileEntity(
          name: 'John Doe',
        );

        expect(entity.hasPasswordChange, false);
      });

      test('should return false for empty entity', () {
        const entity = UpdateProfileEntity();

        expect(entity.hasPasswordChange, false);
      });

      test('should return true with all password fields set', () {
        const entity = UpdateProfileEntity(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
          newPasswordConfirmation: 'newPass',
        );

        expect(entity.hasPasswordChange, true);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const entity1 = UpdateProfileEntity(
          name: 'John',
          email: 'john@example.com',
        );

        const entity2 = UpdateProfileEntity(
          name: 'John',
          email: 'john@example.com',
        );

        expect(entity1, entity2);
      });

      test('should return false when names are different', () {
        const entity1 = UpdateProfileEntity(
          name: 'John',
        );

        const entity2 = UpdateProfileEntity(
          name: 'Jane',
        );

        expect(entity1, isNot(entity2));
      });

      test('should return false when emails are different', () {
        const entity1 = UpdateProfileEntity(
          email: 'john@example.com',
        );

        const entity2 = UpdateProfileEntity(
          email: 'jane@example.com',
        );

        expect(entity1, isNot(entity2));
      });

      test('should return false when passwords are different', () {
        const entity1 = UpdateProfileEntity(
          currentPassword: 'pass1',
          newPassword: 'new1',
        );

        const entity2 = UpdateProfileEntity(
          currentPassword: 'pass2',
          newPassword: 'new2',
        );

        expect(entity1, isNot(entity2));
      });

      test('should have same hashCode for equal entities', () {
        const entity1 = UpdateProfileEntity(
          name: 'John',
        );

        const entity2 = UpdateProfileEntity(
          name: 'John',
        );

        expect(entity1.hashCode, entity2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields in correct order', () {
        const entity = UpdateProfileEntity(
          name: 'John',
          email: 'john@example.com',
          phone: '+241 01 23 45 67',
          currentPassword: 'oldPass',
          newPassword: 'newPass',
          newPasswordConfirmation: 'newPass',
        );

        expect(entity.props, [
          'John',
          'john@example.com',
          '+241 01 23 45 67',
          'oldPass',
          'newPass',
          'newPass',
        ]);
      });

      test('should include null values in props', () {
        const entity = UpdateProfileEntity(
          name: 'John',
        );

        expect(entity.props[0], 'John');
        expect(entity.props[1], isNull);
        expect(entity.props[2], isNull);
        expect(entity.props[3], isNull);
        expect(entity.props[4], isNull);
        expect(entity.props[5], isNull);
      });
    });

    group('Edge cases', () {
      test('should handle empty strings', () {
        const entity = UpdateProfileEntity(
          name: '',
          email: '',
          phone: '',
        );

        expect(entity.name, '');
        expect(entity.email, '');
        expect(entity.phone, '');
      });

      test('should handle very long values', () {
        final longName = 'A' * 255;
        final entity = UpdateProfileEntity(
          name: longName,
        );

        expect(entity.name, longName);
        expect(entity.name!.length, 255);
      });

      test('should handle special characters', () {
        const entity = UpdateProfileEntity(
          name: "Jean-Pierre O'Connor",
          email: 'jean.pierre+test@example.com',
        );

        expect(entity.name, "Jean-Pierre O'Connor");
        expect(entity.email, 'jean.pierre+test@example.com');
      });

      test('should handle unicode characters', () {
        const entity = UpdateProfileEntity(
          name: '田中太郎',
        );

        expect(entity.name, '田中太郎');
      });

      test('should handle password with special characters', () {
        const entity = UpdateProfileEntity(
          currentPassword: 'P@ssw0rd!#\$%',
          newPassword: 'N3wP@ss!@#',
        );

        expect(entity.currentPassword, 'P@ssw0rd!#\$%');
        expect(entity.newPassword, 'N3wP@ss!@#');
        expect(entity.hasPasswordChange, true);
      });

      test('should handle different null combinations', () {
        const entity1 = UpdateProfileEntity(name: 'John');
        const entity2 = UpdateProfileEntity(email: 'john@example.com');
        const entity3 = UpdateProfileEntity(phone: '+241');

        expect(entity1.hasPasswordChange, false);
        expect(entity2.hasPasswordChange, false);
        expect(entity3.hasPasswordChange, false);
      });
    });
  });
}
