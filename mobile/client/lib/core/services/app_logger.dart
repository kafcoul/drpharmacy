import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service de logging centralisé pour DR-PHARMA
/// Remplace les debugPrint dispersés par un système structuré
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in', tag: 'AUTH');
/// AppLogger.error('API call failed', error: e, stackTrace: st, tag: 'API');
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// Log de debug (développement uniquement)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _logger.d(_formatMessage(message, tag));
    }
  }

  /// Log d'information
  static void info(String message, {String? tag}) {
    _logger.i(_formatMessage(message, tag));
  }

  /// Log d'avertissement
  static void warning(String message, {String? tag, Object? error}) {
    _logger.w(_formatMessage(message, tag), error: error);
  }

  /// Log d'erreur
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(_formatMessage(message, tag), error: error, stackTrace: stackTrace);
  }

  /// Log fatal (erreurs critiques)
  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(_formatMessage(message, tag), error: error, stackTrace: stackTrace);
  }

  /// Formate le message avec le tag optionnel
  static String _formatMessage(String message, String? tag) {
    if (tag != null) {
      return '[$tag] $message';
    }
    return message;
  }

  // ============= Logs spécifiques par domaine =============

  /// Log API calls
  static void api(
    String method,
    String path, {
    int? statusCode,
    String? message,
    Object? error,
  }) {
    final buffer = StringBuffer()
      ..write('$method $path');
    
    if (statusCode != null) {
      buffer.write(' → $statusCode');
    }
    if (message != null) {
      buffer.write(' | $message');
    }

    if (error != null || (statusCode != null && statusCode >= 400)) {
      _logger.e(buffer.toString(), error: error);
    } else {
      _logger.i(buffer.toString());
    }
  }

  /// Log authentication events
  static void auth(String event, {String? userId, Object? error}) {
    final message = userId != null ? '$event (user: $userId)' : event;
    if (error != null) {
      _logger.e('[AUTH] $message', error: error);
    } else {
      _logger.i('[AUTH] $message');
    }
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    _logger.d('[NAV] $from → $to');
  }

  /// Log Firebase events
  static void firebase(String event, {Object? error}) {
    if (error != null) {
      _logger.e('[FIREBASE] $event', error: error);
    } else {
      _logger.i('[FIREBASE] $event');
    }
  }

  /// Log cart operations
  static void cart(String operation, {int? itemCount, String? productName}) {
    final buffer = StringBuffer('[CART] $operation');
    if (productName != null) buffer.write(' - $productName');
    if (itemCount != null) buffer.write(' (total: $itemCount items)');
    _logger.d(buffer.toString());
  }

  /// Log order operations
  static void order(String event, {int? orderId, String? status}) {
    final buffer = StringBuffer('[ORDER] $event');
    if (orderId != null) buffer.write(' #$orderId');
    if (status != null) buffer.write(' [$status]');
    _logger.i(buffer.toString());
  }

  /// Log location operations
  static void location(String event, {double? lat, double? lng, Object? error}) {
    final buffer = StringBuffer('[LOCATION] $event');
    if (lat != null && lng != null) {
      buffer.write(' ($lat, $lng)');
    }
    if (error != null) {
      _logger.w(buffer.toString(), error: error);
    } else {
      _logger.d(buffer.toString());
    }
  }
}

/// Extension pour faciliter le logging dans les widgets
extension LoggerExtension on Object {
  void logDebug(String message) => AppLogger.debug(message, tag: runtimeType.toString());
  void logInfo(String message) => AppLogger.info(message, tag: runtimeType.toString());
  void logWarning(String message, {Object? error}) => 
      AppLogger.warning(message, tag: runtimeType.toString(), error: error);
  void logError(String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.error(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
}
