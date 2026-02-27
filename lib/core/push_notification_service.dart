import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/api_client.dart';
import '../features/notifications/providers/notifications_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init(ProviderContainer container) async {
    try {
      // 1. Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Get the token
        final token = await _messaging.getToken();
        log('FCM Token: $token');

        if (token != null) {
          await syncTokenWithBackend(token);
        }

        // 3. Listen for token refreshes
        _messaging.onTokenRefresh.listen((newToken) {
          log('FCM Token Refreshed: $newToken');
          syncTokenWithBackend(newToken);
        });

        // 4. Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          log('Received foreground message: ${message.notification?.title}');
          
          if (message.notification != null) {
            final localNotif = LocalNotification(
              title: message.notification!.title ?? 'New Alert',
              body: message.notification!.body ?? '',
              timestamp: DateTime.now(),
              issueId: message.data['issueId'],
            );
            
            // Save it to the persistent Hive history
            container.read(notificationsProvider.notifier).addNotification(localNotif);
          }
        });

        // 5. Setup background message handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      log('Failed to initialize push notifications: $e');
    }
  }

  static Future<void> syncTokenWithBackend(String fcmToken) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();
      if (idToken == null) return;

      await ApiClient.instance.dio.post(
        '/api/auth/fcm-token',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {'fcmToken': fcmToken},
      );
      log('Successfully synced FCM token with backend.');
    } catch (e) {
      log('Failed to sync FCM token: $e');
    }
  }
}
