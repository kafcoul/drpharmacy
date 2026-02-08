import 'package:dio/dio.dart';
import '../../../../core/config/env_config.dart';

/// Helper pour parser les valeurs numériques de façon sécurisée
int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

double _safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

/// Normalise les données de l'overview pour éviter les erreurs de type
Map<String, dynamic> _normalizeOverviewData(Map<String, dynamic> data) {
  final sales = data['sales'] as Map<String, dynamic>?;
  final orders = data['orders'] as Map<String, dynamic>?;
  final inventory = data['inventory'] as Map<String, dynamic>?;
  
  return {
    'period': data['period']?.toString() ?? 'week',
    'date_range': data['date_range'],
    'sales': sales != null ? {
      'today': _safeDouble(sales['today']),
      'yesterday': _safeDouble(sales['yesterday']),
      'period_total': _safeDouble(sales['period_total']),
      'growth': _safeDouble(sales['growth']),
    } : null,
    'orders': orders != null ? {
      'total': _safeInt(orders['total']),
      'pending': _safeInt(orders['pending']),
      'completed': _safeInt(orders['completed']),
      'cancelled': _safeInt(orders['cancelled']),
    } : null,
    'inventory': inventory != null ? {
      'total_products': _safeInt(inventory['total_products']),
      'low_stock': _safeInt(inventory['low_stock']),
      'out_of_stock': _safeInt(inventory['out_of_stock']),
      'expiring_soon': _safeInt(inventory['expiring_soon']),
    } : null,
  };
}

/// Repository pour les rapports et analytics
class ReportsRepository {
  final Dio _dio;
  
  ReportsRepository({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get dashboard overview
  Future<Map<String, dynamic>> getOverview({String period = 'week'}) async {
    try {
      final response = await _dio.get(
        '/pharmacy/reports/overview',
        queryParameters: {'period': period},
      );
      
      // Vérifier si response.data est bien une Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de données invalide');
        }
        return _normalizeOverviewData(data);
      }
      
      // Gérer les erreurs API
      final errorMessage = responseData['message']?.toString() 
          ?? responseData['error']?.toString() 
          ?? 'Erreur lors du chargement';
      throw Exception(errorMessage);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Get sales report
  Future<Map<String, dynamic>> getSalesReport({String period = 'week'}) async {
    try {
      final response = await _dio.get(
        '/pharmacy/reports/sales',
        queryParameters: {'period': period},
      );
      
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de données invalide');
        }
        return data;
      }
      throw Exception(responseData['message']?.toString() ?? 'Erreur lors du chargement');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Get orders report
  Future<Map<String, dynamic>> getOrdersReport({String period = 'week'}) async {
    try {
      final response = await _dio.get(
        '/pharmacy/reports/orders',
        queryParameters: {'period': period},
      );
      
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de données invalide');
        }
        return data;
      }
      throw Exception(responseData['message']?.toString() ?? 'Erreur lors du chargement');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Get inventory report
  Future<Map<String, dynamic>> getInventoryReport() async {
    try {
      final response = await _dio.get('/pharmacy/reports/inventory');
      
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de données invalide');
        }
        return data;
      }
      throw Exception(responseData['message']?.toString() ?? 'Erreur lors du chargement');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Get stock alerts
  Future<Map<String, dynamic>> getStockAlerts() async {
    try {
      final response = await _dio.get('/pharmacy/reports/stock-alerts');
      
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de données invalide');
        }
        return data;
      }
      throw Exception(responseData['message']?.toString() ?? 'Erreur lors du chargement');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Export report
  Future<Map<String, dynamic>> exportReport({
    required String type,
    String format = 'json',
    String period = 'month',
  }) async {
    try {
      final response = await _dio.get(
        '/pharmacy/reports/export',
        queryParameters: {
          'type': type,
          'format': format,
          'period': period,
        },
      );
      
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de données invalide');
        }
        return data;
      }
      throw Exception(responseData['message']?.toString() ?? 'Erreur lors de l\'export');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Session expirée. Veuillez vous reconnecter.');
    } else if (e.response?.statusCode == 403) {
      return Exception('Accès non autorisé.');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Connexion timeout. Vérifiez votre connexion internet.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('Impossible de se connecter au serveur.');
    }
    return Exception(e.response?.data?['message'] ?? 'Une erreur est survenue');
  }
}
