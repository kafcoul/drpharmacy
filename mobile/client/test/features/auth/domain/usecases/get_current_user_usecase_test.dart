import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';
import 'package:drpharma_client/core/errors/failures.dart';

// Re-use existing mock
import 'login_usecase_test.mocks.dart';

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  UserEntity createTestUser({
    int id = 1,
    String name = 'John Doe',
    String email = 'john@example.com',
    String phone = '0123456789',
    String? address,
    String? profilePicture,
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
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  group('GetCurrentUserUseCase', () {
    group('successful retrieval', () {
      test('should call repository getCurrentUser method', () async {
        // Arrange
        final testUser = createTestUser();
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));

        // Act
        await useCase();

        // Assert
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return UserEntity when user is authenticated', () async {
        // Arrange
        final testUser = createTestUser();
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(testUser));
      });

      test('should return user with all fields populated', () async {
        // Arrange
        final testUser = createTestUser(
          id: 42,
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '0987654321',
          address: '123 Main St',
          profilePicture: 'https://example.com/avatar.jpg',
          emailVerifiedAt: DateTime(2024, 1, 1),
          phoneVerifiedAt: DateTime(2024, 1, 2),
          createdAt: DateTime(2023, 12, 1),
        );
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await useCase();

        // Assert
        result.fold(
          (failure) => fail('Expected user'),
          (user) {
            expect(user.id, 42);
            expect(user.name, 'Jane Smith');
            expect(user.email, 'jane@example.com');
            expect(user.phone, '0987654321');
            expect(user.address, '123 Main St');
            expect(user.profilePicture, 'https://example.com/avatar.jpg');
            expect(user.emailVerifiedAt, DateTime(2024, 1, 1));
            expect(user.phoneVerifiedAt, DateTime(2024, 1, 2));
            expect(user.createdAt, DateTime(2023, 12, 1));
          },
        );
      });

      test('should return user with optional fields null', () async {
        // Arrange
        final testUser = createTestUser();
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await useCase();

        // Assert
        result.fold(
          (failure) => fail('Expected user'),
          (user) {
            expect(user.address, isNull);
            expect(user.profilePicture, isNull);
            expect(user.emailVerifiedAt, isNull);
            expect(user.phoneVerifiedAt, isNull);
          },
        );
      });

      test('should return user with correct verification status', () async {
        // Arrange
        final verifiedUser = createTestUser(
          emailVerifiedAt: DateTime.now(),
          phoneVerifiedAt: DateTime.now(),
        );
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(verifiedUser));

        // Act
        final result = await useCase();

        // Assert
        result.fold(
          (failure) => fail('Expected user'),
          (user) {
            expect(user.isEmailVerified, true);
            expect(user.isPhoneVerified, true);
          },
        );
      });

      test('should return user with unverified status', () async {
        // Arrange
        final unverifiedUser = createTestUser();
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(unverifiedUser));

        // Act
        final result = await useCase();

        // Assert
        result.fold(
          (failure) => fail('Expected user'),
          (user) {
            expect(user.isEmailVerified, false);
            expect(user.isPhoneVerified, false);
          },
        );
      });
    });

    group('failure cases', () {
      test('should return UnauthorizedFailure when user is not authenticated', () async {
        // Arrange
        const failure = UnauthorizedFailure();
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });

      test('should return ServerFailure when server error occurs', () async {
        // Arrange
        const failure = ServerFailure(message: 'Server error');
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });

      test('should return NetworkFailure when no internet connection', () async {
        // Arrange
        const failure = NetworkFailure(message: 'No internet connection');
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });

      test('should return CacheFailure when cached user is corrupted', () async {
        // Arrange
        const failure = CacheFailure(message: 'Failed to retrieve cached user');
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });
    });

    group('repository interaction', () {
      test('should not call repository multiple times for single invocation', () async {
        // Arrange
        final testUser = createTestUser();
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));

        // Act
        await useCase();

        // Assert
        verify(mockRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should propagate exact failure from repository', () async {
        // Arrange
        const specificFailure = ServerFailure(
          message: 'User data not found',
          statusCode: 404,
        );
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(specificFailure));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'User data not found');
            expect((failure as ServerFailure).statusCode, 404);
          },
          (_) => fail('Expected failure'),
        );
      });
    });
  });
}
