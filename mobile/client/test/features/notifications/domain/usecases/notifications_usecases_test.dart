import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:drpharma_client/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:drpharma_client/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:drpharma_client/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:drpharma_client/features/notifications/domain/entities/notification_entity.dart';

@GenerateMocks([NotificationsRepository])
import 'notifications_usecases_test.mocks.dart';

void main() {
  late MockNotificationsRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationsRepository();
  });

  group('GetNotificationsUseCase', () {
    late GetNotificationsUseCase useCase;

    setUp(() {
      useCase = GetNotificationsUseCase(mockRepository);
    });

    final testNotifications = [
      NotificationEntity(
        id: '1',
        type: 'order_status',
        title: 'Commande confirmée',
        body: 'Votre commande #ORD-001 a été confirmée',
        data: {'order_id': 1},
        isRead: false,
        createdAt: DateTime(2024, 1, 15, 10, 0),
      ),
      NotificationEntity(
        id: '2',
        type: 'promotion',
        title: 'Nouvelle offre',
        body: '20% de réduction sur tous les médicaments',
        data: null,
        isRead: true,
        createdAt: DateTime(2024, 1, 14, 9, 0),
      ),
    ];

    test('should get notifications successfully', () async {
      // Arrange
      when(mockRepository.getNotifications())
          .thenAnswer((_) async => Right(testNotifications));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (notifications) {
          expect(notifications.length, 2);
          expect(notifications[0].id, '1');
          expect(notifications[0].type, 'order_status');
          expect(notifications[0].isRead, isFalse);
          expect(notifications[1].isRead, isTrue);
        },
      );
      verify(mockRepository.getNotifications()).called(1);
    });

    test('should return empty list when no notifications', () async {
      // Arrange
      when(mockRepository.getNotifications())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (notifications) => expect(notifications, isEmpty),
      );
    });

    test('should return failure when not authenticated', () async {
      // Arrange
      when(mockRepository.getNotifications())
          .thenAnswer((_) async => const Left(UnauthorizedFailure()));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when server error', () async {
      // Arrange
      when(mockRepository.getNotifications())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('MarkNotificationAsReadUseCase', () {
    late MarkNotificationAsReadUseCase useCase;

    setUp(() {
      useCase = MarkNotificationAsReadUseCase(mockRepository);
    });

    test('should mark notification as read successfully', () async {
      // Arrange
      when(mockRepository.markAsRead('1'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call('1');

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.markAsRead('1')).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.markAsRead('1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call('1');

      // Assert
      expect(result.isLeft(), isTrue);
    });

    group('Validation', () {
      test('should return validation failure for empty notification id', () async {
        // Act
        final result = await useCase.call('');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['id'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.markAsRead(any));
      });
    });
  });

  group('MarkAllNotificationsReadUseCase', () {
    late MarkAllNotificationsReadUseCase useCase;

    setUp(() {
      useCase = MarkAllNotificationsReadUseCase(mockRepository);
    });

    test('should mark all notifications as read successfully', () async {
      // Arrange
      when(mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.markAllAsRead()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('NotificationEntity', () {
    test('should create entity with required fields', () {
      // Arrange & Act
      final notification = NotificationEntity(
        id: '1',
        type: 'order_status',
        title: 'Commande confirmée',
        body: 'Votre commande a été confirmée',
        isRead: false,
        createdAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(notification.id, '1');
      expect(notification.type, 'order_status');
      expect(notification.title, 'Commande confirmée');
      expect(notification.body, 'Votre commande a été confirmée');
      expect(notification.data, isNull);
      expect(notification.isRead, isFalse);
    });

    test('should create entity with data', () {
      // Arrange & Act
      final notification = NotificationEntity(
        id: '1',
        type: 'order_status',
        title: 'Commande livrée',
        body: 'Votre commande a été livrée',
        data: {'order_id': 123, 'status': 'delivered'},
        isRead: true,
        createdAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(notification.data, isNotNull);
      expect(notification.data!['order_id'], 123);
      expect(notification.data!['status'], 'delivered');
      expect(notification.isRead, isTrue);
    });

    test('should support equality', () {
      // Arrange
      final notification1 = NotificationEntity(
        id: '1',
        type: 'order_status',
        title: 'Test',
        body: 'Test body',
        isRead: false,
        createdAt: DateTime(2024, 1, 15),
      );
      
      final notification2 = NotificationEntity(
        id: '1',
        type: 'order_status',
        title: 'Test',
        body: 'Test body',
        isRead: false,
        createdAt: DateTime(2024, 1, 15),
      );
      
      final notification3 = NotificationEntity(
        id: '2', // Different ID
        type: 'order_status',
        title: 'Test',
        body: 'Test body',
        isRead: false,
        createdAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(notification1, equals(notification2));
      expect(notification1, isNot(equals(notification3)));
    });

    test('should have correct props for equality', () {
      // Arrange
      final notification = NotificationEntity(
        id: '1',
        type: 'order_status',
        title: 'Test',
        body: 'Test body',
        data: {'key': 'value'},
        isRead: false,
        createdAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(notification.props.length, 7);
      expect(notification.props.contains('1'), isTrue);
      expect(notification.props.contains('order_status'), isTrue);
    });
  });
}
