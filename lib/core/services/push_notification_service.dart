import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

/// Push Notification Service using Firebase Cloud Messaging (FCM)
class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiService _apiService;
  final StorageService _storageService;

  PushNotificationService(this._apiService, this._storageService);

  Future<void> initialize() async {
    try {
      // Request permission for iOS & Android 13+
      final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('User granted push notification permission');
      }

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground notification: ${message.notification?.title}');
        }
      });

      // Notification opened app listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification clicked: ${message.data}');
        }
      });

      // Get FCM token and register with Laravel backend
      final token = await _fcm.getToken();
      if (token != null) {
        await _storageService.saveFcmToken(token);
        await syncTokenWithBackend(token);
      }

      // Token refresh listener
      _fcm.onTokenRefresh.listen((newToken) async {
        await _storageService.saveFcmToken(newToken);
        await syncTokenWithBackend(newToken);
      });
    } catch (e) {
      if (kDebugMode) print('FCM init error: $e');
    }
  }

  /// Sync device FCM token with Laravel backend API
  Future<void> syncTokenWithBackend(String token) async {
    try {
      await _apiService.post(
        ApiEndpoints.registerFcmToken,
        data: {'fcm_token': token},
      );
    } catch (e) {
      if (kDebugMode) print('Failed to sync FCM token with Laravel: $e');
    }
  }

  /// Subscribe to specific batch or role topics (e.g. batch_2022, role_student)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) print('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      if (kDebugMode) print('Error unsubscribing from topic $topic: $e');
    }
  }
}
