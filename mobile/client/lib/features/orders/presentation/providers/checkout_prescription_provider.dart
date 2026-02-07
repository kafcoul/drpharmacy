import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// État de l'ordonnance pour le checkout
class CheckoutPrescriptionState {
  /// Images de l'ordonnance sélectionnées
  final List<XFile> images;
  
  /// ID de l'ordonnance uploadée (après upload réussi)
  final int? prescriptionId;
  
  /// Notes optionnelles
  final String? notes;
  
  /// Indique si l'upload est en cours
  final bool isUploading;
  
  /// Message d'erreur éventuel
  final String? errorMessage;

  const CheckoutPrescriptionState({
    this.images = const [],
    this.prescriptionId,
    this.notes,
    this.isUploading = false,
    this.errorMessage,
  });

  /// Vérifie si une ordonnance a été uploadée ou sélectionnée
  bool get hasValidPrescription => prescriptionId != null || images.isNotEmpty;

  CheckoutPrescriptionState copyWith({
    List<XFile>? images,
    int? prescriptionId,
    String? notes,
    bool? isUploading,
    String? errorMessage,
    bool clearPrescriptionId = false,
    bool clearError = false,
  }) {
    return CheckoutPrescriptionState(
      images: images ?? this.images,
      prescriptionId: clearPrescriptionId ? null : (prescriptionId ?? this.prescriptionId),
      notes: notes ?? this.notes,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider pour gérer l'ordonnance lors du checkout
class CheckoutPrescriptionNotifier extends StateNotifier<CheckoutPrescriptionState> {
  CheckoutPrescriptionNotifier() : super(const CheckoutPrescriptionState());

  /// Ajoute une image d'ordonnance
  void addImage(XFile image) {
    state = state.copyWith(
      images: [...state.images, image],
      clearError: true,
    );
  }

  /// Ajoute plusieurs images d'ordonnance
  void addImages(List<XFile> images) {
    state = state.copyWith(
      images: [...state.images, ...images],
      clearError: true,
    );
  }

  /// Supprime une image par index
  void removeImage(int index) {
    if (index >= 0 && index < state.images.length) {
      final newImages = List<XFile>.from(state.images)..removeAt(index);
      state = state.copyWith(images: newImages);
    }
  }

  /// Définit les notes
  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  /// Définit l'ID de l'ordonnance (après upload réussi)
  void setPrescriptionId(int id) {
    state = state.copyWith(prescriptionId: id, clearError: true);
  }

  /// Définit l'état d'upload
  void setUploading(bool uploading) {
    state = state.copyWith(isUploading: uploading);
  }

  /// Définit une erreur
  void setError(String error) {
    state = state.copyWith(errorMessage: error, isUploading: false);
  }

  /// Réinitialise l'état
  void reset() {
    state = const CheckoutPrescriptionState();
  }

  /// Efface seulement les images
  void clearImages() {
    state = state.copyWith(images: []);
  }
}

/// Provider global pour l'ordonnance du checkout
final checkoutPrescriptionProvider = StateNotifierProvider<CheckoutPrescriptionNotifier, CheckoutPrescriptionState>(
  (ref) => CheckoutPrescriptionNotifier(),
);
