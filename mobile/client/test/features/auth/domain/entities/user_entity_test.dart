import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    final testDate = DateTime(2024, 1, 1);
    final verificationDate = DateTime(2024, 1, 15);

    UserEntity createUser({
      int id = 1,
      String name = 'Jean Dupont',
      String email = 'jean.dupont@email.com',
      String phone = '+241 01 23 45 67',
      String? address = '123 Rue Test, Libreville',
      String? profilePicture = 'https://example.com/avatar.jpg',
      DateTime? emailVerifiedAt,
      DateTime? phoneVerifiedAt,
      DateTime? createdAt,
    }) {
      return UserEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        profilePicture: profilePicture,
        emailVerifiedAt: emailVerifiedAt,
        phoneVerifiedAt: phoneVerifiedAt,
        createdAt: createdAt ?? testDate,
      );
    }

    group('creation', () {
      test('should create with all required fields', () {
        final user = createUser();

        expect(user.id, equals(1));
        expect(user.name, equals('Jean Dupont'));
        expect(user.email, equals('jean.dupont@email.com'));
        expect(user.phone, equals('+241 01 23 45 67'));
        expect(user.address, equals('123 Rue Test, Libreville'));
        expect(user.profilePicture, equals('https://example.com/avatar.jpg'));
        expect(user.createdAt, equals(testDate));
      });

      test('should create with null optional fields', () {
        final user = UserEntity(
          id: 1,
          name: 'Test User',
          email: 'test@email.com',
          phone: '+241 99 88 77 66',
          address: null,
          profilePicture: null,
          emailVerifiedAt: null,
          phoneVerifiedAt: null,
          createdAt: testDate,
        );

        expect(user.address, isNull);
        expect(user.profilePicture, isNull);
        expect(user.emailVerifiedAt, isNull);
        expect(user.phoneVerifiedAt, isNull);
      });

      test('should create with verification dates', () {
        final user = createUser(
          emailVerifiedAt: verificationDate,
          phoneVerifiedAt: verificationDate,
        );

        expect(user.emailVerifiedAt, equals(verificationDate));
        expect(user.phoneVerifiedAt, equals(verificationDate));
      });
    });

    group('isEmailVerified getter', () {
      test('should return true when emailVerifiedAt is not null', () {
        final user = createUser(emailVerifiedAt: verificationDate);
        expect(user.isEmailVerified, isTrue);
      });

      test('should return false when emailVerifiedAt is null', () {
        final user = createUser(emailVerifiedAt: null);
        expect(user.isEmailVerified, isFalse);
      });
    });

    group('isPhoneVerified getter', () {
      test('should return true when phoneVerifiedAt is not null', () {
        final user = createUser(phoneVerifiedAt: verificationDate);
        expect(user.isPhoneVerified, isTrue);
      });

      test('should return false when phoneVerifiedAt is null', () {
        final user = createUser(phoneVerifiedAt: null);
        expect(user.isPhoneVerified, isFalse);
      });
    });

    group('verification combinations', () {
      test('both verified', () {
        final user = createUser(
          emailVerifiedAt: verificationDate,
          phoneVerifiedAt: verificationDate,
        );

        expect(user.isEmailVerified, isTrue);
        expect(user.isPhoneVerified, isTrue);
      });

      test('only email verified', () {
        final user = createUser(
          emailVerifiedAt: verificationDate,
          phoneVerifiedAt: null,
        );

        expect(user.isEmailVerified, isTrue);
        expect(user.isPhoneVerified, isFalse);
      });

      test('only phone verified', () {
        final user = createUser(
          emailVerifiedAt: null,
          phoneVerifiedAt: verificationDate,
        );

        expect(user.isEmailVerified, isFalse);
        expect(user.isPhoneVerified, isTrue);
      });

      test('neither verified', () {
        final user = createUser(
          emailVerifiedAt: null,
          phoneVerifiedAt: null,
        );

        expect(user.isEmailVerified, isFalse);
        expect(user.isPhoneVerified, isFalse);
      });
    });

    group('equality', () {
      test('two users with same props should be equal', () {
        final user1 = createUser();
        final user2 = createUser();
        expect(user1, equals(user2));
      });

      test('two users with different ids should not be equal', () {
        final user1 = createUser(id: 1);
        final user2 = createUser(id: 2);
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different names should not be equal', () {
        final user1 = createUser(name: 'Jean');
        final user2 = createUser(name: 'Pierre');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different emails should not be equal', () {
        final user1 = createUser(email: 'jean@email.com');
        final user2 = createUser(email: 'pierre@email.com');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different phones should not be equal', () {
        final user1 = createUser(phone: '+241 11 11 11 11');
        final user2 = createUser(phone: '+241 22 22 22 22');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different addresses should not be equal', () {
        final user1 = createUser(address: 'Address 1');
        final user2 = createUser(address: 'Address 2');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different verification dates should not be equal', () {
        final user1 = createUser(emailVerifiedAt: DateTime(2024, 1, 1));
        final user2 = createUser(emailVerifiedAt: DateTime(2024, 2, 2));
        expect(user1, isNot(equals(user2)));
      });
    });

    group('props', () {
      test('should include all properties in correct order', () {
        final user = createUser(
          emailVerifiedAt: verificationDate,
          phoneVerifiedAt: verificationDate,
        );

        expect(user.props.length, equals(9));
        expect(user.props[0], equals(1)); // id
        expect(user.props[1], equals('Jean Dupont')); // name
        expect(user.props[2], equals('jean.dupont@email.com')); // email
        expect(user.props[3], equals('+241 01 23 45 67')); // phone
        expect(user.props[4], equals('123 Rue Test, Libreville')); // address
        expect(user.props[5], equals('https://example.com/avatar.jpg')); // profilePicture
        expect(user.props[6], equals(verificationDate)); // emailVerifiedAt
        expect(user.props[7], equals(verificationDate)); // phoneVerifiedAt
        expect(user.props[8], equals(testDate)); // createdAt
      });
    });

    group('hashCode', () {
      test('same users should have same hashCode', () {
        final user1 = createUser();
        final user2 = createUser();
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('different users should have different hashCodes', () {
        final user1 = createUser(id: 1);
        final user2 = createUser(id: 2);
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });
    });

    group('edge cases', () {
      test('should handle empty name', () {
        final user = createUser(name: '');
        expect(user.name, isEmpty);
      });

      test('should handle long email', () {
        final user = createUser(email: 'very.long.email.address@subdomain.domain.extension');
        expect(user.email, equals('very.long.email.address@subdomain.domain.extension'));
      });

      test('should handle different phone formats', () {
        expect(createUser(phone: '+241 01 23 45 67').phone, equals('+241 01 23 45 67'));
        expect(createUser(phone: '00241012345678').phone, equals('00241012345678'));
        expect(createUser(phone: '012345678').phone, equals('012345678'));
      });
    });
  });
}
