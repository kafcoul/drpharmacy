import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:drpharma_client/features/notifications/data/models/notification_model.dart';

import 'notifications_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late NotificationsRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = NotificationsRemoteDataSourceImpl(mockApiClient);
  });

  group('NotificationsRemoteDataSourceImpl', () {
    group('getNotifications', () {
      test('should return list of notifications on success', () async {
        // Arrange
        final notificationJson = {
          'id': '1',
          'type': 'order_status',
          'title': 'Test Title',
          'body': 'Test Body',
          'data': {'order_id': 1},
          'is_read': false,
          'created_at': '2024-01-01T00:00:00.000Z',
        };
        
        when(mockApiClient.get('/notifications')).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'notifications': [notificationJson],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications'),
          ),
        );

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isA<List<NotificationModel>>());
        expect(result.length, 1);
        verify(mockApiClient.get('/notifications')).called(1);
      });

      test('should return empty list when no notifications', () async {
        // Arrange
        when(mockApiClient.get('/notifications')).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'notifications': [],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications'),
          ),
        );

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw when API call fails', () async {
        // Arrange
        when(mockApiClient.get('/notifications')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notifications'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getNotifications(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getUnreadNotifications', () {
      test('should return list of unread notifications on success', () async {
        // Arrange
        final notificationJson = {
          'id': '1',
          'type': 'order_status',
          'title': 'Unread Title',
          'body': 'Unread Body',
          'data': <String, dynamic>{},
          'is_read': false,
          'created_at': '2024-01-01T00:00:00.000Z',
        };
        
        when(mockApiClient.get('/notifications/unread')).thenAnswer(
          (_) async => Response(
            data: {
              'data': [notificationJson],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications/unread'),
          ),
        );

        // Act
        final result = await dataSource.getUnreadNotifications();

        // Assert
        expect(result, isA<List<NotificationModel>>());
        expect(result.length, 1);
        verify(mockApiClient.get('/notifications/unread')).called(1);
      });

      test('should return empty list when no unread notifications', () async {
        // Arrange
        when(mockApiClient.get('/notifications/unread')).thenAnswer(
          (_) async => Response(
            data: {
              'data': [],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications/unread'),
          ),
        );

        // Act
        final result = await dataSource.getUnreadNotifications();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('markAsRead', () {
      test('should call correct endpoint', () async {
        // Arrange
        const notificationId = '123';
        when(mockApiClient.post('/notifications/$notificationId/read'))
            .thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/notifications/$notificationId/read',
            ),
          ),
        );

        // Act
        await dataSource.markAsRead(notificationId);

        // Assert
        verify(mockApiClient.post('/notifications/$notificationId/read'))
            .called(1);
      });

      test('should throw when marking as read fails', () async {
        // Arrange
        const notificationId = '123';
        when(mockApiClient.post('/notifications/$notificationId/read'))
            .thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/notifications/$notificationId/read',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/notifications/$notificationId/read',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.markAsRead(notificationId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('markAllAsRead', () {
      test('should call correct endpoint', () async {
        // Arrange
        when(mockApiClient.post('/notifications/read-all')).thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications/read-all'),
          ),
        );

        // Act
        await dataSource.markAllAsRead();

        // Assert
        verify(mockApiClient.post('/notifications/read-all')).called(1);
      });

      test('should throw when marking all as read fails', () async {
        // Arrange
        when(mockApiClient.post('/notifications/read-all')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notifications/read-all'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.markAllAsRead(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('deleteNotification', () {
      test('should call correct endpoint', () async {
        // Arrange
        const notificationId = '456';
        when(mockApiClient.delete('/notifications/$notificationId'))
            .thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/notifications/$notificationId',
            ),
          ),
        );

        // Act
        await dataSource.deleteNotification(notificationId);

        // Assert
        verify(mockApiClient.delete('/notifications/$notificationId'))
            .called(1);
      });

      test('should throw when deleting fails', () async {
        // Arrange
        const notificationId = '456';
        when(mockApiClient.delete('/notifications/$notificationId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/notifications/$notificationId',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(
                path: '/notifications/$notificationId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.deleteNotification(notificationId),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('updateFcmToken', () {
      test('should call correct endpoint with token', () async {
        // Arrange
        const fcmToken = 'test_fcm_token_12345';
        when(mockApiClient.post(
          '/notifications/fcm-token',
          data: {'fcm_token': fcmToken},
        )).thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications/fcm-token'),
          ),
        );

        // Act
        await dataSource.updateFcmToken(fcmToken);

        // Assert
        verify(mockApiClient.post(
          '/notifications/fcm-token',
          data: {'fcm_token': fcmToken},
        )).called(1);
      });

      test('should throw when updating FCM token fails', () async {
        // Arrange
        const fcmToken = 'test_fcm_token';
        when(mockApiClient.post(
          '/notifications/fcm-token',
          data: {'fcm_token': fcmToken},
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notifications/fcm-token'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.updateFcmToken(fcmToken),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('removeFcmToken', () {
      test('should call correct endpoint', () async {
        // Arrange
        when(mockApiClient.delete('/notifications/fcm-token')).thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/notifications/fcm-token'),
          ),
        );

        // Act
        await dataSource.removeFcmToken();

        // Assert
        verify(mockApiClient.delete('/notifications/fcm-token')).called(1);
      });

      test('should throw when removing FCM token fails', () async {
        // Arrange
        when(mockApiClient.delete('/notifications/fcm-token')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notifications/fcm-token'),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/notifications/fcm-token'),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.removeFcmToken(),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
