import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/reports_repository.dart';

/// Provider pour le repository des rapports
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final repository = ReportsRepository();
  
  // Get token from SharedPreferences asynchronously
  SharedPreferences.getInstance().then((prefs) {
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      repository.setAuthToken(token);
    }
  });
  
  return repository;
});

/// State pour les rapports
class ReportsState {
  final bool isLoading;
  final String? error;
  final String selectedPeriod;
  final Map<String, dynamic>? overview;
  final Map<String, dynamic>? sales;
  final Map<String, dynamic>? orders;
  final Map<String, dynamic>? inventory;
  final Map<String, dynamic>? stockAlerts;

  const ReportsState({
    this.isLoading = false,
    this.error,
    this.selectedPeriod = 'week',
    this.overview,
    this.sales,
    this.orders,
    this.inventory,
    this.stockAlerts,
  });

  ReportsState copyWith({
    bool? isLoading,
    String? error,
    String? selectedPeriod,
    Map<String, dynamic>? overview,
    Map<String, dynamic>? sales,
    Map<String, dynamic>? orders,
    Map<String, dynamic>? inventory,
    Map<String, dynamic>? stockAlerts,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      overview: overview ?? this.overview,
      sales: sales ?? this.sales,
      orders: orders ?? this.orders,
      inventory: inventory ?? this.inventory,
      stockAlerts: stockAlerts ?? this.stockAlerts,
    );
  }
}

/// Notifier pour gérer l'état des rapports
class ReportsNotifier extends StateNotifier<ReportsState> {
  final ReportsRepository _repository;

  ReportsNotifier(this._repository) : super(const ReportsState());

  /// Load all dashboard data
  Future<void> loadDashboard({String? period}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final selectedPeriod = period ?? state.selectedPeriod;
      
      final overview = await _repository.getOverview(period: selectedPeriod);
      
      state = state.copyWith(
        isLoading: false,
        selectedPeriod: selectedPeriod,
        overview: overview,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load sales data
  Future<void> loadSales({String? period}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final selectedPeriod = period ?? state.selectedPeriod;
      final sales = await _repository.getSalesReport(period: selectedPeriod);
      
      state = state.copyWith(
        isLoading: false,
        selectedPeriod: selectedPeriod,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load orders data
  Future<void> loadOrders({String? period}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final selectedPeriod = period ?? state.selectedPeriod;
      final orders = await _repository.getOrdersReport(period: selectedPeriod);
      
      state = state.copyWith(
        isLoading: false,
        selectedPeriod: selectedPeriod,
        orders: orders,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load inventory data
  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final inventory = await _repository.getInventoryReport();
      
      state = state.copyWith(
        isLoading: false,
        inventory: inventory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load stock alerts
  Future<void> loadStockAlerts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final alerts = await _repository.getStockAlerts();
      
      state = state.copyWith(
        isLoading: false,
        stockAlerts: alerts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Change selected period
  void setPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }

  /// Export report
  Future<Map<String, dynamic>?> exportReport({
    required String type,
    String format = 'json',
  }) async {
    try {
      return await _repository.exportReport(
        type: type,
        format: format,
        period: state.selectedPeriod,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

/// Provider principal pour les rapports
final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return ReportsNotifier(repository);
});

/// Provider pour les alertes de stock uniquement
final stockAlertsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getStockAlerts();
});
