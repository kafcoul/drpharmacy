import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

/// Repository abstrait pour les notifications
/// La couche Data implémentera cette interface
abstract class NotificationsRepository {
  /// Récupère la liste des notifications de l'utilisateur
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  /// Marque une notification comme lue
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Marque toutes les notifications comme lues
  Future<Either<Failure, void>> markAllAsRead();

  /// Supprime une notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);
}
