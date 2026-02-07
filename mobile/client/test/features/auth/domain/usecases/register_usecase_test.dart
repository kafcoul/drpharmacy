import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:drpharma_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:drpharma_client/features/auth/domain/entities/auth_response_entity.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';

@GenerateMocks([AuthRepository])
import 'register_usecase_test.mocks.dart';

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
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

    test('should register successfully with valid data', () async {
      // Arrange
      when(mockRepository.register(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24177123456',
        password: 'password123',
        address: '123 Rue Test',
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await useCase.call(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24177123456',
        password: 'password123',
        passwordConfirmation: 'password123',
        address: '123 Rue Test',
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (response) {
          expect(response.user.id, 1);
          expect(response.user.name, 'John Doe');
          expect(response.token, isNotEmpty);
        },
      );
    });

    test('should register without address', () async {
      // Arrange
      when(mockRepository.register(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24177123456',
        password: 'password123',
        address: null,
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      final result = await useCase.call(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24177123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.register(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24177123456',
        password: 'password123',
        address: null,
      )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24177123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when email already exists', () async {
      // Arrange
      when(mockRepository.register(
        name: 'John Doe',
        email: 'existing@example.com',
        phone: '+24177123456',
        password: 'password123',
        address: null,
      )).thenAnswer((_) async => const Left(ValidationFailure(
        message: 'Email already exists',
        errors: {'email': ['Email already exists']},
      )));

      // Act
      final result = await useCase.call(
        name: 'John Doe',
        email: 'existing@example.com',
        phone: '+24177123456',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(result.isLeft(), isTrue);
    });

    group('Validation - name', () {
      test('should return validation failure for empty name', () async {
        // Act
        final result = await useCase.call(
          name: '',
          email: 'john@example.com',
          phone: '+24177123456',
          password: 'password123',
          passwordConfirmation: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['name'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.register(
          name: anyNamed('name'),
          email: anyNamed('email'),
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          address: anyNamed('address'),
        ));
      });
    });

    group('Validation - email', () {
      test('should return validation failure for empty email', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: '',
          phone: '+24177123456',
          password: 'password123',
          passwordConfirmation: 'password123',
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

      test('should return validation failure for invalid email format', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'invalid-email',
          phone: '+24177123456',
          password: 'password123',
          passwordConfirmation: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should return validation failure for email without @', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'johndoe.com',
          phone: '+24177123456',
          password: 'password123',
          passwordConfirmation: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('Validation - phone', () {
      test('should return validation failure for empty phone', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '',
          password: 'password123',
          passwordConfirmation: 'password123',
        );

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

      test('should return validation failure for phone with less than 8 digits', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567',
          password: 'password123',
          passwordConfirmation: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should accept phone number with spaces', () async {
        // Arrange
        when(mockRepository.register(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+225 01 23 45 67 89',
          password: 'password123',
          address: null,
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+225 01 23 45 67 89',
          password: 'password123',
          passwordConfirmation: 'password123',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });
    });

    group('Validation - password', () {
      test('should return validation failure for empty password', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: '',
          passwordConfirmation: '',
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

      test('should return validation failure for password < 6 characters', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: '12345',
          passwordConfirmation: '12345',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should accept password with exactly 6 characters', () async {
        // Arrange
        when(mockRepository.register(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: '123456',
          address: null,
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: '123456',
          passwordConfirmation: '123456',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });
    });

    group('Validation - password confirmation', () {
      test('should return validation failure for mismatched passwords', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: 'password123',
          passwordConfirmation: 'differentpassword',
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

      test('should return validation failure for case-sensitive password mismatch', () async {
        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: 'Password123',
          passwordConfirmation: 'password123',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should accept matching passwords', () async {
        // Arrange
        when(mockRepository.register(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: 'Password123!@#',
          address: null,
        )).thenAnswer((_) async => Right(testAuthResponse));

        // Act
        final result = await useCase.call(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+24177123456',
          password: 'Password123!@#',
          passwordConfirmation: 'Password123!@#',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });
    });
  });
}
