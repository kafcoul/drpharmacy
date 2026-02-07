import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/profile/domain/usecases/delete_avatar_usecase.dart';

import 'get_profile_usecase_test.mocks.dart';

void main() {
  late DeleteAvatarUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = DeleteAvatarUseCase(repository: mockRepository);
  });

  group('DeleteAvatarUseCase', () {
    group('constructor', () {
      test('should create instance with repository', () {
        expect(useCase.repository, equals(mockRepository));
      });
    });

    group('successful deletion', () {
      test('should call repository deleteAvatar', () async {
        // Arrange
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.deleteAvatar()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return Right(void) on success', () async {
        // Arrange
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(null));
      });

      test('should be callable multiple times', () async {
        // Arrange
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => const Right(null));

        // Act
        await useCase();
        await useCase();
        final result = await useCase();

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.deleteAvatar()).called(3);
      });
    });

    group('repository errors', () {
      test('should return ServerFailure from repository', () async {
        // Arrange
        final failure = ServerFailure(message: 'Server error');
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
        expect(result.isLeft(), true);
      });

      test('should return NetworkFailure from repository', () async {
        // Arrange
        final failure = NetworkFailure(message: 'No internet connection');
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
      });

      test('should return UnauthorizedFailure from repository', () async {
        // Arrange
        final failure = UnauthorizedFailure(message: 'Not authenticated');
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
      });

      test('should return CacheFailure from repository', () async {
        // Arrange
        final failure = CacheFailure(message: 'Cache error');
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
      });

      test('should return ValidationFailure from repository', () async {
        // Arrange
        final failure = ValidationFailure(
          message: 'No avatar to delete',
          errors: {'avatar': ['User has no avatar']},
        );
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Left(failure));
        result.fold(
          (f) {
            expect(f, isA<ValidationFailure>());
            expect((f as ValidationFailure).message, 'No avatar to delete');
          },
          (r) => fail('Should return failure'),
        );
      });
    });

    group('error handling', () {
      test('should propagate repository failure messages', () async {
        // Arrange
        final failure = ServerFailure(message: 'Storage service unavailable');
        when(mockRepository.deleteAvatar())
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase();

        // Assert
        result.fold(
          (f) => expect(f.message, 'Storage service unavailable'),
          (r) => fail('Should return failure'),
        );
      });

      test('should handle different failure types correctly', () async {
        // Arrange
        final failures = [
          ServerFailure(message: 'Server error'),
          NetworkFailure(message: 'Network error'),
          CacheFailure(message: 'Cache error'),
          UnauthorizedFailure(message: 'Unauthorized'),
        ];

        for (final failure in failures) {
          reset(mockRepository);
          when(mockRepository.deleteAvatar())
              .thenAnswer((_) async => Left(failure));

          // Act
          final result = await useCase();

          // Assert
          expect(result.isLeft(), true);
          result.fold(
            (f) => expect(f.runtimeType, failure.runtimeType),
            (r) => fail('Should return failure'),
          );
        }
      });
    });
  });
}
