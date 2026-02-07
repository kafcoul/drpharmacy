import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/auth/presentation/providers/auth_state.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';

void main() {
  group('AuthStatus', () {
    test('should have all expected values', () {
      expect(AuthStatus.values.length, 5);
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.loading));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });

  group('AuthState', () {
    late UserEntity testUser;

    setUp(() {
      testUser = UserEntity(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+24112345678',
        createdAt: DateTime(2024, 1, 15),
      );
    });

    group('Constructor', () {
      test('should create AuthState with required fields', () {
        // Arrange & Act
        const state = AuthState(status: AuthStatus.initial);

        // Assert
        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
        expect(state.validationErrors, isNull);
      });

      test('should create AuthState with all fields', () {
        // Arrange & Act
        final state = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          errorMessage: null,
          validationErrors: null,
        );

        // Assert
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
      });
    });

    group('AuthState.initial', () {
      test('should create initial state', () {
        // Act
        const state = AuthState.initial();

        // Assert
        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
        expect(state.validationErrors, isNull);
      });
    });

    group('AuthState.loading', () {
      test('should create loading state', () {
        // Act
        const state = AuthState.loading();

        // Assert
        expect(state.status, AuthStatus.loading);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
        expect(state.validationErrors, isNull);
      });
    });

    group('AuthState.authenticated', () {
      test('should create authenticated state with user', () {
        // Act
        final state = AuthState.authenticated(testUser);

        // Assert
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.errorMessage, isNull);
        expect(state.validationErrors, isNull);
      });
    });

    group('AuthState.unauthenticated', () {
      test('should create unauthenticated state', () {
        // Act
        const state = AuthState.unauthenticated();

        // Assert
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
        expect(state.validationErrors, isNull);
      });
    });

    group('AuthState.error', () {
      test('should create error state with message', () {
        // Act
        const state = AuthState.error(message: 'Login failed');

        // Assert
        expect(state.status, AuthStatus.error);
        expect(state.user, isNull);
        expect(state.errorMessage, 'Login failed');
        expect(state.validationErrors, isNull);
      });

      test('should create error state with validation errors', () {
        // Arrange
        const validationErrors = {
          'email': ['Email invalide'],
          'password': ['Mot de passe requis'],
        };

        // Act
        const state = AuthState.error(
          message: 'Validation failed',
          errors: validationErrors,
        );

        // Assert
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Validation failed');
        expect(state.validationErrors, validationErrors);
        expect(state.validationErrors!['email'], contains('Email invalide'));
      });
    });

    group('copyWith', () {
      test('should copy with new status', () {
        // Arrange
        const initialState = AuthState.initial();

        // Act
        final newState = initialState.copyWith(status: AuthStatus.loading);

        // Assert
        expect(newState.status, AuthStatus.loading);
        expect(newState.user, isNull);
      });

      test('should copy with new user', () {
        // Arrange
        const initialState = AuthState.initial();

        // Act
        final newState = initialState.copyWith(user: testUser);

        // Assert
        expect(newState.user, testUser);
        expect(newState.status, AuthStatus.initial);
      });

      test('should copy with new error message', () {
        // Arrange
        const initialState = AuthState.initial();

        // Act
        final newState = initialState.copyWith(errorMessage: 'Error');

        // Assert
        expect(newState.errorMessage, 'Error');
      });

      test('should copy with validation errors', () {
        // Arrange
        const initialState = AuthState.initial();
        const errors = {'field': ['error1']};

        // Act
        final newState = initialState.copyWith(validationErrors: errors);

        // Assert
        expect(newState.validationErrors, errors);
      });

      test('should preserve values when not specified', () {
        // Arrange
        final state = AuthState.authenticated(testUser);

        // Act
        final newState = state.copyWith();

        // Assert
        expect(newState.status, AuthStatus.authenticated);
        expect(newState.user, testUser);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const state1 = AuthState.initial();
        const state2 = AuthState.initial();

        // Assert
        expect(state1, equals(state2));
      });

      test('should not be equal when status differs', () {
        // Arrange
        const state1 = AuthState.initial();
        const state2 = AuthState.loading();

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should be equal for same authenticated user', () {
        // Arrange
        final state1 = AuthState.authenticated(testUser);
        final state2 = AuthState.authenticated(testUser);

        // Assert
        expect(state1, equals(state2));
      });

      test('should not be equal for different error messages', () {
        // Arrange
        const state1 = AuthState.error(message: 'Error 1');
        const state2 = AuthState.error(message: 'Error 2');

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should have props with all fields', () {
        // Arrange
        final state = AuthState.authenticated(testUser);

        // Assert
        expect(state.props.length, 4);
        expect(state.props, contains(AuthStatus.authenticated));
        expect(state.props, contains(testUser));
      });
    });
  });
}
