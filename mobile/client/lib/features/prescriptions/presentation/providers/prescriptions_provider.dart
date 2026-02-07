import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import '../../data/datasources/prescriptions_remote_datasource.dart';
import '../../data/repositories/prescriptions_repository_impl.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import '../../domain/usecases/upload_prescription_usecase.dart';
import '../../domain/usecases/get_prescriptions_usecase.dart';
import '../../domain/usecases/get_prescription_details_usecase.dart';
import '../../domain/usecases/pay_prescription_usecase.dart';
import 'prescriptions_notifier.dart';
import 'prescriptions_state.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// DataSource provider
final prescriptionsRemoteDataSourceProvider =
    Provider<PrescriptionsRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return PrescriptionsRemoteDataSourceImpl(apiClient);
    });

/// Repository provider (implémente l'interface du Domain)
final prescriptionsRepositoryProvider = Provider<PrescriptionsRepository>((ref) {
  final remoteDataSource = ref.watch(prescriptionsRemoteDataSourceProvider);
  return PrescriptionsRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

final uploadPrescriptionUseCaseProvider = Provider<UploadPrescriptionUseCase>((ref) {
  final repository = ref.watch(prescriptionsRepositoryProvider);
  return UploadPrescriptionUseCase(repository);
});

final getPrescriptionsUseCaseProvider = Provider<GetPrescriptionsUseCase>((ref) {
  final repository = ref.watch(prescriptionsRepositoryProvider);
  return GetPrescriptionsUseCase(repository);
});

final getPrescriptionDetailsUseCaseProvider = Provider<GetPrescriptionDetailsUseCase>((ref) {
  final repository = ref.watch(prescriptionsRepositoryProvider);
  return GetPrescriptionDetailsUseCase(repository);
});

final payPrescriptionUseCaseProvider = Provider<PayPrescriptionUseCase>((ref) {
  final repository = ref.watch(prescriptionsRepositoryProvider);
  return PayPrescriptionUseCase(repository);
});

// ============================================================================
// PRESENTATION LAYER PROVIDER
// ============================================================================

/// Provider principal pour les prescriptions
final prescriptionsProvider =
    StateNotifierProvider<PrescriptionsNotifier, PrescriptionsState>((ref) {
      return PrescriptionsNotifier(
        uploadPrescriptionUseCase: ref.watch(uploadPrescriptionUseCaseProvider),
        getPrescriptionsUseCase: ref.watch(getPrescriptionsUseCaseProvider),
        getPrescriptionDetailsUseCase: ref.watch(getPrescriptionDetailsUseCaseProvider),
        payPrescriptionUseCase: ref.watch(payPrescriptionUseCaseProvider),
      );
    });

