import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service de cache pour stocker les données localement
/// Améliore les performances et permet le mode offline
class CacheService {
  final SharedPreferences _prefs;
  
  // Durées de cache par défaut
  static const Duration defaultCacheDuration = Duration(minutes: 15);
  static const Duration longCacheDuration = Duration(hours: 1);
  static const Duration shortCacheDuration = Duration(minutes: 5);

  CacheService(this._prefs);

  /// Stocke des données avec une durée d'expiration
  Future<bool> setData<T>({
    required String key,
    required T data,
    Duration? expiration,
  }) async {
    try {
      final cacheEntry = CacheEntry(
        data: data,
        timestamp: DateTime.now(),
        expiration: expiration ?? defaultCacheDuration,
      );
      
      final jsonString = jsonEncode(cacheEntry.toJson());
      return await _prefs.setString(_cacheKey(key), jsonString);
    } catch (e) {
      debugPrint('❌ [CacheService] Error setting cache for $key: $e');
      return false;
    }
  }

  /// Récupère des données du cache si elles ne sont pas expirées
  T? getData<T>({
    required String key,
    T Function(dynamic json)? fromJson,
  }) {
    try {
      final jsonString = _prefs.getString(_cacheKey(key));
      if (jsonString == null) return null;

      final cacheMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final cacheEntry = CacheEntry.fromJson(cacheMap);

      if (cacheEntry.isExpired) {
        debugPrint('⏰ [CacheService] Cache expired for $key');
        removeData(key);
        return null;
      }

      if (fromJson != null) {
        return fromJson(cacheEntry.data);
      }
      
      return cacheEntry.data as T?;
    } catch (e) {
      debugPrint('❌ [CacheService] Error getting cache for $key: $e');
      return null;
    }
  }

  /// Vérifie si une clé existe et n'est pas expirée
  bool hasValidCache(String key) {
    try {
      final jsonString = _prefs.getString(_cacheKey(key));
      if (jsonString == null) return false;

      final cacheMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final cacheEntry = CacheEntry.fromJson(cacheMap);

      return !cacheEntry.isExpired;
    } catch (e) {
      return false;
    }
  }

  /// Supprime une entrée du cache
  Future<bool> removeData(String key) async {
    return await _prefs.remove(_cacheKey(key));
  }

  /// Vide tout le cache
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    debugPrint('🧹 [CacheService] Cache cleared');
  }

  /// Vide le cache expiré
  Future<void> clearExpired() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    int clearedCount = 0;
    
    for (final key in keys) {
      try {
        final jsonString = _prefs.getString(key);
        if (jsonString == null) continue;

        final cacheMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final cacheEntry = CacheEntry.fromJson(cacheMap);

        if (cacheEntry.isExpired) {
          await _prefs.remove(key);
          clearedCount++;
        }
      } catch (e) {
        await _prefs.remove(key);
        clearedCount++;
      }
    }
    
    debugPrint('🧹 [CacheService] Cleared $clearedCount expired entries');
  }

  /// Retourne les statistiques du cache
  CacheStats getStats() {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    int totalEntries = 0;
    int expiredEntries = 0;
    int totalSizeBytes = 0;

    for (final key in keys) {
      totalEntries++;
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        totalSizeBytes += jsonString.length;
        try {
          final cacheMap = jsonDecode(jsonString) as Map<String, dynamic>;
          final cacheEntry = CacheEntry.fromJson(cacheMap);
          if (cacheEntry.isExpired) expiredEntries++;
        } catch (_) {
          expiredEntries++;
        }
      }
    }

    return CacheStats(
      totalEntries: totalEntries,
      expiredEntries: expiredEntries,
      totalSizeKB: totalSizeBytes / 1024,
    );
  }

  String _cacheKey(String key) => 'cache_$key';
}

/// Entrée de cache avec métadonnées
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration expiration;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiration,
  });

  bool get isExpired => DateTime.now().isAfter(timestamp.add(expiration));

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'expirationMs': expiration.inMilliseconds,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      expiration: Duration(milliseconds: json['expirationMs']),
    );
  }
}

/// Statistiques du cache
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final double totalSizeKB;

  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.totalSizeKB,
  });

  int get validEntries => totalEntries - expiredEntries;

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries, size: ${totalSizeKB.toStringAsFixed(2)} KB)';
  }
}

/// Clés de cache prédéfinies
class CacheKeys {
  static const String orders = 'orders';
  static const String inventory = 'inventory';
  static const String notifications = 'notifications';
  static const String userProfile = 'user_profile';
  static const String pharmacyInfo = 'pharmacy_info';
  static const String categories = 'categories';
  static const String statistics = 'statistics';
  static const String walletBalance = 'wallet_balance';
  static const String transactions = 'transactions';
}
