import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prescription_entity.dart';

/// Repository abstrait pour les prescriptions
/// La couche Data implémentera cette interface
abstract class PrescriptionsRepository {
  /// Upload une nouvelle ordonnance
  Future<Either<Failure, PrescriptionEntity>> uploadPrescription({
    required List<XFile> images,
    String? notes,
  });

  /// Récupère la liste des ordonnances de l'utilisateur
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptions();

  /// Récupère les détails d'une ordonnance
  Future<Either<Failure, PrescriptionEntity>> getPrescriptionDetails(int id);

  /// Payer une ordonnance validée par la pharmacie
  Future<Either<Failure, Map<String, dynamic>>> payPrescription({
    required int prescriptionId,
    required String paymentMethod,
  });
}
