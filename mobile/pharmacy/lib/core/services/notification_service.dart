import 'dart:convert';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(); // Valid only if you init Firebase here too
  debugPrint("Handling a background message: ${message.messageId}");
}

/// Types de notifications supportés
enum NotificationType {
  newOrder,
  orderStatusChange,
  lowStock,
  prescription,
  payment,
  system,
  promotion,
}

/// Configuration des canaux de notification
class NotificationChannels {
  static const String ordersChannel = 'orders_channel';
  static const String stockChannel = 'stock_channel';
  static const String paymentsChannel = 'payments_channel';
  static const String systemChannel = 'system_channel';
  
  static const Map<String, AndroidNotificationChannel> channels = {
    ordersChannel: AndroidNotificationChannel(
      ordersChannel,
      'Commandes',
      description: 'Notifications pour les nouvelles commandes',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      ledColor: ui.Color(0xFF2E7D32),
    ),
    stockChannel: AndroidNotificationChannel(
      stockChannel,
      'Stock',
      description: 'Alertes de stock bas ou rupture',
      importance: Importance.high,
      playSound: true,
    ),
    paymentsChannel: AndroidNotificationChannel(
      paymentsChannel,
      'Paiements',
      description: 'Notifications de paiement',
      importance: Importance.high,
    ),
    systemChannel: AndroidNotificationChannel(
      systemChannel,
      'Système',
      description: 'Notifications système',
      importance: Importance.defaultImportance,
    ),
  };
}

class NotificationService {
  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Callbacks pour la navigation
  Function(Map<String, dynamic> data)? onNotificationTapped;
  Function(RemoteMessage message)? onForegroundMessage;

  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      debugPrint("Firebase not initialized. NotificationService disabled.");
      return;
    }
    
    try {
      _firebaseMessaging = FirebaseMessaging.instance;

      // 1. Request Permission
      final settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      );
      debugPrint('✅ User granted permission: ${settings.authorizationStatus}');

      // 2. Initialize Local Notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // 3. Create notification channels (Android)
      await _createNotificationChannels();

      // 4. Setup Foreground Handling
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 5. Setup Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 6. Handle notification tap when app is terminated/background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // 7. Check for initial message (app launched from notification)
      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
      
      // 8. Get Token
      final token = await getToken();
      debugPrint("✅ FCM Token: $token");
      
    } catch (e) {
      debugPrint("❌ Error initializing NotificationService: $e");
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      for (final channel in NotificationChannels.channels.values) {
        await androidImplementation.createNotificationChannel(channel);
      }
      debugPrint('✅ Notification channels created');
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint("📱 Notification tapped with payload: ${response.payload}");
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        onNotificationTapped?.call(data);
      } catch (e) {
        debugPrint("Error parsing notification payload: $e");
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Got a message whilst in the foreground!');
    debugPrint('📬 Message data: ${message.data}');

    onForegroundMessage?.call(message);

    if (message.notification != null) {
      debugPrint('📬 Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📱 App opened from notification: ${message.data}');
    onNotificationTapped?.call(message.data);
  }

  Future<String?> getToken() async {
    if (_firebaseMessaging == null) return null;
    try {
      return await _firebaseMessaging!.getToken();
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
      return null;
    }
  }

  /// S'abonne à un topic pour les notifications ciblées
  Future<void> subscribeToTopic(String topic) async {
    if (_firebaseMessaging == null) return;
    await _firebaseMessaging!.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  /// Se désabonne d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_firebaseMessaging == null) return;
    await _firebaseMessaging!.unsubscribeFromTopic(topic);
    debugPrint('✅ Unsubscribed from topic: $topic');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      final channelId = _getChannelForMessage(message);
      
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            NotificationChannels.channels[channelId]?.name ?? 'Default',
            channelDescription: NotificationChannels.channels[channelId]?.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
              contentTitle: notification.title,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  String _getChannelForMessage(RemoteMessage message) {
    final type = message.data['type'];
    switch (type) {
      case 'new_order':
      case 'order_status':
        return NotificationChannels.ordersChannel;
      case 'low_stock':
      case 'out_of_stock':
        return NotificationChannels.stockChannel;
      case 'payment':
        return NotificationChannels.paymentsChannel;
      default:
        return NotificationChannels.systemChannel;
    }
  }

  /// Affiche une notification locale personnalisée
  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? channelId,
    Map<String, dynamic>? data,
    NotificationType type = NotificationType.system,
  }) async {
    final channel = channelId ?? NotificationChannels.systemChannel;
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          NotificationChannels.channels[channel]?.name ?? 'Default',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Efface toutes les notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Efface une notification spécifique
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Met à jour le badge de l'application (iOS)
  Future<void> updateBadgeCount(int count) async {
    // Pour iOS, utilisez flutter_app_badger ou similaire
    debugPrint('📛 Badge count updated to: $count');
  }
}
