import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('ProfileEntity', () {
    final testDate = DateTime(2024, 1, 1);
    final testDate2 = DateTime(2024, 6, 15);

    ProfileEntity createProfile({
      int id = 1,
      String name = 'Jean Dupont',
      String email = 'jean.dupont@email.com',
      String? phone = '+241 01 23 45 67',
      String? avatar = 'https://example.com/avatar.jpg',
      String? defaultAddress = '123 Rue Test, Libreville',
      DateTime? createdAt,
      int totalOrders = 10,
      int completedOrders = 8,
      double totalSpent = 150000.0,
    }) {
      return ProfileEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
        defaultAddress: defaultAddress,
        createdAt: createdAt ?? testDate,
        totalOrders: totalOrders,
        completedOrders: completedOrders,
        totalSpent: totalSpent,
      );
    }

    group('creation', () {
      test('should create with all required fields', () {
        final profile = createProfile();

        expect(profile.id, equals(1));
        expect(profile.name, equals('Jean Dupont'));
        expect(profile.email, equals('jean.dupont@email.com'));
        expect(profile.phone, equals('+241 01 23 45 67'));
        expect(profile.avatar, equals('https://example.com/avatar.jpg'));
        expect(profile.defaultAddress, equals('123 Rue Test, Libreville'));
        expect(profile.createdAt, equals(testDate));
        expect(profile.totalOrders, equals(10));
        expect(profile.completedOrders, equals(8));
        expect(profile.totalSpent, equals(150000.0));
      });

      test('should create with default values for stats', () {
        final profile = ProfileEntity(
          id: 1,
          name: 'Test User',
          email: 'test@email.com',
          createdAt: testDate,
        );

        expect(profile.totalOrders, equals(0));
        expect(profile.completedOrders, equals(0));
        expect(profile.totalSpent, equals(0.0));
      });

      test('should create with null optional fields', () {
        final profile = ProfileEntity(
          id: 1,
          name: 'Test User',
          email: 'test@email.com',
          phone: null,
          avatar: null,
          defaultAddress: null,
          createdAt: testDate,
        );

        expect(profile.phone, isNull);
        expect(profile.avatar, isNull);
        expect(profile.defaultAddress, isNull);
      });
    });

    group('hasAvatar', () {
      test('should return true when avatar is present', () {
        final profile = createProfile(avatar: 'https://example.com/avatar.jpg');
        expect(profile.hasAvatar, isTrue);
      });

      test('should return false when avatar is null', () {
        final profile = createProfile(avatar: null);
        expect(profile.hasAvatar, isFalse);
      });

      test('should return false when avatar is empty', () {
        final profile = createProfile(avatar: '');
        expect(profile.hasAvatar, isFalse);
      });
    });

    group('hasPhone', () {
      test('should return true when phone is present', () {
        final profile = createProfile(phone: '+241 01 23 45 67');
        expect(profile.hasPhone, isTrue);
      });

      test('should return false when phone is null', () {
        final profile = createProfile(phone: null);
        expect(profile.hasPhone, isFalse);
      });

      test('should return false when phone is empty', () {
        final profile = createProfile(phone: '');
        expect(profile.hasPhone, isFalse);
      });
    });

    group('hasDefaultAddress', () {
      test('should return true when defaultAddress is present', () {
        final profile = createProfile(defaultAddress: '123 Rue Test');
        expect(profile.hasDefaultAddress, isTrue);
      });

      test('should return false when defaultAddress is null', () {
        final profile = createProfile(defaultAddress: null);
        expect(profile.hasDefaultAddress, isFalse);
      });

      test('should return false when defaultAddress is empty', () {
        final profile = createProfile(defaultAddress: '');
        expect(profile.hasDefaultAddress, isFalse);
      });
    });

    group('initials', () {
      test('should return two letters for name with two words', () {
        final profile = createProfile(name: 'Jean Dupont');
        expect(profile.initials, equals('JD'));
      });

      test('should return two letters for name with multiple words', () {
        final profile = createProfile(name: 'Jean Pierre Dupont');
        expect(profile.initials, equals('JP'));
      });

      test('should return one letter for single name', () {
        final profile = createProfile(name: 'Jean');
        expect(profile.initials, equals('J'));
      });

      test('should handle lowercase names', () {
        final profile = createProfile(name: 'jean dupont');
        expect(profile.initials, equals('JD'));
      });

      test('should return ? for empty name', () {
        final profile = createProfile(name: '');
        expect(profile.initials, equals('?'));
      });
    });

    group('equality', () {
      test('two profiles with same props should be equal', () {
        final profile1 = createProfile();
        final profile2 = createProfile();
        expect(profile1, equals(profile2));
      });

      test('two profiles with different ids should not be equal', () {
        final profile1 = createProfile(id: 1);
        final profile2 = createProfile(id: 2);
        expect(profile1, isNot(equals(profile2)));
      });

      test('two profiles with different names should not be equal', () {
        final profile1 = createProfile(name: 'Jean Dupont');
        final profile2 = createProfile(name: 'Pierre Martin');
        expect(profile1, isNot(equals(profile2)));
      });

      test('two profiles with different emails should not be equal', () {
        final profile1 = createProfile(email: 'jean@email.com');
        final profile2 = createProfile(email: 'pierre@email.com');
        expect(profile1, isNot(equals(profile2)));
      });

      test('two profiles with different totalSpent should not be equal', () {
        final profile1 = createProfile(totalSpent: 100000.0);
        final profile2 = createProfile(totalSpent: 200000.0);
        expect(profile1, isNot(equals(profile2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final profile = createProfile();
        expect(profile.props.length, equals(10));
        expect(profile.props[0], equals(1)); // id
        expect(profile.props[1], equals('Jean Dupont')); // name
        expect(profile.props[2], equals('jean.dupont@email.com')); // email
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = createProfile();
        final copy = original.copyWith();
        expect(copy, equals(original));
      });

      test('should copy with new id', () {
        final original = createProfile(id: 1);
        final copy = original.copyWith(id: 99);
        expect(copy.id, equals(99));
        expect(copy.name, equals(original.name));
      });

      test('should copy with new name', () {
        final original = createProfile(name: 'Jean Dupont');
        final copy = original.copyWith(name: 'Pierre Martin');
        expect(copy.name, equals('Pierre Martin'));
        expect(copy.id, equals(original.id));
      });

      test('should copy with new email', () {
        final original = createProfile(email: 'jean@email.com');
        final copy = original.copyWith(email: 'pierre@email.com');
        expect(copy.email, equals('pierre@email.com'));
      });

      test('should copy with new phone', () {
        final original = createProfile(phone: '+241 01 23 45 67');
        final copy = original.copyWith(phone: '+241 99 88 77 66');
        expect(copy.phone, equals('+241 99 88 77 66'));
      });

      test('should copy with new avatar', () {
        final original = createProfile(avatar: 'old.jpg');
        final copy = original.copyWith(avatar: 'new.jpg');
        expect(copy.avatar, equals('new.jpg'));
      });

      test('should copy with new defaultAddress', () {
        final original = createProfile(defaultAddress: 'Old Address');
        final copy = original.copyWith(defaultAddress: 'New Address');
        expect(copy.defaultAddress, equals('New Address'));
      });

      test('should copy with new createdAt', () {
        final original = createProfile(createdAt: testDate);
        final copy = original.copyWith(createdAt: testDate2);
        expect(copy.createdAt, equals(testDate2));
      });

      test('should copy with new totalOrders', () {
        final original = createProfile(totalOrders: 10);
        final copy = original.copyWith(totalOrders: 20);
        expect(copy.totalOrders, equals(20));
      });

      test('should copy with new completedOrders', () {
        final original = createProfile(completedOrders: 8);
        final copy = original.copyWith(completedOrders: 15);
        expect(copy.completedOrders, equals(15));
      });

      test('should copy with new totalSpent', () {
        final original = createProfile(totalSpent: 150000.0);
        final copy = original.copyWith(totalSpent: 250000.0);
        expect(copy.totalSpent, equals(250000.0));
      });

      test('should copy with multiple changes', () {
        final original = createProfile();
        final copy = original.copyWith(
          name: 'New Name',
          email: 'new@email.com',
          totalOrders: 50,
          totalSpent: 500000.0,
        );
        expect(copy.name, equals('New Name'));
        expect(copy.email, equals('new@email.com'));
        expect(copy.totalOrders, equals(50));
        expect(copy.totalSpent, equals(500000.0));
        // Others unchanged
        expect(copy.id, equals(original.id));
        expect(copy.phone, equals(original.phone));
      });
    });

    group('hashCode', () {
      test('same profiles should have same hashCode', () {
        final profile1 = createProfile();
        final profile2 = createProfile();
        expect(profile1.hashCode, equals(profile2.hashCode));
      });

      test('different profiles should have different hashCodes', () {
        final profile1 = createProfile(id: 1);
        final profile2 = createProfile(id: 2);
        expect(profile1.hashCode, isNot(equals(profile2.hashCode)));
      });
    });
  });
}
