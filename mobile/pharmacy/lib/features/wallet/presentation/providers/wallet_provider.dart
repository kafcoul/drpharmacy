import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/models/wallet_data.dart';
import '../../../../core/providers/core_providers.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiClientProvider).dio);
});

/// Provider principal pour les données du portefeuille
final walletProvider = FutureProvider.autoDispose<WalletData>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWalletData();
});

/// Provider pour les paramètres de seuil de retrait
final withdrawalSettingsProvider = FutureProvider<WithdrawalSettings>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWithdrawalSettings();
});

/// Provider pour les statistiques par période
final walletStatsProvider = FutureProvider.autoDispose.family<WalletStats, String>((ref, period) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getStatsByPeriod(period);
});

/// Provider pour la période sélectionnée
final selectedPeriodProvider = StateProvider<String>((ref) => 'month');

/// Provider pour demander un retrait
final withdrawRequestProvider = FutureProvider.autoDispose.family<WithdrawResponse, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.requestWithdrawal(
    amount: params['amount'] as double,
    paymentMethod: params['payment_method'] as String,
    accountDetails: params['account_details'] as String?,
  );
});

/// Notifier pour les actions du wallet
class WalletActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final WalletRepository _repository;
  final Ref _ref;

  WalletActionsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Demander un retrait
  Future<WithdrawResponse> requestWithdrawal({
    required double amount,
    required String paymentMethod,
    String? accountDetails,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.requestWithdrawal(
        amount: amount,
        paymentMethod: paymentMethod,
        accountDetails: accountDetails,
      );
      state = const AsyncValue.data(null);
      // Rafraîchir les données du wallet
      _ref.invalidate(walletProvider);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Enregistrer les informations bancaires
  Future<bool> saveBankInfo({
    required String bankName,
    required String holderName,
    required String accountNumber,
    String? iban,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.saveBankInfo(
        bankName: bankName,
        holderName: holderName,
        accountNumber: accountNumber,
        iban: iban,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Enregistrer les informations Mobile Money
  Future<bool> saveMobileMoneyInfo({
    required String operator,
    required String phoneNumber,
    required String accountName,
    bool isPrimary = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.saveMobileMoneyInfo(
        operator: operator,
        phoneNumber: phoneNumber,
        accountName: accountName,
        isPrimary: isPrimary,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Récupérer les paramètres de retrait
  Future<WithdrawalSettings> getWithdrawalSettings() async {
    return await _repository.getWithdrawalSettings();
  }

  /// Configurer le seuil de retrait
  Future<WithdrawalSettings> setWithdrawalThreshold({
    required double threshold,
    required bool autoWithdraw,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.setWithdrawalThreshold(
        threshold: threshold,
        autoWithdraw: autoWithdraw,
      );
      state = const AsyncValue.data(null);
      // Invalider le cache des paramètres
      _ref.invalidate(withdrawalSettingsProvider);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Exporter les transactions
  Future<String> exportTransactions({
    required String format,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final url = await _repository.exportTransactions(
        format: format,
        startDate: startDate,
        endDate: endDate,
      );
      state = const AsyncValue.data(null);
      return url;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final walletActionsProvider = StateNotifierProvider<WalletActionsNotifier, AsyncValue<void>>((ref) {
  return WalletActionsNotifier(
    ref.watch(walletRepositoryProvider),
    ref,
  );
});
