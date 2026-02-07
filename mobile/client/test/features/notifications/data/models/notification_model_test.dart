import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/notifications/data/models/notification_model.dart';
import 'package:drpharma_client/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationModel', () {
    const testJson = {
      'id': 'notif-123',
      'type': 'order_status',
      'data': {
        'title': 'Commande confirmée',
        'message': 'Votre commande #ORD-001 a été confirmée',
        'order_id': 123,
      },
      'read_at': null,
      'created_at': '2024-01-15T10:30:00.000Z',
    };

    const testJsonRead = {
      'id': 'notif-456',
      'type': 'promotion',
      'data': {
        'title': 'Nouvelle offre',
        'message': '20% de réduction sur les vitamines',
      },
      'read_at': '2024-01-16T09:00:00.000Z',
      'created_at': '2024-01-15T08:00:00.000Z',
    };

    group('fromJson', () {
      test('should create model from valid JSON (unread)', () {
        // Act
        final model = NotificationModel.fromJson(testJson);

        // Assert
        expect(model.id, 'notif-123');
        expect(model.type, 'order_status');
        expect(model.data['title'], 'Commande confirmée');
        expect(model.data['order_id'], 123);
        expect(model.readAt, isNull);
        expect(model.createdAt, '2024-01-15T10:30:00.000Z');
      });

      test('should create model from valid JSON (read)', () {
        // Act
        final model = NotificationModel.fromJson(testJsonRead);

        // Assert
        expect(model.id, 'notif-456');
        expect(model.type, 'promotion');
        expect(model.readAt, '2024-01-16T09:00:00.000Z');
      });

      test('should handle different notification types', () {
        final types = ['order_status', 'promotion', 'delivery', 'prescription', 'payment'];
        
        for (final type in types) {
          final json = {...testJson, 'type': type};
          final model = NotificationModel.fromJson(json);
          expect(model.type, type);
        }
      });

      test('should handle empty data object', () {
        final json = {
          'id': 'notif-empty',
          'type': 'system',
          'data': <String, dynamic>{},
          'read_at': null,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);
        expect(model.data, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly (unread)', () {
        // Arrange
        final model = NotificationModel(
          id: 'notif-123',
          type: 'order_status',
          data: {'title': 'Test', 'message': 'Test message'},
          readAt: null,
          createdAt: '2024-01-15T10:30:00.000Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'notif-123');
        expect(json['type'], 'order_status');
        expect(json['data']['title'], 'Test');
        expect(json['read_at'], isNull);
        expect(json['created_at'], '2024-01-15T10:30:00.000Z');
      });

      test('should convert model to JSON correctly (read)', () {
        // Arrange
        final model = NotificationModel(
          id: 'notif-456',
          type: 'promotion',
          data: {'title': 'Promo', 'message': 'New promo'},
          readAt: '2024-01-16T09:00:00.000Z',
          createdAt: '2024-01-15T08:00:00.000Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['read_at'], '2024-01-16T09:00:00.000Z');
      });
    });

    group('toEntity', () {
      test('should convert to entity correctly (unread)', () {
        // Arrange
        final model = NotificationModel.fromJson(testJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<NotificationEntity>());
        expect(entity.id, 'notif-123');
        expect(entity.type, 'order_status');
        expect(entity.title, 'Commande confirmée');
        expect(entity.body, 'Votre commande #ORD-001 a été confirmée');
        expect(entity.isRead, isFalse);
        expect(entity.createdAt.year, 2024);
        expect(entity.createdAt.month, 1);
        expect(entity.createdAt.day, 15);
      });

      test('should convert to entity correctly (read)', () {
        // Arrange
        final model = NotificationModel.fromJson(testJsonRead);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.isRead, isTrue);
        expect(entity.title, 'Nouvelle offre');
      });

      test('should use default title when missing', () {
        // Arrange
        final json = {
          'id': 'notif-default',
          'type': 'system',
          'data': {'message': 'Some message'},
          'read_at': null,
          'created_at': '2024-01-15T10:30:00.000Z',
        };
        final model = NotificationModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.title, 'Notification');
      });

      test('should use empty body when message is missing', () {
        // Arrange
        final json = {
          'id': 'notif-nobody',
          'type': 'system',
          'data': {'title': 'Test'},
          'read_at': null,
          'created_at': '2024-01-15T10:30:00.000Z',
        };
        final model = NotificationModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.body, '');
      });

      test('should preserve data object in entity', () {
        // Arrange
        final model = NotificationModel.fromJson(testJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.data, isNotNull);
        expect(entity.data!['order_id'], 123);
      });
    });

    group('constructor', () {
      test('should create model with required fields', () {
        // Act
        final model = NotificationModel(
          id: 'test-id',
          type: 'test-type',
          data: {},
          createdAt: '2024-01-15T10:00:00.000Z',
        );

        // Assert
        expect(model.id, 'test-id');
        expect(model.type, 'test-type');
        expect(model.readAt, isNull);
      });

      test('should create model with all fields', () {
        // Act
        final model = NotificationModel(
          id: 'test-id',
          type: 'test-type',
          data: {'key': 'value'},
          readAt: '2024-01-16T10:00:00.000Z',
          createdAt: '2024-01-15T10:00:00.000Z',
        );

        // Assert
        expect(model.readAt, isNotNull);
        expect(model.data['key'], 'value');
      });
    });
  });
}
