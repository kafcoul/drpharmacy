import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/profile/domain/entities/profile_entity.dart';
import 'package:drpharma_client/features/profile/domain/repositories/profile_repository.dart';
import 'package:drpharma_client/features/profile/domain/usecases/get_profile_usecase.dart';

@GenerateMocks([ProfileRepository])
import 'get_profile_usecase_test.mocks.dart';

void main() {
  late GetProfileUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileUseCase(repository: mockRepository);
  });

  final tProfile = ProfileEntity(
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    phone: '0612345678',
    avatar: 'https://example.com/avatar.jpg',
    defaultAddress: '123 Main Street',
    createdAt: DateTime(2024, 1, 1),
    totalOrders: 10,
    completedOrders: 8,
    totalSpent: 15000.0,
  );

  group('GetProfileUseCase', () {
    group('constructor', () {
      test('should create instance with repository', () {
        expect(useCase.repository, equals(mockRepository));
      });
    });

    group('call', () {
      test('should get profile from repository', () async {
        // Arrange
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Right(tProfile));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(tProfile));
        verify(mockRepository.getProfile()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return ServerFailure when server error', () async {
        // Arrange
        final failure = ServerFailure(message: 'Server error');
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
        verify(mockRepository.getProfile()).called(1);
      });

      test('should return NetworkFailure when no connection', () async {
        // Arrange
        final failure = NetworkFailure(message: 'No internet connection');
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
      });

      test('should return UnauthorizedFailure when not authenticated', () async {
        // Arrange
        final failure = UnauthorizedFailure(message: 'Not authenticated');
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
      });

      test('should return CacheFailure when cache error', () async {
        // Arrange
        final failure = CacheFailure(message: 'Cache error');
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
      });

      test('should return profile with minimal data', () async {
        // Arrange
        final minimalProfile = ProfileEntity(
          id: 2,
          name: 'Jane',
          email: 'jane@example.com',
          createdAt: DateTime(2024, 2, 1),
        );
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Right(minimalProfile));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(minimalProfile));
        expect(result.fold((l) => null, (r) => r.phone), isNull);
        expect(result.fold((l) => null, (r) => r.avatar), isNull);
        expect(result.fold((l) => null, (r) => r.defaultAddress), isNull);
      });

      test('should return profile with statistics', () async {
        // Arrange
        final profileWithStats = ProfileEntity(
          id: 3,
          name: 'User Stats',
          email: 'stats@example.com',
          createdAt: DateTime(2024, 3, 1),
          totalOrders: 50,
          completedOrders: 48,
          totalSpent: 250000.0,
        );
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Right(profileWithStats));

        // Act
        final result = await useCase();

        // Assert
        expect(result.fold((l) => 0, (r) => r.totalOrders), 50);
        expect(result.fold((l) => 0, (r) => r.completedOrders), 48);
        expect(result.fold((l) => 0.0, (r) => r.totalSpent), 250000.0);
      });

      test('should call repository only once per call', () async {
        // Arrange
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Right(tProfile));

        // Act
        await useCase();
        await useCase();

        // Assert
        verify(mockRepository.getProfile()).called(2);
      });

      test('should handle ServerFailure with details', () async {
        // Arrange
        final failure = ServerFailure(message: 'Unexpected error occurred');
        when(mockRepository.getProfile())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (r) => fail('Should return failure'),
        );
      });
    });
  });

  group('ProfileEntity - getters', () {
    test('hasAvatar returns true when avatar is present', () {
      expect(tProfile.hasAvatar, true);
    });

    test('hasAvatar returns false when avatar is null', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      );
      expect(profile.hasAvatar, false);
    });

    test('hasAvatar returns false when avatar is empty', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        avatar: '',
        createdAt: DateTime.now(),
      );
      expect(profile.hasAvatar, false);
    });

    test('hasPhone returns true when phone is present', () {
      expect(tProfile.hasPhone, true);
    });

    test('hasPhone returns false when phone is null', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      );
      expect(profile.hasPhone, false);
    });

    test('hasPhone returns false when phone is empty', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        phone: '',
        createdAt: DateTime.now(),
      );
      expect(profile.hasPhone, false);
    });

    test('hasDefaultAddress returns true when address is present', () {
      expect(tProfile.hasDefaultAddress, true);
    });

    test('initials returns two letters for full name', () {
      expect(tProfile.initials, 'JD');
    });

    test('initials returns one letter for single name', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'John',
        email: 'john@test.com',
        createdAt: DateTime.now(),
      );
      expect(profile.initials, 'J');
    });

    test('initials returns ? for empty name', () {
      final profile = ProfileEntity(
        id: 1,
        name: '',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      );
      expect(profile.initials, '?');
    });

    test('initials handles lowercase names', () {
      final profile = ProfileEntity(
        id: 1,
        name: 'jane doe',
        email: 'jane@test.com',
        createdAt: DateTime.now(),
      );
      expect(profile.initials, 'JD');
    });
  });

  group('ProfileEntity - copyWith', () {
    test('should copy with all new values', () {
      final newProfile = tProfile.copyWith(
        id: 99,
        name: 'New Name',
        email: 'new@email.com',
        phone: '0699999999',
        avatar: 'new-avatar.jpg',
        defaultAddress: 'New Address',
        totalOrders: 100,
        completedOrders: 99,
        totalSpent: 999999.0,
      );

      expect(newProfile.id, 99);
      expect(newProfile.name, 'New Name');
      expect(newProfile.email, 'new@email.com');
      expect(newProfile.phone, '0699999999');
      expect(newProfile.avatar, 'new-avatar.jpg');
      expect(newProfile.defaultAddress, 'New Address');
      expect(newProfile.totalOrders, 100);
      expect(newProfile.completedOrders, 99);
      expect(newProfile.totalSpent, 999999.0);
    });

    test('should preserve original values when no changes', () {
      final copiedProfile = tProfile.copyWith();

      expect(copiedProfile.id, tProfile.id);
      expect(copiedProfile.name, tProfile.name);
      expect(copiedProfile.email, tProfile.email);
      expect(copiedProfile.phone, tProfile.phone);
      expect(copiedProfile.avatar, tProfile.avatar);
      expect(copiedProfile.defaultAddress, tProfile.defaultAddress);
      expect(copiedProfile.totalOrders, tProfile.totalOrders);
      expect(copiedProfile.completedOrders, tProfile.completedOrders);
      expect(copiedProfile.totalSpent, tProfile.totalSpent);
    });

    test('should copy with partial changes', () {
      final partialCopy = tProfile.copyWith(name: 'New Name Only');

      expect(partialCopy.name, 'New Name Only');
      expect(partialCopy.email, tProfile.email);
      expect(partialCopy.id, tProfile.id);
    });
  });

  group('ProfileEntity - equality', () {
    test('should be equal for same values', () {
      final profile1 = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime(2024, 1, 1),
      );
      final profile2 = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(profile1, equals(profile2));
    });

    test('should not be equal for different ids', () {
      final profile1 = ProfileEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime(2024, 1, 1),
      );
      final profile2 = ProfileEntity(
        id: 2,
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(profile1, isNot(equals(profile2)));
    });

    test('should have same props list length', () {
      expect(tProfile.props.length, 10);
    });
  });
}
