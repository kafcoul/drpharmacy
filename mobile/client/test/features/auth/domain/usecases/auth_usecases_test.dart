import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/auth/domain/entities/auth_response_entity.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';
import 'package:drpharma_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:drpharma_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/get_current_user_usecase.dart';

import 'auth_usecases_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    registerUseCase = RegisterUseCase(mockRepository);
    logoutUseCase = LogoutUseCase(mockRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(mockRepository);
  });

  // Test data
  final testUser = UserEntity(
    id: 1,
    name: 'Jean Test',
    email: 'jean.test@example.com',
    phone: '+24107123456',
    address: 'Libreville, Gabon',
    createdAt: DateTime.now(),
  );

  final testAuthResponse = AuthResponseEntity(
    user: testUser,
    token: 'test_jwt_token_123',
  );

  group('LoginUseCase', () {
    test('should return auth response on successful login', () async {
      // Arrange
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await loginUseCase(
        email: 'jean.test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned auth response'),
        (response) {
          expect(response.user.name, 'Jean Test');
          expect(response.token, 'test_jwt_token_123');
        },
      );
    });

    test('should return ValidationFailure when email is empty', () async {
      // Act
      final result = await loginUseCase(
        email: '',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('requis'));
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure when password is empty', () async {
      // Act
      final result = await loginUseCase(
        email: 'jean.test@example.com',
        password: '',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure for invalid email format', () async {
      // Act
      final result = await loginUseCase(
        email: 'invalid-email',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('email'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure when password is too short', () async {
      // Act
      final result = await loginUseCase(
        email: 'jean.test@example.com',
        password: '12345', // Less than 6 characters
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('password'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should accept phone number as identifier', () async {
      // Arrange
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await loginUseCase(
        email: '+24107123456',
        password: 'password123',
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('should return failure on invalid credentials', () async {
      // Arrange
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(
        UnauthorizedFailure(message: 'Invalid credentials'),
      ));

      // Act
      final result = await loginUseCase(
        email: 'jean.test@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return failure on network error', () async {
      // Arrange
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(
        NetworkFailure(message: 'No internet connection'),
      ));

      // Act
      final result = await loginUseCase(
        email: 'jean.test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });
  });

  group('RegisterUseCase', () {
    test('should return auth response on successful registration', () async {
      // Arrange
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        password: anyNamed('password'),
        address: anyNamed('address'),
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await registerUseCase(
        name: 'Jean Test',
        email: 'jean.test@example.com',
        phone: '+24107123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned auth response'),
        (response) => expect(response.user.name, 'Jean Test'),
      );
    });

    test('should return ValidationFailure when name is empty', () async {
      // Act
      final result = await registerUseCase(
        name: '',
        email: 'jean.test@example.com',
        phone: '+24107123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('name'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure for invalid email', () async {
      // Act
      final result = await registerUseCase(
        name: 'Jean Test',
        email: 'invalid-email',
        phone: '+24107123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('email'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure for invalid phone', () async {
      // Act
      final result = await registerUseCase(
        name: 'Jean Test',
        email: 'jean.test@example.com',
        phone: '123', // Too short
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('phone'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure when passwords do not match', () async {
      // Act
      final result = await registerUseCase(
        name: 'Jean Test',
        email: 'jean.test@example.com',
        phone: '+24107123456',
        password: 'password123',
        passwordConfirmation: 'different_password',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('correspondent'));
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure when password is too short', () async {
      // Act
      final result = await registerUseCase(
        name: 'Jean Test',
        email: 'jean.test@example.com',
        phone: '+24107123456',
        password: '12345',
        passwordConfirmation: '12345',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('password'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return failure when email already exists', () async {
      // Arrange
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        password: anyNamed('password'),
        address: anyNamed('address'),
      )).thenAnswer((_) async => const Left(
        ValidationFailure(
          message: 'Email already exists',
          errors: {'email': ['Email already exists']},
        ),
      ));

      // Act
      final result = await registerUseCase(
        name: 'Jean Test',
        email: 'jean.test@example.com',
        phone: '+24107123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('LogoutUseCase', () {
    test('should return success on logout', () async {
      // Arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await logoutUseCase();

      // Assert
      expect(result.isRight(), true);
    });

    test('should call repository logout method', () async {
      // Arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // Act
      await logoutUseCase();

      // Assert
      verify(mockRepository.logout()).called(1);
    });

    test('should return failure on repository error', () async {
      // Arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(
            ServerFailure(message: 'Logout failed'),
          ));

      // Act
      final result = await logoutUseCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('GetCurrentUserUseCase', () {
    test('should return current user on success', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await getCurrentUserUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned user'),
        (user) {
          expect(user.id, 1);
          expect(user.name, 'Jean Test');
          expect(user.email, 'jean.test@example.com');
        },
      );
    });

    test('should call repository method', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUser));

      // Act
      await getCurrentUserUseCase();

      // Assert
      verify(mockRepository.getCurrentUser()).called(1);
    });

    test('should return failure when not authenticated', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(
            UnauthorizedFailure(message: 'Not authenticated'),
          ));

      // Act
      final result = await getCurrentUserUseCase();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });
  });

  group('UserEntity', () {
    test('should return isEmailVerified correctly', () {
      // Arrange
      final verifiedUser = UserEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        phone: '+24107123456',
        emailVerifiedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final unverifiedUser = UserEntity(
        id: 2,
        name: 'Test',
        email: 'test@test.com',
        phone: '+24107123456',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(verifiedUser.isEmailVerified, true);
      expect(unverifiedUser.isEmailVerified, false);
    });

    test('should return isPhoneVerified correctly', () {
      // Arrange
      final verifiedUser = UserEntity(
        id: 1,
        name: 'Test',
        email: 'test@test.com',
        phone: '+24107123456',
        phoneVerifiedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final unverifiedUser = UserEntity(
        id: 2,
        name: 'Test',
        email: 'test@test.com',
        phone: '+24107123456',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(verifiedUser.isPhoneVerified, true);
      expect(unverifiedUser.isPhoneVerified, false);
    });
  });
}
