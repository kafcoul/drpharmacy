abstract class Failure {
  final String message;
  /// The original error/exception that caused this failure
  final Object? originalError;

  const Failure(this.message, {this.originalError});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.originalError});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.originalError});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.originalError});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.originalError});
}

/// Failure pour les erreurs 403 (compte non approuvé, suspendu, etc.)
class ForbiddenFailure extends Failure {
  final String? errorCode;
  
  const ForbiddenFailure(super.message, {this.errorCode, super.originalError});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  ValidationFailure(this.errors, {super.originalError})
      : super(errors.values.expand((element) => element).join('\n'));
}
