import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationEntity', () {
    NotificationEntity createNotification({
      String id = '1',
      String type = 'order_status',
      String title = 'Test Notification',
      String body = 'Test body',
      Map<String, dynamic>? data,
      bool isRead = false,
      DateTime? createdAt,
    }) {
      return NotificationEntity(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: isRead,
        createdAt: createdAt ?? DateTime(2024, 1, 1),
      );
    }

    group('constructor', () {
      test('should create with required parameters', () {
        final notification = createNotification();

        expect(notification.id, '1');
        expect(notification.type, 'order_status');
        expect(notification.title, 'Test Notification');
        expect(notification.body, 'Test body');
        expect(notification.isRead, false);
        expect(notification.createdAt, DateTime(2024, 1, 1));
      });

      test('should create with optional data', () {
        final notification = createNotification(
          data: {'order_id': 123, 'status': 'delivered'},
        );

        expect(notification.data, isNotNull);
        expect(notification.data!['order_id'], 123);
        expect(notification.data!['status'], 'delivered');
      });

      test('should create read notification', () {
        final notification = createNotification(isRead: true);
        expect(notification.isRead, true);
      });

      test('should create unread notification', () {
        final notification = createNotification(isRead: false);
        expect(notification.isRead, false);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final notification1 = NotificationEntity(
          id: '1',
          type: 'order',
          title: 'Title',
          body: 'Body',
          isRead: false,
          createdAt: DateTime(2024, 1, 1),
        );
        final notification2 = NotificationEntity(
          id: '1',
          type: 'order',
          title: 'Title',
          body: 'Body',
          isRead: false,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(notification1, equals(notification2));
      });

      test('should not be equal when id differs', () {
        final notification1 = createNotification(id: '1');
        final notification2 = createNotification(id: '2');

        expect(notification1, isNot(equals(notification2)));
      });

      test('should not be equal when isRead differs', () {
        final notification1 = createNotification(isRead: false);
        final notification2 = createNotification(isRead: true);

        expect(notification1, isNot(equals(notification2)));
      });

      test('should not be equal when type differs', () {
        final notification1 = createNotification(type: 'order');
        final notification2 = createNotification(type: 'promo');

        expect(notification1, isNot(equals(notification2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final notification = createNotification(
          id: 'test-id',
          type: 'promo',
          title: 'Promo Title',
          body: 'Promo Body',
          isRead: true,
          data: {'key': 'value'},
        );

        expect(notification.props.length, equals(7));
        expect(notification.props[0], equals('test-id'));
        expect(notification.props[1], equals('promo'));
        expect(notification.props[2], equals('Promo Title'));
        expect(notification.props[3], equals('Promo Body'));
      });
    });

    group('notification types', () {
      test('should handle order_status type', () {
        final notification = createNotification(type: 'order_status');
        expect(notification.type, 'order_status');
      });

      test('should handle promo type', () {
        final notification = createNotification(type: 'promo');
        expect(notification.type, 'promo');
      });

      test('should handle system type', () {
        final notification = createNotification(type: 'system');
        expect(notification.type, 'system');
      });
    });
  });
}
