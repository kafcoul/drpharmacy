import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => state = const AuthState.unauthenticated(),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          state = AuthState.error(
            message: failure.message,
            errors: failure.errors,
          );
        } else {
          state = AuthState.error(message: failure.message);
        }
      },
      (authResponse) {
        state = AuthState.authenticated(authResponse.user);
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
  }) async {
    state = const AuthState.loading();

    final result = await registerUseCase(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      address: address,
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          state = AuthState.error(
            message: failure.message,
            errors: failure.errors,
          );
        } else {
          state = AuthState.error(message: failure.message);
        }
      },
      (authResponse) {
        state = AuthState.authenticated(authResponse.user);
      },
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await logoutUseCase();

    result.fold(
      (failure) => state = AuthState.error(message: failure.message),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Vérifie l'OTP Firebase et met à jour l'état d'authentification
  Future<Either<Failure, AuthResponseEntity>> verifyFirebaseOtp({
    required String phone,
    required String firebaseUid,
  }) async {
    state = const AuthState.loading();

    final result = await authRepository.verifyFirebaseOtp(
      phone: phone,
      firebaseUid: firebaseUid,
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          state = AuthState.error(
            message: failure.message,
            errors: failure.errors,
          );
        } else {
          state = AuthState.error(message: failure.message);
        }
      },
      (authResponse) {
        state = AuthState.authenticated(authResponse.user);
      },
    );

    return result;
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }
}
