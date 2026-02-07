import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/auth/domain/entities/auth_response_entity.dart';
import 'package:drpharma_client/features/auth/domain/entities/user_entity.dart';
import 'package:drpharma_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:drpharma_client/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_notifier.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_state.dart';

import 'auth_notifier_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  AuthRepository,
])
void main() {
  late AuthNotifier authNotifier;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockAuthRepository mockAuthRepository;

  // Test user fixture
  final testUser = UserEntity(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    phone: '0123456789',
    address: '123 Test St',
    createdAt: DateTime.now(),
  );

  final testAuthResponse = AuthResponseEntity(
    user: testUser,
    token: 'test_token_123',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockAuthRepository = MockAuthRepository();

    // Default: no authenticated user
    when(mockGetCurrentUserUseCase())
        .thenAnswer((_) async => Left(const ServerFailure(message: 'Unauthenticated')));

    authNotifier = AuthNotifier(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      authRepository: mockAuthRepository,
    );
  });

  group('AuthNotifier initialization', () {
    test('should start with initial state then check auth status', () async {
      // Wait for initial auth check
      await Future.delayed(const Duration(milliseconds: 100));

      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      verify(mockGetCurrentUserUseCase()).called(1);
    });

    test('should be authenticated if user exists in cache', () async {
      // Setup: user exists
      when(mockGetCurrentUserUseCase())
          .thenAnswer((_) async => Right(testUser));

      // Create new notifier with cached user
      final notifier = AuthNotifier(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: mockLogoutUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        authRepository: mockAuthRepository,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user, testUser);
    });
  });

  group('AuthNotifier.login', () {
    test('should emit loading then authenticated on successful login',
        () async {
      // Arrange
      when(mockLoginUseCase(email: 'test@example.com', password: 'password123'))
          .thenAnswer((_) async => Right(testAuthResponse));

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(states.any((s) => s.status == AuthStatus.loading), isTrue);
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user, testUser);
      verify(mockLoginUseCase(
              email: 'test@example.com', password: 'password123'))
          .called(1);
    });

    test('should emit loading then error on login failure', () async {
      // Arrange
      when(mockLoginUseCase(email: 'test@example.com', password: 'wrongpass'))
          .thenAnswer((_) async => Left(const ServerFailure(message: 'Invalid credentials')));

      // Act
      await authNotifier.login(
        email: 'test@example.com',
        password: 'wrongpass',
      );

      // Assert
      expect(authNotifier.state.status, AuthStatus.error);
      expect(authNotifier.state.errorMessage, 'Invalid credentials');
    });

    test('should handle validation errors from login', () async {
      // Arrange
      when(mockLoginUseCase(email: 'bad', password: '123'))
          .thenAnswer((_) async => Left(const ValidationFailure(
                message: 'Validation failed',
                errors: {'email': ['Invalid email format']},
              )));

      // Act
      await authNotifier.login(email: 'bad', password: '123');

      // Assert
      expect(authNotifier.state.status, AuthStatus.error);
      expect(authNotifier.state.validationErrors, isNotNull);
      expect(authNotifier.state.validationErrors!['email'], contains('Invalid email format'));
    });
  });

  group('AuthNotifier.register', () {
    test('should emit loading then authenticated on successful registration',
        () async {
      // Arrange
      when(mockRegisterUseCase(
        name: 'New User',
        email: 'new@example.com',
        phone: '0123456789',
        password: 'password123',
        passwordConfirmation: 'password123',
        address: null,
      )).thenAnswer((_) async => Right(testAuthResponse));

      // Act
      await authNotifier.register(
        name: 'New User',
        email: 'new@example.com',
        phone: '0123456789',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user, testUser);
    });

    test('should emit error on registration failure', () async {
      // Arrange
      when(mockRegisterUseCase(
        name: 'Test',
        email: 'existing@example.com',
        phone: '0123456789',
        password: 'password123',
        passwordConfirmation: 'password123',
        address: null,
      )).thenAnswer((_) async => Left(const ValidationFailure(
            message: 'Email already exists',
            errors: {'email': ['This email is already taken']},
          )));

      // Act
      await authNotifier.register(
        name: 'Test',
        email: 'existing@example.com',
        phone: '0123456789',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      // Assert
      expect(authNotifier.state.status, AuthStatus.error);
      expect(authNotifier.state.errorMessage, 'Email already exists');
    });
  });

  group('AuthNotifier.logout', () {
    test('should emit loading then unauthenticated on successful logout',
        () async {
      // First login
      when(mockLoginUseCase(email: 'test@example.com', password: 'password123'))
          .thenAnswer((_) async => Right(testAuthResponse));
      await authNotifier.login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Then logout
      when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));

      // Act
      await authNotifier.logout();

      // Assert
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.user, isNull);
      verify(mockLogoutUseCase()).called(1);
    });

    test('should emit error if logout fails', () async {
      // Arrange
      when(mockLogoutUseCase())
          .thenAnswer((_) async => Left(const NetworkFailure(message: 'No connection')));

      // Act
      await authNotifier.logout();

      // Assert
      expect(authNotifier.state.status, AuthStatus.error);
      expect(authNotifier.state.errorMessage, 'No connection');
    });
  });

  group('AuthNotifier.clearError', () {
    test('should clear error state and return to unauthenticated', () async {
      // Arrange: set error state
      when(mockLoginUseCase(email: 'test@example.com', password: 'wrong'))
          .thenAnswer((_) async => Left(const ServerFailure(message: 'Error')));
      await authNotifier.login(
        email: 'test@example.com',
        password: 'wrong',
      );
      expect(authNotifier.state.status, AuthStatus.error);

      // Act
      authNotifier.clearError();

      // Assert
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.errorMessage, isNull);
    });

    test('should not change state if not in error', () async {
      // Wait for initial state
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authNotifier.state.status, AuthStatus.unauthenticated);

      // Act
      authNotifier.clearError();

      // Assert - still unauthenticated
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
    });
  });
}
