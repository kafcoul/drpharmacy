import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prescription_model.dart';
import '../../data/repositories/prescription_repository.dart';

enum PrescriptionStatus { initial, loading, loaded, error }

class PrescriptionListState {
  final PrescriptionStatus status;
  final List<PrescriptionModel> prescriptions;
  final String? errorMessage;
  final String activeFilter; // 'all', 'pending', 'validated'

  PrescriptionListState({
    this.status = PrescriptionStatus.initial,
    this.prescriptions = const [],
    this.errorMessage,
    this.activeFilter = 'all',
  });

  PrescriptionListState copyWith({
    PrescriptionStatus? status,
    List<PrescriptionModel>? prescriptions,
    String? errorMessage,
    String? activeFilter,
  }) {
    return PrescriptionListState(
      status: status ?? this.status,
      prescriptions: prescriptions ?? this.prescriptions,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class PrescriptionListNotifier extends StateNotifier<PrescriptionListState> {
  final PrescriptionRepository _repository;

  PrescriptionListNotifier(this._repository) : super(PrescriptionListState()) {
    getPrescriptions();
  }

  Future<void> getPrescriptions() async {
    state = state.copyWith(status: PrescriptionStatus.loading);

    final result = await _repository.getPrescriptions();

    result.fold(
      (failure) => state = state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: failure.message,
      ),
      (prescriptions) => state = state.copyWith(
        status: PrescriptionStatus.loaded,
        prescriptions: prescriptions,
      ),
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }
  
  List<PrescriptionModel> get filteredPrescriptions {
    if (state.activeFilter == 'all') {
      return state.prescriptions;
    }
    return state.prescriptions.where((p) => p.status == state.activeFilter).toList();
  }

  Future<void> updateStatus(int id, String status, {String? notes, double? quoteAmount}) async {
      // Optimistic update or reload
      final result = await _repository.updateStatus(id, status, notes: notes, quoteAmount: quoteAmount);
      
      result.fold(
          (failure) => null, // Handle error toast in UI
          (updated) {
              final newList = state.prescriptions.map((p) => p.id == id ? updated : p).toList();
              state = state.copyWith(prescriptions: newList);
          }
      );
  }

  Future<void> sendQuote(int id, double amount, {String? notes}) async {
    // Re-use updateStatus logic but with specific status
    await updateStatus(id, 'quoted', notes: notes, quoteAmount: amount);
  }
}

final prescriptionListProvider = StateNotifierProvider<PrescriptionListNotifier, PrescriptionListState>((ref) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return PrescriptionListNotifier(repository);
});
