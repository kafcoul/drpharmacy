import 'package:equatable/equatable.dart';
import '../../domain/entities/prescription_entity.dart';

enum PrescriptionsStatus { initial, loading, loaded, uploading, uploaded, error, unauthorized }

extension PrescriptionsStatusExtension on PrescriptionsStatus {
  bool get isLoading => this == PrescriptionsStatus.loading;
  bool get isLoaded => this == PrescriptionsStatus.loaded;
  bool get isUploading => this == PrescriptionsStatus.uploading;
  bool get isUploaded => this == PrescriptionsStatus.uploaded;
  bool get isError => this == PrescriptionsStatus.error;
  bool get isUnauthorized => this == PrescriptionsStatus.unauthorized;
}

class PrescriptionsState extends Equatable {
  final PrescriptionsStatus status;
  final List<PrescriptionEntity> prescriptions;
  final PrescriptionEntity? uploadedPrescription;
  final String? errorMessage;

  const PrescriptionsState({
    required this.status,
    required this.prescriptions,
    this.uploadedPrescription,
    this.errorMessage,
  });

  const PrescriptionsState.initial()
      : status = PrescriptionsStatus.initial,
        prescriptions = const [],
        uploadedPrescription = null,
        errorMessage = null;

  PrescriptionsState copyWith({
    PrescriptionsStatus? status,
    List<PrescriptionEntity>? prescriptions,
    PrescriptionEntity? uploadedPrescription,
    String? errorMessage,
  }) {
    return PrescriptionsState(
      status: status ?? this.status,
      prescriptions: prescriptions ?? this.prescriptions,
      uploadedPrescription: uploadedPrescription ?? this.uploadedPrescription,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, prescriptions, uploadedPrescription, errorMessage];
}
