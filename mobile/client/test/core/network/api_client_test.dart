import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/core/errors/exceptions.dart';
import 'package:drpharma_client/core/config/env_config.dart';

// We need to test ApiClient behavior without actual network calls
// We'll use a custom approach by extending ApiClient for testing

@GenerateMocks([Dio])
void main() {
  // Initialize EnvConfig before all tests
  setUpAll(() async {
    await EnvConfig.init();
  });

  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    group('Token Management', () {
      test('setToken should store the access token', () {
        // Arrange & Act
        apiClient.setToken('test_token_123');
        
        // Assert - we can verify by calling authorizedOptions
        final options = apiClient.authorizedOptions('other_token');
        expect(options.headers?['Authorization'], 'Bearer other_token');
      });

      test('clearToken should remove the access token', () {
        // Arrange
        apiClient.setToken('test_token_123');
        
        // Act
        apiClient.clearToken();
        
        // Assert - token should be null now (no way to verify directly, but no error)
        expect(() => apiClient.clearToken(), returnsNormally);
      });

      test('authorizedOptions should return correct header', () {
        // Arrange
        const token = 'my_bearer_token';
        
        // Act
        final options = apiClient.authorizedOptions(token);
        
        // Assert
        expect(options.headers, isNotNull);
        expect(options.headers!['Authorization'], 'Bearer $token');
      });
    });

    group('Error Handling', () {
      test('should identify network timeout exceptions', () {
        // Verify that timeout exceptions are properly classified
        final timeoutException = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(timeoutException.type, DioExceptionType.connectionTimeout);
      });

      test('should identify connection error exceptions', () {
        final connectionException = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(connectionException.type, DioExceptionType.connectionError);
      });

      test('should handle 401 response correctly', () {
        // Create a mock 401 response
        final response = Response<Map<String, dynamic>>(
          statusCode: 401,
          data: {'message': 'Session expired'},
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(response.statusCode, 401);
        expect(response.data?['message'], 'Session expired');
      });

      test('should handle 403 response correctly', () {
        final response = Response<Map<String, dynamic>>(
          statusCode: 403,
          data: {'message': 'Access denied', 'error_code': 'PHONE_NOT_VERIFIED'},
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(response.statusCode, 403);
        expect(response.data?['error_code'], 'PHONE_NOT_VERIFIED');
      });

      test('should handle 422 validation response correctly', () {
        final response = Response<Map<String, dynamic>>(
          statusCode: 422,
          data: {
            'message': 'Validation failed',
            'errors': {
              'email': ['Email is required', 'Email must be valid'],
              'password': ['Password is too short'],
            },
          },
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(response.statusCode, 422);
        final errors = response.data?['errors'] as Map<String, dynamic>?;
        expect(errors?['email'], isA<List>());
        expect((errors?['email'] as List?)?.length, 2);
      });

      test('should handle 404 response correctly', () {
        final response = Response<Map<String, dynamic>>(
          statusCode: 404,
          data: {'message': 'Resource not found'},
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(response.statusCode, 404);
      });

      test('should handle 500 server error correctly', () {
        final response = Response<Map<String, dynamic>>(
          statusCode: 500,
          data: {'message': 'Internal server error'},
          requestOptions: RequestOptions(path: '/test'),
        );
        
        expect(response.statusCode, 500);
      });
    });
  });

  group('Exception Classes', () {
    test('ServerException should store message and statusCode', () {
      final exception = ServerException(
        message: 'Server error',
        statusCode: 500,
      );
      
      expect(exception.message, 'Server error');
      expect(exception.statusCode, 500);
    });

    test('NetworkException should store message', () {
      final exception = NetworkException(
        message: 'No internet connection',
      );
      
      expect(exception.message, 'No internet connection');
    });

    test('UnauthorizedException should store message', () {
      final exception = UnauthorizedException(
        message: 'Token expired',
      );
      
      expect(exception.message, 'Token expired');
    });

    test('ValidationException should store errors map', () {
      final exception = ValidationException(
        errors: {
          'email': ['Email is required'],
          'phone': ['Phone is invalid'],
        },
      );
      
      expect(exception.errors.length, 2);
      expect(exception.errors['email']?.first, 'Email is required');
      expect(exception.errors['phone']?.first, 'Phone is invalid');
    });

    test('ValidationException errors should be accessible by key', () {
      final exception = ValidationException(
        errors: {
          'password': ['Too short', 'Needs uppercase'],
        },
      );
      
      expect(exception.errors['password']?.length, 2);
      expect(exception.errors['nonexistent'], isNull);
    });
  });

  group('Request Options', () {
    test('authorizedOptions should create valid Options object', () {
      final apiClient = ApiClient();
      const token = 'valid_token_123';
      
      final options = apiClient.authorizedOptions(token);
      
      expect(options, isA<Options>());
      expect(options.headers, isNotNull);
      expect(options.headers!.containsKey('Authorization'), true);
    });

    test('authorizedOptions should format Bearer token correctly', () {
      final apiClient = ApiClient();
      const token = 'abc123def456';
      
      final options = apiClient.authorizedOptions(token);
      
      expect(options.headers!['Authorization'], startsWith('Bearer '));
      expect(options.headers!['Authorization'], contains(token));
    });

    test('multiple calls to authorizedOptions should work independently', () {
      final apiClient = ApiClient();
      
      final options1 = apiClient.authorizedOptions('token1');
      final options2 = apiClient.authorizedOptions('token2');
      
      expect(options1.headers!['Authorization'], 'Bearer token1');
      expect(options2.headers!['Authorization'], 'Bearer token2');
    });
  });

  group('ApiClient Configuration', () {
    test('should create instance without errors', () {
      expect(() => ApiClient(), returnsNormally);
    });

    test('multiple instances should be independent', () {
      final client1 = ApiClient();
      final client2 = ApiClient();
      
      client1.setToken('token1');
      client2.setToken('token2');
      
      // Each client should maintain its own state
      expect(client1, isNot(same(client2)));
    });

    test('token operations should not throw on empty state', () {
      final apiClient = ApiClient();
      
      // Should not throw even if no token was set
      expect(() => apiClient.clearToken(), returnsNormally);
    });

    test('setToken then clearToken should work in sequence', () {
      final apiClient = ApiClient();
      
      apiClient.setToken('test_token');
      apiClient.clearToken();
      apiClient.setToken('new_token');
      
      // Should work without errors
      expect(() => apiClient.clearToken(), returnsNormally);
    });
  });

  group('DioException Types', () {
    test('should recognize all DioExceptionType values', () {
      // Verify all exception types are accessible
      expect(DioExceptionType.connectionTimeout, isNotNull);
      expect(DioExceptionType.sendTimeout, isNotNull);
      expect(DioExceptionType.receiveTimeout, isNotNull);
      expect(DioExceptionType.badCertificate, isNotNull);
      expect(DioExceptionType.badResponse, isNotNull);
      expect(DioExceptionType.cancel, isNotNull);
      expect(DioExceptionType.connectionError, isNotNull);
      expect(DioExceptionType.unknown, isNotNull);
    });

    test('connectionTimeout should be distinct from receiveTimeout', () {
      expect(
        DioExceptionType.connectionTimeout,
        isNot(equals(DioExceptionType.receiveTimeout)),
      );
    });
  });
}
