import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:drpharma_client/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:drpharma_client/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:drpharma_client/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:drpharma_client/features/profile/domain/repositories/profile_repository.dart';
import 'package:drpharma_client/features/profile/domain/entities/profile_entity.dart';
import 'package:drpharma_client/features/profile/domain/entities/update_profile_entity.dart';
import 'dart:typed_data';

@GenerateMocks([ProfileRepository])
import 'profile_usecases_test.mocks.dart';

void main() {
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  group('GetProfileUseCase', () {
    late GetProfileUseCase useCase;

    setUp(() {
      useCase = GetProfileUseCase(repository: mockRepository);
    });

    final testProfile = ProfileEntity(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+24177123456',
      avatar: 'https://example.com/avatar.jpg',
      defaultAddress: '123 Rue Test, Libreville',
      createdAt: DateTime(2024, 1, 15),
      totalOrders: 10,
      completedOrders: 8,
      totalSpent: 75000.0,
    );

    test('should get profile successfully', () async {
      // Arrange
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Right(testProfile));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (profile) {
          expect(profile.id, 1);
          expect(profile.name, 'John Doe');
          expect(profile.email, 'john@example.com');
          expect(profile.totalOrders, 10);
          expect(profile.totalSpent, 75000.0);
        },
      );
      verify(mockRepository.getProfile()).called(1);
    });

    test('should return profile with all fields', () async {
      // Arrange
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Right(testProfile));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (profile) {
          expect(profile.hasAvatar, isTrue);
          expect(profile.hasPhone, isTrue);
          expect(profile.hasDefaultAddress, isTrue);
          expect(profile.initials, 'JD');
        },
      );
    });

    test('should return failure when not authenticated', () async {
      // Arrange
      when(mockRepository.getProfile())
          .thenAnswer((_) async => const Left(UnauthorizedFailure()));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when server error', () async {
      // Arrange
      when(mockRepository.getProfile())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('UpdateProfileUseCase', () {
    late UpdateProfileUseCase useCase;

    setUp(() {
      useCase = UpdateProfileUseCase(repository: mockRepository);
    });

    final testProfile = ProfileEntity(
      id: 1,
      name: 'John Doe Updated',
      email: 'john.updated@example.com',
      phone: '+24177999888',
      createdAt: DateTime(2024, 1, 15),
    );

    test('should update profile name successfully', () async {
      // Arrange
      const updateEntity = UpdateProfileEntity(name: 'John Doe Updated');
      when(mockRepository.updateProfile(updateEntity))
          .thenAnswer((_) async => Right(testProfile));

      // Act
      final result = await useCase.call(updateEntity);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (profile) {
          expect(profile.name, 'John Doe Updated');
        },
      );
    });

    test('should update profile email successfully', () async {
      // Arrange
      const updateEntity = UpdateProfileEntity(email: 'john.new@example.com');
      when(mockRepository.updateProfile(updateEntity))
          .thenAnswer((_) async => Right(testProfile));

      // Act
      final result = await useCase.call(updateEntity);

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should update password successfully', () async {
      // Arrange
      const updateEntity = UpdateProfileEntity(
        currentPassword: 'oldPassword123',
        newPassword: 'newPassword456',
        newPasswordConfirmation: 'newPassword456',
      );
      when(mockRepository.updateProfile(updateEntity))
          .thenAnswer((_) async => Right(testProfile));

      // Act
      final result = await useCase.call(updateEntity);

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const updateEntity = UpdateProfileEntity(name: 'New Name');
      when(mockRepository.updateProfile(updateEntity))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(updateEntity);

      // Assert
      expect(result.isLeft(), isTrue);
    });

    group('Validation - name', () {
      test('should return validation failure for empty name', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(name: '');

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['name'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for whitespace-only name', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(name: '   ');

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('Validation - email', () {
      test('should return validation failure for invalid email', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(email: 'invalid-email');

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['email'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });
    });

    group('Validation - phone', () {
      test('should return validation failure for short phone', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(phone: '12345');

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['phone'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });
    });

    group('Validation - password', () {
      test('should return validation failure when current password missing', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(
          currentPassword: '',
          newPassword: 'newPassword123',
          newPasswordConfirmation: 'newPassword123',
        );

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['current_password'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure when new password too short', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(
          currentPassword: 'oldPassword',
          newPassword: '1234567', // 7 chars, need 8
          newPasswordConfirmation: '1234567',
        );

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['password'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure when passwords do not match', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(
          currentPassword: 'oldPassword',
          newPassword: 'newPassword123',
          newPasswordConfirmation: 'differentPassword',
        );

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['password_confirmation'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should accept password with exactly 8 characters', () async {
        // Arrange
        const updateEntity = UpdateProfileEntity(
          currentPassword: 'oldPassword',
          newPassword: '12345678',
          newPasswordConfirmation: '12345678',
        );
        when(mockRepository.updateProfile(updateEntity))
            .thenAnswer((_) async => Right(testProfile));

        // Act
        final result = await useCase.call(updateEntity);

        // Assert
        expect(result.isRight(), isTrue);
      });
    });
  });

  group('UploadAvatarUseCase', () {
    late UploadAvatarUseCase useCase;

    setUp(() {
      useCase = UploadAvatarUseCase(repository: mockRepository);
    });

    test('should upload avatar successfully', () async {
      // Arrange
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      when(mockRepository.uploadAvatar(imageBytes))
          .thenAnswer((_) async => const Right('https://example.com/new-avatar.jpg'));

      // Act
      final result = await useCase.call(imageBytes);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (url) => expect(url, isNotEmpty),
      );
      verify(mockRepository.uploadAvatar(imageBytes)).called(1);
    });

    test('should return failure when upload fails', () async {
      // Arrange
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      when(mockRepository.uploadAvatar(imageBytes))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Upload failed')));

      // Act
      final result = await useCase.call(imageBytes);

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  group('DeleteAvatarUseCase', () {
    late DeleteAvatarUseCase useCase;

    setUp(() {
      useCase = DeleteAvatarUseCase(repository: mockRepository);
    });

    test('should delete avatar successfully', () async {
      // Arrange
      when(mockRepository.deleteAvatar())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.deleteAvatar()).called(1);
    });

    test('should return failure when delete fails', () async {
      // Arrange
      when(mockRepository.deleteAvatar())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Delete failed')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  group('ProfileEntity helpers', () {
    test('initials should return first letter for single name', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(profile.initials, 'J');
    });

    test('initials should return two letters for full name', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(profile.initials, 'JD');
    });

    test('initials should return ? for empty name', () {
      final profile = ProfileEntity(
        id: 1,
        name: '',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(profile.initials, '?');
    });

    test('hasAvatar should return false when avatar is null', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        avatar: null,
      );
      expect(profile.hasAvatar, isFalse);
    });

    test('hasAvatar should return false when avatar is empty', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        avatar: '',
      );
      expect(profile.hasAvatar, isFalse);
    });

    test('hasAvatar should return true when avatar is set', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        avatar: 'https://example.com/avatar.jpg',
      );
      expect(profile.hasAvatar, isTrue);
    });

    test('hasPhone should return false when phone is null', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        phone: null,
      );
      expect(profile.hasPhone, isFalse);
    });

    test('hasPhone should return true when phone is set', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        phone: '+24177123456',
      );
      expect(profile.hasPhone, isTrue);
    });

    test('hasDefaultAddress should return false when address is null', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        defaultAddress: null,
      );
      expect(profile.hasDefaultAddress, isFalse);
    });

    test('hasDefaultAddress should return true when address is set', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        defaultAddress: '123 Rue Test',
      );
      expect(profile.hasDefaultAddress, isTrue);
    });

    test('copyWith should update specified fields', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        totalOrders: 5,
      );

      final updated = profile.copyWith(
        name: 'Jane',
        totalOrders: 10,
      );

      expect(updated.name, 'Jane');
      expect(updated.totalOrders, 10);
      expect(updated.email, 'john@example.com'); // unchanged
      expect(updated.id, 1); // unchanged
    });
  });

  group('UpdateProfileEntity helpers', () {
    test('hasPasswordChange should return true when both passwords are set', () {
      const entity = UpdateProfileEntity(
        currentPassword: 'old',
        newPassword: 'new',
      );
      expect(entity.hasPasswordChange, isTrue);
    });

    test('hasPasswordChange should return false when currentPassword is null', () {
      const entity = UpdateProfileEntity(
        newPassword: 'new',
      );
      expect(entity.hasPasswordChange, isFalse);
    });

    test('hasPasswordChange should return false when newPassword is null', () {
      const entity = UpdateProfileEntity(
        currentPassword: 'old',
      );
      expect(entity.hasPasswordChange, isFalse);
    });

    test('hasPasswordChange should return false when both are null', () {
      const entity = UpdateProfileEntity(
        name: 'John',
      );
      expect(entity.hasPasswordChange, isFalse);
    });
  });
}
