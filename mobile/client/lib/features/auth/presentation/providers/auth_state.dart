import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final Map<String, List<String>>? validationErrors;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.validationErrors,
  });

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      errorMessage = null,
      validationErrors = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      user = null,
      errorMessage = null,
      validationErrors = null;

  const AuthState.authenticated(this.user)
    : status = AuthStatus.authenticated,
      errorMessage = null,
      validationErrors = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      errorMessage = null,
      validationErrors = null;

  const AuthState.error({
    required String message,
    Map<String, List<String>>? errors,
  }) : status = AuthStatus.error,
       user = null,
       errorMessage = message,
       validationErrors = errors;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, validationErrors];
}
