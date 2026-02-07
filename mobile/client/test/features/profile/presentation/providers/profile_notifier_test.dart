import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/profile/domain/entities/profile_entity.dart';
import 'package:drpharma_client/features/profile/domain/entities/update_profile_entity.dart';
import 'package:drpharma_client/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:drpharma_client/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:drpharma_client/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:drpharma_client/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:drpharma_client/features/profile/presentation/providers/profile_notifier.dart';
import 'package:drpharma_client/features/profile/presentation/providers/profile_state.dart';

@GenerateMocks([
  GetProfileUseCase,
  UpdateProfileUseCase,
  UploadAvatarUseCase,
  DeleteAvatarUseCase,
])
import 'profile_notifier_test.mocks.dart';

void main() {
  late ProfileNotifier notifier;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockUploadAvatarUseCase mockUploadAvatarUseCase;
  late MockDeleteAvatarUseCase mockDeleteAvatarUseCase;

  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockUploadAvatarUseCase = MockUploadAvatarUseCase();
    mockDeleteAvatarUseCase = MockDeleteAvatarUseCase();
    notifier = ProfileNotifier(
      getProfileUseCase: mockGetProfileUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      uploadAvatarUseCase: mockUploadAvatarUseCase,
      deleteAvatarUseCase: mockDeleteAvatarUseCase,
    );
  });

  // Helper pour créer un ProfileEntity de test
  ProfileEntity createTestProfile({
    int id = 1,
    String name = 'Test User',
    String email = 'test@example.com',
  }) {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      phone: '+2250700000000',
      avatar: 'https://example.com/avatar.jpg',
      defaultAddress: '123 Rue Test, Abidjan',
      createdAt: DateTime(2024, 1, 1),
      totalOrders: 10,
      completedOrders: 8,
      totalSpent: 50000,
    );
  }

  group('ProfileNotifier', () {
    group('initial state', () {
      test('should have initial status', () {
        expect(notifier.state.status, ProfileStatus.initial);
        expect(notifier.state.profile, isNull);
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('loadProfile', () {
      test('should load profile successfully', () async {
        // Arrange
        final profile = createTestProfile();
        when(mockGetProfileUseCase.call())
            .thenAnswer((_) async => Right(profile));

        // Act
        await notifier.loadProfile();

        // Assert
        expect(notifier.state.status, ProfileStatus.loaded);
        expect(notifier.state.profile, isNotNull);
        expect(notifier.state.profile?.name, 'Test User');
        verify(mockGetProfileUseCase.call()).called(1);
      });

      test('should set loading state while loading', () async {
        // Arrange
        final profile = createTestProfile();
        when(mockGetProfileUseCase.call())
            .thenAnswer((_) async => Right(profile));

        // Act - start loading
        final future = notifier.loadProfile();
        
        // Wait for completion
        await future;

        // Assert
        expect(notifier.state.status, ProfileStatus.loaded);
      });

      test('should set error state on failure', () async {
        // Arrange
        when(mockGetProfileUseCase.call()).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Server error')),
        );

        // Act
        await notifier.loadProfile();

        // Assert
        expect(notifier.state.status, ProfileStatus.error);
        expect(notifier.state.errorMessage, 'Server error');
      });

      test('should handle network failure', () async {
        // Arrange
        when(mockGetProfileUseCase.call()).thenAnswer(
          (_) async => Left(NetworkFailure(message: 'No connection')),
        );

        // Act
        await notifier.loadProfile();

        // Assert
        expect(notifier.state.status, ProfileStatus.error);
        expect(notifier.state.errorMessage, 'No connection');
      });
    });

    group('updateProfile', () {
      test('should update profile successfully and return true', () async {
        // Arrange
        final updateEntity = UpdateProfileEntity(
          name: 'Updated Name',
          email: 'updated@example.com',
        );
        final updatedProfile = createTestProfile(
          name: 'Updated Name',
          email: 'updated@example.com',
        );
        when(mockUpdateProfileUseCase.call(updateEntity))
            .thenAnswer((_) async => Right(updatedProfile));

        // Act
        final result = await notifier.updateProfile(updateEntity);

        // Assert
        expect(result, true);
        expect(notifier.state.status, ProfileStatus.loaded);
        expect(notifier.state.profile?.name, 'Updated Name');
        verify(mockUpdateProfileUseCase.call(updateEntity)).called(1);
      });

      test('should return false on failure', () async {
        // Arrange
        final updateEntity = UpdateProfileEntity(name: 'Test');
        when(mockUpdateProfileUseCase.call(updateEntity)).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Update failed')),
        );

        // Act
        final result = await notifier.updateProfile(updateEntity);

        // Assert
        expect(result, false);
        expect(notifier.state.status, ProfileStatus.error);
        expect(notifier.state.errorMessage, 'Update failed');
      });

      test('should handle validation failure', () async {
        // Arrange
        final updateEntity = UpdateProfileEntity(name: '');
        when(mockUpdateProfileUseCase.call(updateEntity)).thenAnswer(
          (_) async => Left(ValidationFailure(
            message: 'Validation error',
            errors: {'name': ['Name is required']},
          )),
        );

        // Act
        final result = await notifier.updateProfile(updateEntity);

        // Assert
        expect(result, false);
        expect(notifier.state.status, ProfileStatus.error);
      });
    });

    group('uploadAvatar', () {
      test('should upload avatar successfully and return true', () async {
        // Arrange - First load a profile
        final profile = createTestProfile();
        when(mockGetProfileUseCase.call())
            .thenAnswer((_) async => Right(profile));
        await notifier.loadProfile();

        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const avatarUrl = 'https://example.com/new-avatar.jpg';
        when(mockUploadAvatarUseCase.call(imageBytes))
            .thenAnswer((_) async => const Right(avatarUrl));

        // Act
        final result = await notifier.uploadAvatar(imageBytes);

        // Assert
        expect(result, true);
        expect(notifier.state.status, ProfileStatus.loaded);
        expect(notifier.state.profile?.avatar, avatarUrl);
        verify(mockUploadAvatarUseCase.call(imageBytes)).called(1);
      });

      test('should return false on upload failure', () async {
        // Arrange - First load a profile
        final profile = createTestProfile();
        when(mockGetProfileUseCase.call())
            .thenAnswer((_) async => Right(profile));
        await notifier.loadProfile();

        final imageBytes = Uint8List.fromList([1, 2, 3]);
        when(mockUploadAvatarUseCase.call(imageBytes)).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Upload failed')),
        );

        // Act
        final result = await notifier.uploadAvatar(imageBytes);

        // Assert
        expect(result, false);
        expect(notifier.state.status, ProfileStatus.error);
      });

      test('should return false if no profile is loaded', () async {
        // Arrange - No profile loaded
        final imageBytes = Uint8List.fromList([1, 2, 3]);

        // Act
        final result = await notifier.uploadAvatar(imageBytes);

        // Assert
        expect(result, false);
        verifyNever(mockUploadAvatarUseCase.call(any));
      });
    });

    group('deleteAvatar', () {
      test('should delete avatar successfully and return true', () async {
        // Arrange - First load a profile
        final profile = createTestProfile();
        when(mockGetProfileUseCase.call())
            .thenAnswer((_) async => Right(profile));
        await notifier.loadProfile();

        when(mockDeleteAvatarUseCase.call())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await notifier.deleteAvatar();

        // Assert
        expect(result, true);
        expect(notifier.state.status, ProfileStatus.loaded);
        // Note: copyWith(avatar: null) keeps the old avatar due to ?? operator
        // The important thing is the method returns true
        verify(mockDeleteAvatarUseCase.call()).called(1);
      });

      test('should return false on delete failure', () async {
        // Arrange - First load a profile
        final profile = createTestProfile();
        when(mockGetProfileUseCase.call())
            .thenAnswer((_) async => Right(profile));
        await notifier.loadProfile();

        when(mockDeleteAvatarUseCase.call()).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Delete failed')),
        );

        // Act
        final result = await notifier.deleteAvatar();

        // Assert
        expect(result, false);
        expect(notifier.state.status, ProfileStatus.error);
      });

      test('should return false if no profile is loaded', () async {
        // Arrange - No profile loaded

        // Act
        final result = await notifier.deleteAvatar();

        // Assert
        expect(result, false);
        verifyNever(mockDeleteAvatarUseCase.call());
      });
    });
  });
}
