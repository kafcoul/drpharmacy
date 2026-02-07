import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/notifications/presentation/providers/notifications_state.dart';
import 'package:drpharma_client/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationsState', () {
    final testDate = DateTime(2024, 1, 1);

    NotificationEntity createNotification({
      String id = '1',
      String type = 'order_status',
      String title = 'Test Notification',
      String body = 'Test body',
      bool isRead = false,
    }) {
      return NotificationEntity(
        id: id,
        type: type,
        title: title,
        body: body,
        isRead: isRead,
        createdAt: testDate,
      );
    }

    group('construction', () {
      test('should create with required fields', () {
        final notifications = [createNotification()];
        final state = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: notifications,
          unreadCount: 1,
        );

        expect(state.status, equals(NotificationsStatus.loaded));
        expect(state.notifications, equals(notifications));
        expect(state.unreadCount, equals(1));
        expect(state.errorMessage, isNull);
      });

      test('should create with all fields', () {
        final notifications = [createNotification()];
        final state = NotificationsState(
          status: NotificationsStatus.error,
          notifications: notifications,
          unreadCount: 0,
          errorMessage: 'Failed to load',
        );

        expect(state.errorMessage, equals('Failed to load'));
      });
    });

    group('initial constructor', () {
      test('should set initial state correctly', () {
        const state = NotificationsState.initial();

        expect(state.status, equals(NotificationsStatus.initial));
        expect(state.notifications, isEmpty);
        expect(state.unreadCount, equals(0));
        expect(state.errorMessage, isNull);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: [createNotification()],
          unreadCount: 5,
        );

        final copy = original.copyWith();

        expect(copy.status, equals(original.status));
        expect(copy.notifications, equals(original.notifications));
        expect(copy.unreadCount, equals(original.unreadCount));
      });

      test('should copy with new status', () {
        const original = NotificationsState.initial();

        final copy = original.copyWith(status: NotificationsStatus.loading);

        expect(copy.status, equals(NotificationsStatus.loading));
      });

      test('should copy with new notifications', () {
        const original = NotificationsState.initial();
        final newNotifications = [
          createNotification(id: '1'),
          createNotification(id: '2'),
        ];

        final copy = original.copyWith(notifications: newNotifications);

        expect(copy.notifications.length, equals(2));
      });

      test('should copy with new unreadCount', () {
        const original = NotificationsState.initial();

        final copy = original.copyWith(unreadCount: 10);

        expect(copy.unreadCount, equals(10));
      });

      test('should copy with new errorMessage', () {
        const original = NotificationsState.initial();

        final copy = original.copyWith(errorMessage: 'Network error');

        expect(copy.errorMessage, equals('Network error'));
      });

      test('should clear errorMessage when copying', () {
        final original = NotificationsState(
          status: NotificationsStatus.error,
          notifications: const [],
          unreadCount: 0,
          errorMessage: 'Old error',
        );

        final copy = original.copyWith(
          status: NotificationsStatus.loaded,
        );

        expect(copy.errorMessage, isNull);
      });
    });

    group('equality', () {
      test('two states with same props should be equal', () {
        final notifications = [createNotification()];
        final state1 = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: notifications,
          unreadCount: 1,
        );
        final state2 = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: notifications,
          unreadCount: 1,
        );

        expect(state1, equals(state2));
      });

      test('two states with different statuses should not be equal', () {
        const state1 = NotificationsState(
          status: NotificationsStatus.loading,
          notifications: [],
          unreadCount: 0,
        );
        const state2 = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: [],
          unreadCount: 0,
        );

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different unreadCount should not be equal', () {
        const state1 = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: [],
          unreadCount: 5,
        );
        const state2 = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: [],
          unreadCount: 10,
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('props', () {
      test('should include all properties', () {
        final notifications = [createNotification()];
        final state = NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: notifications,
          unreadCount: 3,
          errorMessage: 'test',
        );

        expect(state.props.length, equals(4));
        expect(state.props[0], equals(NotificationsStatus.loaded));
        expect(state.props[1], equals(notifications));
        expect(state.props[2], equals(3));
        expect(state.props[3], equals('test'));
      });
    });
  });

  group('NotificationsStatus', () {
    test('should have all expected values', () {
      expect(NotificationsStatus.values, contains(NotificationsStatus.initial));
      expect(NotificationsStatus.values, contains(NotificationsStatus.loading));
      expect(NotificationsStatus.values, contains(NotificationsStatus.loaded));
      expect(NotificationsStatus.values, contains(NotificationsStatus.error));
    });

    test('should have 4 values', () {
      expect(NotificationsStatus.values.length, equals(4));
    });
  });
}
