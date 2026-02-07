class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'Unauthorized access'});

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception pour les erreurs 403 (compte non approuvé, suspendu, etc.)
class ForbiddenException implements Exception {
  final String message;
  final String? errorCode;

  ForbiddenException({required this.message, this.errorCode});

  @override
  String toString() => 'ForbiddenException: $message (code: $errorCode)';
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;

  ValidationException({required this.errors});

  @override
  String toString() => 'ValidationException: $errors';
}
