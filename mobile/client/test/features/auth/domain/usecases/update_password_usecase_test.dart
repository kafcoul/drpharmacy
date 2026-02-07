import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:drpharma_client/core/errors/failures.dart';

// Re-use existing mock
import 'login_usecase_test.mocks.dart';

void main() {
  late UpdatePasswordUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = UpdatePasswordUseCase(mockRepository);
  });

  group('UpdatePasswordUseCase', () {
    const testCurrentPassword = 'oldPassword123';
    const testNewPassword = 'newPassword456';

    group('successful updates', () {
      test('should call repository with correct parameters', () async {
        // Arrange
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        verify(mockRepository.updatePassword(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        )).called(1);
      });

      test('should return Right(void) when password update succeeds', () async {
        // Arrange
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Right(null));
      });

      test('should return Right(void) when passwords are different but valid', () async {
        // Arrange
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentPassword: 'current123',
          newPassword: 'different456',
        );

        // Assert
        expect(result, const Right(null));
      });
    });

    group('failure cases', () {
      test('should return ServerFailure when server error occurs', () async {
        // Arrange
        const failure = ServerFailure(message: 'Server error');
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should return NetworkFailure when network error occurs', () async {
        // Arrange
        const failure = NetworkFailure(message: 'No internet connection');
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should return ServerFailure when current password is incorrect', () async {
        // Arrange
        const failure = ServerFailure(message: 'Current password is incorrect', statusCode: 401);
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: 'wrongPassword',
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should return ValidationFailure when new password is too weak', () async {
        // Arrange
        const failure = ValidationFailure(
          message: 'Password must be at least 8 characters',
          errors: {'password': ['Password must be at least 8 characters']},
        );
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: 'weak',
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should return UnauthorizedFailure when user is not authenticated', () async {
        // Arrange
        const failure = UnauthorizedFailure();
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should return ServerFailure when request times out', () async {
        // Arrange
        const failure = ServerFailure(message: 'Request timed out', statusCode: 408);
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Left(failure));
      });
    });

    group('edge cases', () {
      test('should handle empty current password', () async {
        // Arrange
        const failure = ValidationFailure(
          message: 'Current password cannot be empty',
          errors: {'currentPassword': ['Current password cannot be empty']},
        );
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: '',
          newPassword: testNewPassword,
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should handle empty new password', () async {
        // Arrange
        const failure = ValidationFailure(
          message: 'New password cannot be empty',
          errors: {'newPassword': ['New password cannot be empty']},
        );
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: '',
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should handle same old and new password', () async {
        // Arrange
        const samePassword = 'samePassword123';
        const failure = ValidationFailure(
          message: 'New password must be different from current',
          errors: {'newPassword': ['New password must be different from current']},
        );
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          currentPassword: samePassword,
          newPassword: samePassword,
        );

        // Assert
        expect(result, const Left(failure));
      });

      test('should handle password with special characters', () async {
        // Arrange
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentPassword: 'old@Pass#123!',
          newPassword: r'new$Secure*456&',
        );

        // Assert
        expect(result, const Right(null));
      });

      test('should handle very long passwords', () async {
        // Arrange
        final longPassword = 'A' * 100;
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: longPassword,
        );

        // Assert
        expect(result, const Right(null));
      });

      test('should handle unicode characters in password', () async {
        // Arrange
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(
          currentPassword: 'oldPassword123',
          newPassword: 'newPässwörd456',
        );

        // Assert
        expect(result, const Right(null));
      });
    });

    group('repository interaction', () {
      test('should not call repository multiple times for single invocation', () async {
        // Arrange
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Right(null));

        // Act
        await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        verify(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should propagate exact failure from repository', () async {
        // Arrange
        const specificFailure = ServerFailure(message: 'Specific error message 12345');
        when(mockRepository.updatePassword(
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        )).thenAnswer((_) async => const Left(specificFailure));

        // Act
        final result = await useCase(
          currentPassword: testCurrentPassword,
          newPassword: testNewPassword,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Specific error message 12345');
          },
          (_) => fail('Expected failure'),
        );
      });
    });
  });
}
