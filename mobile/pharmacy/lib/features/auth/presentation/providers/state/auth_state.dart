import '../../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error, registered }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  /// Stores the original error/exception for type-based handling
  final Object? originalError;
  /// Stores field-specific validation errors from the server
  /// Key is field name (email, phone, license_number, etc.), value is error message
  final Map<String, String>? fieldErrors;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.originalError,
    this.fieldErrors,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    Object? originalError,
    Map<String, String>? fieldErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      originalError: originalError,
      fieldErrors: fieldErrors,
    );
  }
  
  /// Helper to get error for a specific field
  String? getFieldError(String fieldName) {
    return fieldErrors?[fieldName];
  }
  
  /// Check if there are any field errors
  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;
}
