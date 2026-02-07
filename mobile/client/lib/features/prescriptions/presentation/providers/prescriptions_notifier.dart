import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/usecases/upload_prescription_usecase.dart';
import '../../domain/usecases/get_prescriptions_usecase.dart';
import '../../domain/usecases/get_prescription_details_usecase.dart';
import '../../domain/usecases/pay_prescription_usecase.dart';
import 'prescriptions_state.dart';

/// Notifier pour la gestion des ordonnances (Clean Architecture)
/// Utilise les UseCases au lieu d'accéder directement au DataSource
class PrescriptionsNotifier extends StateNotifier<PrescriptionsState> {
  final UploadPrescriptionUseCase uploadPrescriptionUseCase;
  final GetPrescriptionsUseCase getPrescriptionsUseCase;
  final GetPrescriptionDetailsUseCase getPrescriptionDetailsUseCase;
  final PayPrescriptionUseCase payPrescriptionUseCase;

  PrescriptionsNotifier({
    required this.uploadPrescriptionUseCase,
    required this.getPrescriptionsUseCase,
    required this.getPrescriptionDetailsUseCase,
    required this.payPrescriptionUseCase,
  }) : super(const PrescriptionsState.initial());

  /// Upload une ordonnance
  Future<void> uploadPrescription({
    required List<XFile> images,
    String? notes,
  }) async {
    state = state.copyWith(status: PrescriptionsStatus.uploading);

    final result = await uploadPrescriptionUseCase(
      images: images,
      notes: notes,
    );

    result.fold(
      (failure) {
        String errorMessage = failure.message;
        PrescriptionsStatus status = PrescriptionsStatus.error;
        
        if (failure is UnauthorizedFailure) {
          errorMessage = 'Veuillez vous reconnecter pour envoyer une ordonnance';
          status = PrescriptionsStatus.unauthorized;
        } else if (errorMessage.contains('403') || errorMessage.contains('PHONE_NOT_VERIFIED')) {
          errorMessage = 'Veuillez vérifier votre numéro de téléphone pour envoyer une ordonnance';
        }
        
        state = state.copyWith(
          status: status,
          errorMessage: errorMessage,
        );
      },
      (prescription) {
        state = state.copyWith(
          status: PrescriptionsStatus.uploaded,
          uploadedPrescription: prescription,
          errorMessage: null,
        );
      },
    );
  }

  /// Charge la liste des ordonnances
  Future<void> loadPrescriptions() async {
    state = state.copyWith(status: PrescriptionsStatus.loading);

    final result = await getPrescriptionsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PrescriptionsStatus.error,
          errorMessage: failure.message,
        );
      },
      (prescriptions) {
        state = state.copyWith(
          status: PrescriptionsStatus.loaded,
          prescriptions: prescriptions,
          errorMessage: null,
        );
      },
    );
  }

  /// Récupère les détails d'une ordonnance
  Future<PrescriptionEntity?> getPrescriptionDetails(int prescriptionId) async {
    final result = await getPrescriptionDetailsUseCase(prescriptionId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PrescriptionsStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (prescription) => prescription,
    );
  }

  /// Payer une ordonnance validée
  Future<bool> payPrescription(int prescriptionId, {String method = 'mobile_money'}) async {
    state = state.copyWith(status: PrescriptionsStatus.loading);

    final result = await payPrescriptionUseCase(
      prescriptionId: prescriptionId,
      paymentMethod: method,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PrescriptionsStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        // Update local state
        final updatedList = state.prescriptions.map((p) {
          if (p.id == prescriptionId) {
            return p.copyWith(status: 'paid');
          }
          return p;
        }).toList();

        state = state.copyWith(
          status: PrescriptionsStatus.loaded,
          prescriptions: updatedList,
        );
        return true;
      },
    );
  }

  /// Clear error state
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

