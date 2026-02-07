import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/profile/presentation/providers/profile_state.dart';
import 'package:drpharma_client/features/profile/domain/entities/profile_entity.dart';

void main() {
  group('ProfileState', () {
    final testDate = DateTime(2024, 1, 1);

    ProfileEntity createProfile({
      int id = 1,
      String name = 'Jean Dupont',
      String email = 'jean@email.com',
    }) {
      return ProfileEntity(
        id: id,
        name: name,
        email: email,
        phone: '+241 01 23 45 67',
        createdAt: testDate,
      );
    }

    group('creation', () {
      test('should create with default values', () {
        const state = ProfileState();

        expect(state.status, equals(ProfileStatus.initial));
        expect(state.profile, isNull);
        expect(state.errorMessage, isNull);
      });

      test('should create with initial status', () {
        const state = ProfileState(status: ProfileStatus.initial);
        expect(state.status, equals(ProfileStatus.initial));
      });

      test('should create with loading status', () {
        const state = ProfileState(status: ProfileStatus.loading);
        expect(state.status, equals(ProfileStatus.loading));
      });

      test('should create with loaded status and profile', () {
        final profile = createProfile();
        final state = ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
        );

        expect(state.status, equals(ProfileStatus.loaded));
        expect(state.profile, equals(profile));
      });

      test('should create with error status and message', () {
        const state = ProfileState(
          status: ProfileStatus.error,
          errorMessage: 'Something went wrong',
        );

        expect(state.status, equals(ProfileStatus.error));
        expect(state.errorMessage, equals('Something went wrong'));
      });
    });

    group('isLoading getter', () {
      test('should return true when status is loading', () {
        const state = ProfileState(status: ProfileStatus.loading);
        expect(state.isLoading, isTrue);
      });

      test('should return false when status is not loading', () {
        expect(const ProfileState(status: ProfileStatus.initial).isLoading, isFalse);
        expect(const ProfileState(status: ProfileStatus.loaded).isLoading, isFalse);
        expect(const ProfileState(status: ProfileStatus.error).isLoading, isFalse);
        expect(const ProfileState(status: ProfileStatus.updating).isLoading, isFalse);
      });
    });

    group('isLoaded getter', () {
      test('should return true when status is loaded', () {
        const state = ProfileState(status: ProfileStatus.loaded);
        expect(state.isLoaded, isTrue);
      });

      test('should return false when status is not loaded', () {
        expect(const ProfileState(status: ProfileStatus.initial).isLoaded, isFalse);
        expect(const ProfileState(status: ProfileStatus.loading).isLoaded, isFalse);
        expect(const ProfileState(status: ProfileStatus.error).isLoaded, isFalse);
      });
    });

    group('isUpdating getter', () {
      test('should return true when status is updating', () {
        const state = ProfileState(status: ProfileStatus.updating);
        expect(state.isUpdating, isTrue);
      });

      test('should return false when status is not updating', () {
        expect(const ProfileState(status: ProfileStatus.initial).isUpdating, isFalse);
        expect(const ProfileState(status: ProfileStatus.loaded).isUpdating, isFalse);
      });
    });

    group('isUploadingAvatar getter', () {
      test('should return true when status is uploadingAvatar', () {
        const state = ProfileState(status: ProfileStatus.uploadingAvatar);
        expect(state.isUploadingAvatar, isTrue);
      });

      test('should return false when status is not uploadingAvatar', () {
        expect(const ProfileState(status: ProfileStatus.initial).isUploadingAvatar, isFalse);
        expect(const ProfileState(status: ProfileStatus.loaded).isUploadingAvatar, isFalse);
      });
    });

    group('hasError getter', () {
      test('should return true when status is error', () {
        const state = ProfileState(status: ProfileStatus.error);
        expect(state.hasError, isTrue);
      });

      test('should return false when status is not error', () {
        expect(const ProfileState(status: ProfileStatus.initial).hasError, isFalse);
        expect(const ProfileState(status: ProfileStatus.loaded).hasError, isFalse);
      });
    });

    group('hasProfile getter', () {
      test('should return true when profile is not null', () {
        final state = ProfileState(profile: createProfile());
        expect(state.hasProfile, isTrue);
      });

      test('should return false when profile is null', () {
        const state = ProfileState();
        expect(state.hasProfile, isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final profile = createProfile();
        final original = ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
          errorMessage: null,
        );

        final copy = original.copyWith();

        expect(copy.status, equals(original.status));
        expect(copy.profile, equals(original.profile));
      });

      test('should copy with new status', () {
        final original = ProfileState(
          status: ProfileStatus.loaded,
          profile: createProfile(),
        );

        final copy = original.copyWith(status: ProfileStatus.updating);

        expect(copy.status, equals(ProfileStatus.updating));
        expect(copy.profile, equals(original.profile));
      });

      test('should copy with new profile', () {
        final original = ProfileState(
          status: ProfileStatus.loaded,
          profile: createProfile(id: 1, name: 'Old Name'),
        );

        final newProfile = createProfile(id: 2, name: 'New Name');
        final copy = original.copyWith(profile: newProfile);

        expect(copy.profile, equals(newProfile));
        expect(copy.status, equals(original.status));
      });

      test('should copy with new errorMessage', () {
        final original = ProfileState(status: ProfileStatus.loaded);

        final copy = original.copyWith(errorMessage: 'New error');

        expect(copy.errorMessage, equals('New error'));
      });

      test('should replace errorMessage with null', () {
        const original = ProfileState(
          status: ProfileStatus.error,
          errorMessage: 'Old error',
        );

        // Note: copyWith sets errorMessage directly, doesn't preserve
        final copy = original.copyWith(status: ProfileStatus.loaded);

        expect(copy.errorMessage, isNull);
      });
    });

    group('clearError', () {
      test('should clear error and set status to loaded', () {
        const state = ProfileState(
          status: ProfileStatus.error,
          errorMessage: 'Some error',
        );

        final cleared = state.clearError();

        expect(cleared.status, equals(ProfileStatus.loaded));
        expect(cleared.errorMessage, isNull);
      });

      test('should preserve profile when clearing error', () {
        final profile = createProfile();
        final state = ProfileState(
          status: ProfileStatus.error,
          profile: profile,
          errorMessage: 'Error',
        );

        final cleared = state.clearError();

        expect(cleared.profile, equals(profile));
      });
    });

    group('equality', () {
      test('two states with same props should be equal', () {
        final profile = createProfile();
        final state1 = ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
        );
        final state2 = ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
        );

        expect(state1, equals(state2));
      });

      test('two states with different statuses should not be equal', () {
        const state1 = ProfileState(status: ProfileStatus.loading);
        const state2 = ProfileState(status: ProfileStatus.loaded);

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different profiles should not be equal', () {
        final state1 = ProfileState(profile: createProfile(id: 1));
        final state2 = ProfileState(profile: createProfile(id: 2));

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different errors should not be equal', () {
        const state1 = ProfileState(errorMessage: 'Error 1');
        const state2 = ProfileState(errorMessage: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final profile = createProfile();
        final state = ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
          errorMessage: 'test',
        );

        expect(state.props.length, equals(3));
        expect(state.props[0], equals(ProfileStatus.loaded));
        expect(state.props[1], equals(profile));
        expect(state.props[2], equals('test'));
      });
    });
  });

  group('ProfileStatus', () {
    test('should have all expected values', () {
      expect(ProfileStatus.values, contains(ProfileStatus.initial));
      expect(ProfileStatus.values, contains(ProfileStatus.loading));
      expect(ProfileStatus.values, contains(ProfileStatus.loaded));
      expect(ProfileStatus.values, contains(ProfileStatus.updating));
      expect(ProfileStatus.values, contains(ProfileStatus.uploadingAvatar));
      expect(ProfileStatus.values, contains(ProfileStatus.error));
    });

    test('should have 6 values', () {
      expect(ProfileStatus.values.length, equals(6));
    });
  });
}
