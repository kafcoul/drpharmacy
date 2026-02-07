import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/profile/data/models/update_profile_model.dart';
import 'package:drpharma_client/features/profile/domain/entities/update_profile_entity.dart';

void main() {
  group('UpdateProfileModel', () {
    group('Constructor', () {
      test('should create model with all fields', () {
        const model = UpdateProfileModel(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+241 01 23 45 67',
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
          newPasswordConfirmation: 'newPass456',
        );

        expect(model.name, 'John Doe');
        expect(model.email, 'john@example.com');
        expect(model.phone, '+241 01 23 45 67');
        expect(model.currentPassword, 'oldPass123');
        expect(model.newPassword, 'newPass456');
        expect(model.newPasswordConfirmation, 'newPass456');
      });

      test('should create model with only name', () {
        const model = UpdateProfileModel(
          name: 'John Doe',
        );

        expect(model.name, 'John Doe');
        expect(model.email, isNull);
        expect(model.phone, isNull);
        expect(model.currentPassword, isNull);
        expect(model.newPassword, isNull);
        expect(model.newPasswordConfirmation, isNull);
      });

      test('should create model with null values', () {
        const model = UpdateProfileModel();

        expect(model.name, isNull);
        expect(model.email, isNull);
        expect(model.phone, isNull);
        expect(model.currentPassword, isNull);
        expect(model.newPassword, isNull);
        expect(model.newPasswordConfirmation, isNull);
      });

      test('should create model with only password fields', () {
        const model = UpdateProfileModel(
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
          newPasswordConfirmation: 'newPass456',
        );

        expect(model.name, isNull);
        expect(model.email, isNull);
        expect(model.currentPassword, 'oldPass123');
        expect(model.newPassword, 'newPass456');
        expect(model.newPasswordConfirmation, 'newPass456');
      });
    });

    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        const entity = UpdateProfileEntity(
          name: 'Jane Doe',
          email: 'jane@example.com',
          phone: '+241 01 98 76 54',
          currentPassword: 'currentPass',
          newPassword: 'newPass',
          newPasswordConfirmation: 'newPass',
        );

        final model = UpdateProfileModel.fromEntity(entity);

        expect(model.name, 'Jane Doe');
        expect(model.email, 'jane@example.com');
        expect(model.phone, '+241 01 98 76 54');
        expect(model.currentPassword, 'currentPass');
        expect(model.newPassword, 'newPass');
        expect(model.newPasswordConfirmation, 'newPass');
      });

      test('should create model from entity with partial fields', () {
        const entity = UpdateProfileEntity(
          name: 'Jane Doe',
        );

        final model = UpdateProfileModel.fromEntity(entity);

        expect(model.name, 'Jane Doe');
        expect(model.email, isNull);
        expect(model.phone, isNull);
        expect(model.currentPassword, isNull);
        expect(model.newPassword, isNull);
        expect(model.newPasswordConfirmation, isNull);
      });

      test('should create model from entity with password only', () {
        const entity = UpdateProfileEntity(
          currentPassword: 'old',
          newPassword: 'new',
          newPasswordConfirmation: 'new',
        );

        final model = UpdateProfileModel.fromEntity(entity);

        expect(model.name, isNull);
        expect(model.currentPassword, 'old');
        expect(model.newPassword, 'new');
        expect(model.newPasswordConfirmation, 'new');
      });
    });

    group('toJson', () {
      test('should convert model with all fields to json', () {
        const model = UpdateProfileModel(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+241 01 23 45 67',
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
          newPasswordConfirmation: 'newPass456',
        );

        final json = model.toJson();

        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@example.com');
        expect(json['phone'], '+241 01 23 45 67');
        expect(json['current_password'], 'oldPass123');
        expect(json['password'], 'newPass456');
        expect(json['password_confirmation'], 'newPass456');
      });

      test('should only include non-null fields in json', () {
        const model = UpdateProfileModel(
          name: 'John Doe',
        );

        final json = model.toJson();

        expect(json, {'name': 'John Doe'});
        expect(json.containsKey('email'), false);
        expect(json.containsKey('phone'), false);
        expect(json.containsKey('current_password'), false);
        expect(json.containsKey('password'), false);
        expect(json.containsKey('password_confirmation'), false);
      });

      test('should return empty map when all fields are null', () {
        const model = UpdateProfileModel();

        final json = model.toJson();

        expect(json, isEmpty);
      });

      test('should include only email when only email is provided', () {
        const model = UpdateProfileModel(
          email: 'test@example.com',
        );

        final json = model.toJson();

        expect(json, {'email': 'test@example.com'});
      });

      test('should include only phone when only phone is provided', () {
        const model = UpdateProfileModel(
          phone: '+241 01 00 00 00',
        );

        final json = model.toJson();

        expect(json, {'phone': '+241 01 00 00 00'});
      });

      test('should include password fields with correct keys', () {
        const model = UpdateProfileModel(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
          newPasswordConfirmation: 'newPass',
        );

        final json = model.toJson();

        expect(json.containsKey('current_password'), true);
        expect(json.containsKey('password'), true);
        expect(json.containsKey('password_confirmation'), true);
        expect(json['current_password'], 'oldPass');
        expect(json['password'], 'newPass');
        expect(json['password_confirmation'], 'newPass');
      });

      test('should handle partial password update', () {
        const model = UpdateProfileModel(
          newPassword: 'newPass',
          newPasswordConfirmation: 'newPass',
        );

        final json = model.toJson();

        expect(json.containsKey('current_password'), false);
        expect(json['password'], 'newPass');
        expect(json['password_confirmation'], 'newPass');
      });
    });

    group('Edge cases', () {
      test('should handle empty strings', () {
        const model = UpdateProfileModel(
          name: '',
          email: '',
          phone: '',
        );

        final json = model.toJson();

        expect(json['name'], '');
        expect(json['email'], '');
        expect(json['phone'], '');
      });

      test('should handle very long name', () {
        final longName = 'A' * 255;
        final model = UpdateProfileModel(
          name: longName,
        );

        final json = model.toJson();

        expect(json['name'], longName);
        expect((json['name'] as String).length, 255);
      });

      test('should handle special characters in fields', () {
        const model = UpdateProfileModel(
          name: "Jean-Pierre O'Connor",
          email: 'jean.pierre+test@example.com',
        );

        final json = model.toJson();

        expect(json['name'], "Jean-Pierre O'Connor");
        expect(json['email'], 'jean.pierre+test@example.com');
      });

      test('should handle unicode characters', () {
        const model = UpdateProfileModel(
          name: '田中太郎',
        );

        final json = model.toJson();

        expect(json['name'], '田中太郎');
      });

      test('should handle password with special characters', () {
        const model = UpdateProfileModel(
          currentPassword: 'P@ssw0rd!#\$%',
          newPassword: 'N3wP@ss!@#',
          newPasswordConfirmation: 'N3wP@ss!@#',
        );

        final json = model.toJson();

        expect(json['current_password'], 'P@ssw0rd!#\$%');
        expect(json['password'], 'N3wP@ss!@#');
        expect(json['password_confirmation'], 'N3wP@ss!@#');
      });
    });
  });
}
