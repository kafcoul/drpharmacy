import '../../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error, registered }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  /// Stores the original error/exception for type-based handling
  final Object? originalError;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.originalError,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    Object? originalError,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      originalError: originalError,
    );
  }
}
