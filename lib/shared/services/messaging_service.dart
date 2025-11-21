import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Top-level function to handle background messages
/// Must be top-level or static
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');

  // Handle URL in background if needed
  if (message.data.containsKey('url')) {
    log('Background message contains URL: ${message.data['url']}');
  }
}

/// Service for Firebase Cloud Messaging
/// Handles push notifications and URL launching
class MessagingService {
  static MessagingService? _instance;
  static MessagingService get instance => _instance ??= MessagingService._();

  MessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request notification permissions
      await _requestPermissions();

      // Get FCM token
      await _getToken();

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        log('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps (app in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      log('Firebase Messaging initialized successfully');
    } catch (e) {
      log('Error initializing Firebase Messaging: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        log('User granted provisional notification permission');
      } else {
        log('User declined or has not accepted notification permission');
      }
    } catch (e) {
      log('Error requesting permissions: $e');
    }
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      // For iOS, request APNs token first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          log('APNs token not available yet, will retry...');
          // Retry after a delay
          await Future.delayed(const Duration(seconds: 3));
        }
      }

      _fcmToken = await _messaging.getToken();
      log('FCM Token: $_fcmToken');
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    log('Received foreground message: ${message.messageId}');
    log('Notification: ${message.notification?.title}');
    log('Data: ${message.data}');

    // In foreground, you might want to show a custom in-app notification
    // or update UI directly

    // Handle URL if present
    if (message.data.containsKey('url')) {
      log('Foreground message contains URL: ${message.data['url']}');
      // Optionally show a dialog asking user if they want to open the URL
    }
  }

  /// Handle notification tap (when user taps notification)
  void _handleNotificationTap(RemoteMessage message) {
    log('Notification tapped: ${message.messageId}');
    log('Data: ${message.data}');

    // Check if notification contains a URL
    if (message.data.containsKey('url')) {
      final url = message.data['url'] as String;
      log('Opening URL from notification: $url');
      _launchURL(url);
    }
  }

  /// Launch URL in browser
  Future<void> _launchURL(String urlString) async {
    try {
      final url = Uri.parse(urlString);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Open in browser
        );
        log('Successfully launched URL: $urlString');
      } else {
        log('Could not launch URL: $urlString');
      }
    } catch (e) {
      log('Error launching URL: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      log('FCM token deleted');
    } catch (e) {
      log('Error deleting token: $e');
    }
  }
}
