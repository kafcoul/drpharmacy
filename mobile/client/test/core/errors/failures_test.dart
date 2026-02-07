import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should create failure with message and statusCode', () {
      const failure = ServerFailure(
        message: 'Server error occurred',
        statusCode: 500,
      );

      expect(failure.message, 'Server error occurred');
      expect(failure.statusCode, 500);
    });

    test('should create failure with message only', () {
      const failure = ServerFailure(
        message: 'Server error',
      );

      expect(failure.message, 'Server error');
      expect(failure.statusCode, isNull);
    });

    test('props should include message and statusCode', () {
      const failure = ServerFailure(
        message: 'Error',
        statusCode: 500,
      );

      expect(failure.props, ['Error', 500]);
    });

    test('should be equal when message and statusCode are same', () {
      const failure1 = ServerFailure(
        message: 'Error',
        statusCode: 500,
      );

      const failure2 = ServerFailure(
        message: 'Error',
        statusCode: 500,
      );

      expect(failure1, failure2);
    });

    test('should not be equal when statusCode differs', () {
      const failure1 = ServerFailure(
        message: 'Error',
        statusCode: 500,
      );

      const failure2 = ServerFailure(
        message: 'Error',
        statusCode: 404,
      );

      expect(failure1, isNot(failure2));
    });

    test('should handle different status codes', () {
      const notFound = ServerFailure(message: 'Not Found', statusCode: 404);
      const badRequest = ServerFailure(message: 'Bad Request', statusCode: 400);
      const internalError = ServerFailure(message: 'Internal Error', statusCode: 500);

      expect(notFound.statusCode, 404);
      expect(badRequest.statusCode, 400);
      expect(internalError.statusCode, 500);
    });
  });

  group('CacheFailure', () {
    test('should create failure with message', () {
      const failure = CacheFailure(message: 'Cache read failed');

      expect(failure.message, 'Cache read failed');
    });

    test('props should include only message', () {
      const failure = CacheFailure(message: 'Error');

      expect(failure.props, ['Error']);
    });

    test('should be equal when messages are same', () {
      const failure1 = CacheFailure(message: 'Error');
      const failure2 = CacheFailure(message: 'Error');

      expect(failure1, failure2);
    });

    test('should not be equal when messages differ', () {
      const failure1 = CacheFailure(message: 'Error 1');
      const failure2 = CacheFailure(message: 'Error 2');

      expect(failure1, isNot(failure2));
    });
  });

  group('NetworkFailure', () {
    test('should create failure with message', () {
      const failure = NetworkFailure(message: 'No internet connection');

      expect(failure.message, 'No internet connection');
    });

    test('props should include only message', () {
      const failure = NetworkFailure(message: 'Timeout');

      expect(failure.props, ['Timeout']);
    });

    test('should be equal when messages are same', () {
      const failure1 = NetworkFailure(message: 'No connection');
      const failure2 = NetworkFailure(message: 'No connection');

      expect(failure1, failure2);
    });

    test('should not be equal when messages differ', () {
      const failure1 = NetworkFailure(message: 'Timeout');
      const failure2 = NetworkFailure(message: 'No connection');

      expect(failure1, isNot(failure2));
    });
  });

  group('ValidationFailure', () {
    test('should create failure with message and errors', () {
      const failure = ValidationFailure(
        message: 'Validation failed',
        errors: {
          'email': ['Email is required'],
        },
      );

      expect(failure.message, 'Validation failed');
      expect(failure.errors['email'], ['Email is required']);
    });

    test('props should include message and errors', () {
      const failure = ValidationFailure(
        message: 'Invalid input',
        errors: {
          'name': ['Name is required'],
        },
      );

      expect(failure.props.length, 2);
      expect(failure.props[0], 'Invalid input');
      expect(failure.props[1], {'name': ['Name is required']});
    });

    test('should be equal when message and errors are same', () {
      const failure1 = ValidationFailure(
        message: 'Error',
        errors: {'field': ['Error']},
      );

      const failure2 = ValidationFailure(
        message: 'Error',
        errors: {'field': ['Error']},
      );

      expect(failure1, failure2);
    });

    test('should not be equal when errors differ', () {
      const failure1 = ValidationFailure(
        message: 'Error',
        errors: {'field1': ['Error']},
      );

      const failure2 = ValidationFailure(
        message: 'Error',
        errors: {'field2': ['Error']},
      );

      expect(failure1, isNot(failure2));
    });

    test('should handle multiple field errors', () {
      const failure = ValidationFailure(
        message: 'Validation failed',
        errors: {
          'email': ['Email is required', 'Invalid format'],
          'password': ['Password too short'],
        },
      );

      expect(failure.errors.length, 2);
      expect(failure.errors['email']?.length, 2);
      expect(failure.errors['password']?.length, 1);
    });

    test('should handle empty errors', () {
      const failure = ValidationFailure(
        message: 'No errors',
        errors: {},
      );

      expect(failure.errors, isEmpty);
    });
  });

  group('UnauthorizedFailure', () {
    test('should create failure with default message', () {
      const failure = UnauthorizedFailure();

      expect(failure.message, 'Unauthorized access');
    });

    test('should create failure with custom message', () {
      const failure = UnauthorizedFailure(message: 'Session expired');

      expect(failure.message, 'Session expired');
    });

    test('props should include message', () {
      const failure = UnauthorizedFailure(message: 'Invalid token');

      expect(failure.props, ['Invalid token']);
    });

    test('should be equal when messages are same', () {
      const failure1 = UnauthorizedFailure();
      const failure2 = UnauthorizedFailure();

      expect(failure1, failure2);
    });

    test('should not be equal when messages differ', () {
      const failure1 = UnauthorizedFailure(message: 'Token expired');
      const failure2 = UnauthorizedFailure(message: 'Invalid token');

      expect(failure1, isNot(failure2));
    });
  });

  group('Failure inheritance', () {
    test('ServerFailure extends Failure', () {
      const failure = ServerFailure(message: 'Error');

      expect(failure, isA<Failure>());
    });

    test('CacheFailure extends Failure', () {
      const failure = CacheFailure(message: 'Error');

      expect(failure, isA<Failure>());
    });

    test('NetworkFailure extends Failure', () {
      const failure = NetworkFailure(message: 'Error');

      expect(failure, isA<Failure>());
    });

    test('ValidationFailure extends Failure', () {
      const failure = ValidationFailure(message: 'Error', errors: {});

      expect(failure, isA<Failure>());
    });

    test('UnauthorizedFailure extends Failure', () {
      const failure = UnauthorizedFailure();

      expect(failure, isA<Failure>());
    });
  });

  group('Equatable behavior', () {
    test('all failures should have hashCode consistency', () {
      const failure1 = ServerFailure(message: 'Error', statusCode: 500);
      const failure2 = ServerFailure(message: 'Error', statusCode: 500);

      expect(failure1.hashCode, failure2.hashCode);
    });

    test('different failure types should not be equal', () {
      const serverFailure = ServerFailure(message: 'Error');
      const networkFailure = NetworkFailure(message: 'Error');
      const cacheFailure = CacheFailure(message: 'Error');

      expect(serverFailure, isNot(networkFailure));
      expect(serverFailure, isNot(cacheFailure));
      expect(networkFailure, isNot(cacheFailure));
    });
  });

  group('Edge cases', () {
    test('should handle empty message', () {
      const failure = ServerFailure(message: '');

      expect(failure.message, '');
    });

    test('should handle very long message', () {
      final longMessage = 'A' * 1000;
      final failure = NetworkFailure(message: longMessage);

      expect(failure.message.length, 1000);
    });

    test('should handle special characters in message', () {
      const failure = CacheFailure(
        message: 'Error: "file" not found <path/to/file>',
      );

      expect(failure.message, 'Error: "file" not found <path/to/file>');
    });

    test('should handle unicode in message', () {
      const failure = NetworkFailure(
        message: 'Erreur de réseau: connexion échouée',
      );

      expect(failure.message, 'Erreur de réseau: connexion échouée');
    });

    test('should handle status code 0', () {
      const failure = ServerFailure(message: 'Error', statusCode: 0);

      expect(failure.statusCode, 0);
    });

    test('ValidationFailure should handle nested error keys', () {
      const failure = ValidationFailure(
        message: 'Validation error',
        errors: {
          'user.profile.name': ['Name is required'],
          'items[0].quantity': ['Quantity must be positive'],
        },
      );

      expect(failure.errors['user.profile.name'], ['Name is required']);
      expect(failure.errors['items[0].quantity'], ['Quantity must be positive']);
    });
  });
}
