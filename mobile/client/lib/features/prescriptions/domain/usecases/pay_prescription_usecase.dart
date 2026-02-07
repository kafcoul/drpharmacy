import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/prescriptions_repository.dart';

/// UseCase pour payer une ordonnance validée
class PayPrescriptionUseCase {
  final PrescriptionsRepository repository;

  PayPrescriptionUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int prescriptionId,
    required String paymentMethod,
  }) async {
    // Validation
    if (prescriptionId <= 0) {
      return Left(
        ValidationFailure(
          message: 'ID ordonnance invalide',
          errors: {'prescriptionId': ['ID ordonnance invalide']},
        ),
      );
    }

    final validMethods = ['mobile_money', 'card', 'on_delivery'];
    if (!validMethods.contains(paymentMethod)) {
      return Left(
        ValidationFailure(
          message: 'Méthode de paiement invalide',
          errors: {'paymentMethod': ['Méthode de paiement invalide']},
        ),
      );
    }

    return await repository.payPrescription(
      prescriptionId: prescriptionId,
      paymentMethod: paymentMethod,
    );
  }
}
