import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/auth/data/models/auth_response_model.dart';
import 'package:drpharma_client/features/auth/data/models/user_model.dart';
import 'package:drpharma_client/features/auth/domain/entities/auth_response_entity.dart';

void main() {
  group('AuthResponseModel', () {
    UserModel createUserModel({
      int id = 1,
      String name = 'Jean Dupont',
      String email = 'jean.dupont@email.com',
      String phone = '+241 01 23 45 67',
      String? address,
      String? avatar,
      String? emailVerifiedAt,
      String? phoneVerifiedAt,
      String? createdAt = '2024-01-01T00:00:00.000Z',
    }) {
      return UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        avatar: avatar,
        emailVerifiedAt: emailVerifiedAt,
        phoneVerifiedAt: phoneVerifiedAt,
        createdAt: createdAt,
      );
    }

    group('creation', () {
      test('should create with user and token', () {
        final user = createUserModel();
        const token = 'jwt_token_12345';

        final model = AuthResponseModel(user: user, token: token);

        expect(model.user, equals(user));
        expect(model.token, equals(token));
      });

      test('should store complex JWT token', () {
        final user = createUserModel();
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U';

        final model = AuthResponseModel(user: user, token: token);

        expect(model.token, equals(token));
      });
    });

    group('fromJson', () {
      test('should parse complete JSON', () {
        final json = {
          'user': {
            'id': 1,
            'name': 'Test User',
            'email': 'test@email.com',
            'phone': '+241 99 88 77 66',
            'created_at': '2024-01-01T00:00:00.000Z',
          },
          'token': 'test_token_12345',
        };

        final model = AuthResponseModel.fromJson(json);

        expect(model.user.id, equals(1));
        expect(model.user.name, equals('Test User'));
        expect(model.user.email, equals('test@email.com'));
        expect(model.token, equals('test_token_12345'));
      });

      test('should parse JSON with full user data', () {
        final json = {
          'user': {
            'id': 99,
            'name': 'Full User',
            'email': 'full@email.com',
            'phone': '+241 11 22 33 44',
            'address': '123 Rue Test',
            'avatar': 'https://example.com/avatar.jpg',
            'email_verified_at': '2024-01-15T10:00:00.000Z',
            'phone_verified_at': '2024-01-16T11:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
          },
          'token': 'full_token',
        };

        final model = AuthResponseModel.fromJson(json);

        expect(model.user.id, equals(99));
        expect(model.user.address, equals('123 Rue Test'));
        expect(model.user.avatar, equals('https://example.com/avatar.jpg'));
        expect(model.user.emailVerifiedAt, isNotNull);
        expect(model.user.phoneVerifiedAt, isNotNull);
      });
    });

    group('toJson', () {
      test('should serialize to JSON', () {
        final user = createUserModel(id: 1, name: 'Test', email: 'test@email.com');
        const token = 'token123';

        final model = AuthResponseModel(user: user, token: token);
        final json = model.toJson();

        // The generated code keeps user as UserModel, not Map
        expect(json['user'], isA<UserModel>());
        expect(json['token'], equals('token123'));
      });

      test('should include all user fields through user object', () {
        final user = UserModel(
          id: 50,
          name: 'Complete User',
          email: 'complete@email.com',
          phone: '+241 55 66 77 88',
          address: 'Complete Address',
          avatar: 'https://example.com/pic.jpg',
          emailVerifiedAt: '2024-01-10T00:00:00.000Z',
          phoneVerifiedAt: '2024-01-11T00:00:00.000Z',
          createdAt: '2024-01-01T00:00:00.000Z',
        );
        const token = 'complete_token';

        final model = AuthResponseModel(user: user, token: token);
        final json = model.toJson();

        final userFromJson = json['user'] as UserModel;
        expect(userFromJson.id, equals(50));
        expect(userFromJson.name, equals('Complete User'));
        expect(userFromJson.email, equals('complete@email.com'));
        expect(userFromJson.address, equals('Complete Address'));
      });
    });

    group('toEntity', () {
      test('should convert to AuthResponseEntity', () {
        final user = createUserModel(id: 1, name: 'Entity User');
        const token = 'entity_token';

        final model = AuthResponseModel(user: user, token: token);
        final entity = model.toEntity();

        expect(entity, isA<AuthResponseEntity>());
        expect(entity.user.id, equals(1));
        expect(entity.user.name, equals('Entity User'));
        expect(entity.token, equals('entity_token'));
      });

      test('should convert user with all fields', () {
        final user = UserModel(
          id: 100,
          name: 'Full Entity User',
          email: 'full.entity@email.com',
          phone: '+241 77 88 99 00',
          address: 'Entity Address',
          avatar: 'https://entity.com/avatar.jpg',
          emailVerifiedAt: '2024-02-01T00:00:00.000Z',
          phoneVerifiedAt: '2024-02-02T00:00:00.000Z',
          createdAt: '2024-01-01T00:00:00.000Z',
        );
        const token = 'full_entity_token';

        final model = AuthResponseModel(user: user, token: token);
        final entity = model.toEntity();

        expect(entity.user.id, equals(100));
        expect(entity.user.name, equals('Full Entity User'));
        expect(entity.user.address, equals('Entity Address'));
        expect(entity.user.profilePicture, equals('https://entity.com/avatar.jpg'));
        expect(entity.user.isEmailVerified, isTrue);
        expect(entity.user.isPhoneVerified, isTrue);
        expect(entity.token, equals('full_entity_token'));
      });
    });

    group('roundtrip', () {
      test('should preserve data through model operations', () {
        final user = createUserModel(id: 42, name: 'Roundtrip User');
        const token = 'roundtrip_token';

        final original = AuthResponseModel(user: user, token: token);
        
        // Test the model preserves data
        expect(original.user.id, equals(42));
        expect(original.user.name, equals('Roundtrip User'));
        expect(original.token, equals(token));
        
        // Test entity conversion preserves data
        final entity = original.toEntity();
        expect(entity.user.id, equals(42));
        expect(entity.user.name, equals('Roundtrip User'));
        expect(entity.token, equals(token));
      });
    });

    group('token types', () {
      test('should handle bearer token', () {
        final user = createUserModel();
        const token = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.signature';

        final model = AuthResponseModel(user: user, token: token);

        expect(model.token, startsWith('Bearer '));
      });

      test('should handle empty token', () {
        final user = createUserModel();
        const token = '';

        final model = AuthResponseModel(user: user, token: token);

        expect(model.token, isEmpty);
      });

      test('should handle long token', () {
        final user = createUserModel();
        final token = 'very_long_token_' * 50;

        final model = AuthResponseModel(user: user, token: token);

        expect(model.token, equals(token));
      });
    });

    group('user access', () {
      test('should access user verification status through entity', () {
        final verifiedUser = UserModel(
          id: 1,
          name: 'Verified',
          email: 'verified@email.com',
          phone: '+241 11 22 33 44',
          emailVerifiedAt: '2024-01-01T00:00:00.000Z',
          phoneVerifiedAt: '2024-01-02T00:00:00.000Z',
          createdAt: '2024-01-01T00:00:00.000Z',
        );
        const token = 'token';

        final model = AuthResponseModel(user: verifiedUser, token: token);
        final entity = model.toEntity();

        expect(entity.user.isEmailVerified, isTrue);
        expect(entity.user.isPhoneVerified, isTrue);
      });

      test('should handle unverified user', () {
        final unverifiedUser = UserModel(
          id: 2,
          name: 'Unverified',
          email: 'unverified@email.com',
          phone: '+241 22 33 44 55',
          emailVerifiedAt: null,
          phoneVerifiedAt: null,
          createdAt: '2024-01-01T00:00:00.000Z',
        );
        const token = 'token';

        final model = AuthResponseModel(user: unverifiedUser, token: token);
        final entity = model.toEntity();

        expect(entity.user.isEmailVerified, isFalse);
        expect(entity.user.isPhoneVerified, isFalse);
      });
    });
  });
}
