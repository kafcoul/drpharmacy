import 'package:dio/dio.dart';
import '../models/wallet_data.dart';

class WalletRepository {
  final Dio _dio;
  final String _endpoint = '/pharmacy/wallet';

  WalletRepository(this._dio);

  /// Récupère les données du portefeuille
  Future<WalletData> getWalletData() async {
    try {
      final response = await _dio.get(_endpoint);
      return WalletData.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch wallet data: $e');
    }
  }

  /// Récupère les statistiques par période
  Future<WalletStats> getStatsByPeriod(String period) async {
    try {
      final response = await _dio.get('$_endpoint/stats', queryParameters: {
        'period': period, // today, week, month, year
      });
      return WalletStats.fromJson(response.data['data']);
    } catch (e) {
      // Fallback: calculer localement
      final wallet = await getWalletData();
      return _calculateLocalStats(wallet, period);
    }
  }

  /// Demande de retrait
  Future<WithdrawResponse> requestWithdrawal({
    required double amount,
    required String paymentMethod, // wave, mtn, orange, moov, bank
    String? accountDetails,
    String? phone,
    String? pin,
  }) async {
    try {
      // Mapper vers les codes Côte d'Ivoire
      final mappedMethod = _mapPaymentMethodToCI(paymentMethod);
      
      final response = await _dio.post('$_endpoint/withdraw', data: {
        'amount': amount,
        'payment_method': mappedMethod,
        'account_details': accountDetails,
        'phone': phone,
        'pin': pin,
      });
      return WithdrawResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to request withdrawal: $e');
    }
  }
  
  /// Mapper les méthodes de paiement vers les codes Jeko
  String _mapPaymentMethodToCI(String method) {
    switch (method) {
      case 'orange':
        return 'orange';
      case 'mtn':
        return 'mtn';
      case 'moov':
        return 'moov';
      case 'wave':
        return 'wave';
      case 'bank':
        return 'bank';
      default:
        return method;
    }
  }

  /// Enregistrer les informations bancaires
  Future<bool> saveBankInfo({
    required String bankName,
    required String holderName,
    required String accountNumber,
    String? iban,
  }) async {
    try {
      await _dio.post('$_endpoint/bank-info', data: {
        'bank_name': bankName,
        'holder_name': holderName,
        'account_number': accountNumber,
        'iban': iban,
      });
      return true;
    } catch (e) {
      throw Exception('Failed to save bank info: $e');
    }
  }

  /// Enregistrer les informations Mobile Money
  Future<bool> saveMobileMoneyInfo({
    required String operator,
    required String phoneNumber,
    required String accountName,
    bool isPrimary = true,
  }) async {
    try {
      await _dio.post('$_endpoint/mobile-money', data: {
        'operator': operator,
        'phone_number': phoneNumber,
        'account_name': accountName,
        'is_primary': isPrimary,
      });
      return true;
    } catch (e) {
      throw Exception('Failed to save mobile money info: $e');
    }
  }

  /// Récupérer les paramètres de seuil de retrait
  Future<WithdrawalSettings> getWithdrawalSettings() async {
    try {
      final response = await _dio.get('$_endpoint/threshold');
      return WithdrawalSettings.fromJson(response.data['data']);
    } catch (e) {
      // Retourner les valeurs par défaut en cas d'erreur
      return WithdrawalSettings(
        threshold: 50000,
        autoWithdraw: false,
        hasPin: false,
        hasMobileMoney: false,
        hasBankInfo: false,
      );
    }
  }

  /// Configurer le seuil de retrait automatique
  Future<WithdrawalSettings> setWithdrawalThreshold({
    required double threshold,
    required bool autoWithdraw,
  }) async {
    try {
      final response = await _dio.post('$_endpoint/threshold', data: {
        'threshold': threshold,
        'auto_withdraw': autoWithdraw,
      });
      return WithdrawalSettings(
        threshold: (response.data['data']['threshold'] as num).toDouble(),
        autoWithdraw: response.data['data']['auto_withdraw'] ?? false,
        hasPin: false,
        hasMobileMoney: false,
        hasBankInfo: false,
      );
    } catch (e) {
      throw Exception('Failed to set withdrawal threshold: $e');
    }
  }

  /// Exporter les transactions
  Future<String> exportTransactions({
    required String format, // pdf, excel, csv
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get('$_endpoint/export', queryParameters: {
        'format': format,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      });
      return response.data['download_url'] ?? '';
    } catch (e) {
      throw Exception('Failed to export transactions: $e');
    }
  }

  /// Calcul local des statistiques (fallback)
  WalletStats _calculateLocalStats(WalletData wallet, String period) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    final filteredTx = wallet.transactions.where((tx) {
      if (tx.date == null) return false;
      try {
        // Parse date format "dd/MM/yyyy HH:mm"
        final parts = tx.date!.split(' ')[0].split('/');
        final txDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        return txDate.isAfter(startDate) || txDate.isAtSameMomentAs(startDate);
      } catch (e) {
        return false;
      }
    }).toList();

    final credits = filteredTx.where((tx) => tx.type == 'credit').fold(0.0, (sum, tx) => sum + tx.amount);
    final debits = filteredTx.where((tx) => tx.type == 'debit').fold(0.0, (sum, tx) => sum + tx.amount);

    return WalletStats(
      totalCredits: credits,
      totalDebits: debits,
      transactionCount: filteredTx.length,
      averageTransaction: filteredTx.isEmpty ? 0 : (credits + debits) / filteredTx.length,
      period: period,
    );
  }
}

/// Modèle pour les statistiques
class WalletStats {
  final double totalCredits;
  final double totalDebits;
  final int transactionCount;
  final double averageTransaction;
  final String period;

  WalletStats({
    required this.totalCredits,
    required this.totalDebits,
    required this.transactionCount,
    required this.averageTransaction,
    required this.period,
  });

  factory WalletStats.fromJson(Map<String, dynamic> json) {
    return WalletStats(
      totalCredits: double.parse(json['total_credits'].toString()),
      totalDebits: double.parse(json['total_debits'].toString()),
      transactionCount: json['transaction_count'] ?? 0,
      averageTransaction: double.parse(json['average_transaction'].toString()),
      period: json['period'] ?? 'month',
    );
  }

  double get netBalance => totalCredits - totalDebits;
}

/// Modèle pour la réponse de retrait
class WithdrawResponse {
  final bool success;
  final String message;
  final String? reference;
  final String? status;

  WithdrawResponse({
    required this.success,
    required this.message,
    this.reference,
    this.status,
  });

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      reference: json['data']?['reference'],
      status: json['data']?['status'],
    );
  }
}
