import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:drpharma_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:drpharma_client/features/auth/domain/entities/auth_response_entity.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';

@GenerateMocks([AuthRepository])
import 'login_usecase_test.mocks.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    final testUser = UserEntity(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+24177123456',
      address: '123 Rue Test, Libreville',
      createdAt: DateTime(2024, 1, 15),
    );

    final testAuthResponse = AuthResponseEntity(
      user: testUser,
      token: 'test_jwt_token_123',
    );

    test('should login successfully with valid email and password', () async {
      // Arrange
      when(mockRepository.login(
        email: 'john@example.com',
        password: 'password123',
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await useCase.call(
        email: 'john@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (response) {
          expect(response.user.id, 1);
          expect(response.user.email, 'john@example.com');
          expect(response.token, isNotEmpty);
        },
      );
      verify(mockRepository.login(
        email: 'john@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should login successfully with valid phone number', () async {
      // Arrange
      when(mockRepository.login(
        email: '+24177123456',
        password: 'password123',
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await useCase.call(
        email: '+24177123456',
        password: 'password123',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should login successfully with phone number without + prefix', () async {
      // Arrange
      when(mockRepository.login(
        email: '24177123456',
        password: 'password123',
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await useCase.call(
        email: '24177123456',
        password: 'password123',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.login(
        email: 'john@example.com',
        password: 'password123',
      )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(
        email: 'john@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return auth failure for invalid credentials', () async {
      // Arrange
      when(mockRepository.login(
        email: 'john@example.com',
        password: 'wrongpassword',
      )).thenAnswer((_) async => const Left(UnauthorizedFailure(message: 'Invalid credentials')));

      // Act
      final result = await useCase.call(
        email: 'john@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    group('Validation - email/phone', () {
      test('should return validation failure for empty email', () async {
        // Act
        final result = await useCase.call(
          email: '',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['form'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should return validation failure for invalid email format', () async {
        // Act
        final result = await useCase.call(
          email: 'invalid-email',
          password: 'password123',
        );

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

      test('should return validation failure for email without domain', () async {
        // Act
        final result = await useCase.call(
          email: 'john@',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should return validation failure for email without @', () async {
        // Act
        final result = await useCase.call(
          email: 'johndoe.com',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should accept valid email formats', () async {
        // Arrange
        when(mockRepository.login(
          email: 'user.name+tag@example.co.uk',
          password: 'password123',
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          email: 'user.name+tag@example.co.uk',
          password: 'password123',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('should accept phone number starting with 0', () async {
        // Arrange
        when(mockRepository.login(
          email: '0511223344',
          password: 'password123',
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          email: '0511223344',
          password: 'password123',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('should reject phone number with less than 8 digits', () async {
        // Act
        final result = await useCase.call(
          email: '1234567',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('Validation - password', () {
      test('should return validation failure for empty password', () async {
        // Act
        final result = await useCase.call(
          email: 'john@example.com',
          password: '',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['form'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for password < 6 characters', () async {
        // Act
        final result = await useCase.call(
          email: 'john@example.com',
          password: '12345',
        );

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

      test('should accept password with exactly 6 characters', () async {
        // Arrange
        when(mockRepository.login(
          email: 'john@example.com',
          password: '123456',
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          email: 'john@example.com',
          password: '123456',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('should accept long password', () async {
        // Arrange
        final longPassword = 'a' * 100;
        when(mockRepository.login(
          email: 'john@example.com',
          password: longPassword,
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          email: 'john@example.com',
          password: longPassword,
        );

        // Assert
        expect(result.isRight(), isTrue);
      });
    });

    group('Multiple validations', () {
      test('should return validation failure for both empty email and password', () async {
        // Act
        final result = await useCase.call(
          email: '',
          password: '',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should be Left'),
        );
      });
    });
  });
}
