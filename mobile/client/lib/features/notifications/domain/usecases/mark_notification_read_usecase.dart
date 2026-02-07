import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notifications_repository.dart';

/// UseCase pour marquer une notification comme lue
class MarkNotificationAsReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    if (notificationId.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'ID notification invalide',
          errors: {'id': ['ID notification invalide']},
        ),
      );
    }

    return await repository.markAsRead(notificationId);
  }
}
