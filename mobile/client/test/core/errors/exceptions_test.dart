import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('should create exception with message and statusCode', () {
      final exception = ServerException(
        message: 'Server error occurred',
        statusCode: 500,
      );

      expect(exception.message, 'Server error occurred');
      expect(exception.statusCode, 500);
    });

    test('should create exception with message only', () {
      final exception = ServerException(
        message: 'Server error',
      );

      expect(exception.message, 'Server error');
      expect(exception.statusCode, isNull);
    });

    test('toString should include message and status code', () {
      final exception = ServerException(
        message: 'Internal Server Error',
        statusCode: 500,
      );

      expect(
        exception.toString(),
        'ServerException: Internal Server Error (Status: 500)',
      );
    });

    test('toString should handle null status code', () {
      final exception = ServerException(
        message: 'Error',
      );

      expect(
        exception.toString(),
        'ServerException: Error (Status: null)',
      );
    });

    test('should handle different status codes', () {
      final notFound = ServerException(
        message: 'Not Found',
        statusCode: 404,
      );

      final badRequest = ServerException(
        message: 'Bad Request',
        statusCode: 400,
      );

      final unauthorized = ServerException(
        message: 'Unauthorized',
        statusCode: 401,
      );

      expect(notFound.statusCode, 404);
      expect(badRequest.statusCode, 400);
      expect(unauthorized.statusCode, 401);
    });
  });

  group('CacheException', () {
    test('should create exception with message', () {
      final exception = CacheException(message: 'Cache read failed');

      expect(exception.message, 'Cache read failed');
    });

    test('toString should include message', () {
      final exception = CacheException(message: 'Cache write failed');

      expect(
        exception.toString(),
        'CacheException: Cache write failed',
      );
    });

    test('should handle different cache errors', () {
      final readError = CacheException(message: 'Failed to read from cache');
      final writeError = CacheException(message: 'Failed to write to cache');
      final clearError = CacheException(message: 'Failed to clear cache');

      expect(readError.message, 'Failed to read from cache');
      expect(writeError.message, 'Failed to write to cache');
      expect(clearError.message, 'Failed to clear cache');
    });
  });

  group('NetworkException', () {
    test('should create exception with message', () {
      final exception = NetworkException(message: 'No internet connection');

      expect(exception.message, 'No internet connection');
    });

    test('toString should include message', () {
      final exception = NetworkException(message: 'Connection timeout');

      expect(
        exception.toString(),
        'NetworkException: Connection timeout',
      );
    });

    test('should handle different network errors', () {
      final noConnection = NetworkException(message: 'No internet connection');
      final timeout = NetworkException(message: 'Connection timeout');
      final dnsError = NetworkException(message: 'DNS resolution failed');

      expect(noConnection.message, 'No internet connection');
      expect(timeout.message, 'Connection timeout');
      expect(dnsError.message, 'DNS resolution failed');
    });
  });

  group('UnauthorizedException', () {
    test('should create exception with default message', () {
      final exception = UnauthorizedException();

      expect(exception.message, 'Unauthorized access');
    });

    test('should create exception with custom message', () {
      final exception = UnauthorizedException(
        message: 'Invalid token',
      );

      expect(exception.message, 'Invalid token');
    });

    test('toString should include message', () {
      final exception = UnauthorizedException(
        message: 'Session expired',
      );

      expect(
        exception.toString(),
        'UnauthorizedException: Session expired',
      );
    });

    test('toString with default message', () {
      final exception = UnauthorizedException();

      expect(
        exception.toString(),
        'UnauthorizedException: Unauthorized access',
      );
    });

    test('should handle different unauthorized scenarios', () {
      final tokenExpired = UnauthorizedException(message: 'Token expired');
      final invalidCredentials = UnauthorizedException(message: 'Invalid credentials');
      final accessDenied = UnauthorizedException(message: 'Access denied');

      expect(tokenExpired.message, 'Token expired');
      expect(invalidCredentials.message, 'Invalid credentials');
      expect(accessDenied.message, 'Access denied');
    });
  });

  group('ValidationException', () {
    test('should create exception with single field error', () {
      final exception = ValidationException(
        errors: {
          'email': ['Email is required'],
        },
      );

      expect(exception.errors['email'], ['Email is required']);
    });

    test('should create exception with multiple field errors', () {
      final exception = ValidationException(
        errors: {
          'email': ['Email is required'],
          'password': ['Password is too short'],
        },
      );

      expect(exception.errors['email'], ['Email is required']);
      expect(exception.errors['password'], ['Password is too short']);
    });

    test('should create exception with multiple errors per field', () {
      final exception = ValidationException(
        errors: {
          'password': [
            'Password is too short',
            'Password must contain a number',
            'Password must contain a special character',
          ],
        },
      );

      expect(exception.errors['password']?.length, 3);
    });

    test('toString should include errors', () {
      final exception = ValidationException(
        errors: {
          'name': ['Name is required'],
        },
      );

      expect(
        exception.toString(),
        "ValidationException: {name: [Name is required]}",
      );
    });

    test('should handle empty errors map', () {
      final exception = ValidationException(errors: {});

      expect(exception.errors, isEmpty);
      expect(exception.toString(), 'ValidationException: {}');
    });

    test('should handle complex validation errors', () {
      final exception = ValidationException(
        errors: {
          'user.email': ['Invalid email format'],
          'user.phone': ['Phone number is invalid'],
          'items': ['At least one item is required'],
          'address.zip': ['Invalid zip code'],
        },
      );

      expect(exception.errors.length, 4);
      expect(exception.errors['user.email'], ['Invalid email format']);
      expect(exception.errors['address.zip'], ['Invalid zip code']);
    });

    test('should handle empty error messages', () {
      final exception = ValidationException(
        errors: {
          'field': [],
        },
      );

      expect(exception.errors['field'], isEmpty);
    });
  });

  group('Exception type checking', () {
    test('ServerException implements Exception', () {
      final exception = ServerException(message: 'Test');

      expect(exception, isA<Exception>());
    });

    test('CacheException implements Exception', () {
      final exception = CacheException(message: 'Test');

      expect(exception, isA<Exception>());
    });

    test('NetworkException implements Exception', () {
      final exception = NetworkException(message: 'Test');

      expect(exception, isA<Exception>());
    });

    test('UnauthorizedException implements Exception', () {
      final exception = UnauthorizedException();

      expect(exception, isA<Exception>());
    });

    test('ValidationException implements Exception', () {
      final exception = ValidationException(errors: {});

      expect(exception, isA<Exception>());
    });
  });

  group('Edge cases', () {
    test('should handle empty message in ServerException', () {
      final exception = ServerException(message: '');

      expect(exception.message, '');
      expect(exception.toString(), 'ServerException:  (Status: null)');
    });

    test('should handle very long messages', () {
      final longMessage = 'A' * 1000;
      final exception = ServerException(message: longMessage);

      expect(exception.message.length, 1000);
    });

    test('should handle special characters in messages', () {
      final exception = CacheException(
        message: 'Error: "file" not found <path/to/file>',
      );

      expect(exception.message, 'Error: "file" not found <path/to/file>');
    });

    test('should handle unicode in messages', () {
      final exception = NetworkException(
        message: 'Erreur de réseau: connexion échouée',
      );

      expect(exception.message, 'Erreur de réseau: connexion échouée');
    });

    test('should handle status code 0', () {
      final exception = ServerException(
        message: 'Error',
        statusCode: 0,
      );

      expect(exception.statusCode, 0);
    });

    test('should handle negative status code', () {
      final exception = ServerException(
        message: 'Error',
        statusCode: -1,
      );

      expect(exception.statusCode, -1);
    });
  });
}
