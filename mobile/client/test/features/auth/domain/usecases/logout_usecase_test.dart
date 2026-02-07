import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:drpharma_client/core/errors/failures.dart';

// Re-use existing mock
import 'login_usecase_test.mocks.dart';

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    group('successful logout', () {
      test('should call repository logout method', () async {
        // Arrange
        when(mockRepository.logout())
            .thenAnswer((_) async => const Right(null));

        // Act
        await useCase();

        // Assert
        verify(mockRepository.logout()).called(1);
      });

      test('should return Right(void) when logout succeeds', () async {
        // Arrange
        when(mockRepository.logout())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(null));
      });

      test('should clear user session on successful logout', () async {
        // Arrange
        when(mockRepository.logout())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.logout()).called(1);
      });
    });

    group('failure cases', () {
      test('should return ServerFailure when server error occurs', () async {
        // Arrange
        const failure = ServerFailure(message: 'Server error');
        when(mockRepository.logout())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });

      test('should return NetworkFailure when no internet connection', () async {
        // Arrange
        const failure = NetworkFailure(message: 'No internet connection');
        when(mockRepository.logout())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });

      test('should return UnauthorizedFailure when token is invalid', () async {
        // Arrange
        const failure = UnauthorizedFailure();
        when(mockRepository.logout())
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(failure));
      });

      test('should return CacheFailure when unable to clear local data', () async {
        // Arrange
        const failure = CacheFailure(message: 'Failed to clear local data');
        when(mockRepository.logout())
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
        when(mockRepository.logout())
            .thenAnswer((_) async => const Right(null));

        // Act
        await useCase();

        // Assert
        verify(mockRepository.logout()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should propagate exact failure from repository', () async {
        // Arrange
        const specificFailure = ServerFailure(message: 'Specific logout error');
        when(mockRepository.logout())
            .thenAnswer((_) async => const Left(specificFailure));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Specific logout error');
          },
          (_) => fail('Expected failure'),
        );
      });
    });
  });
}
