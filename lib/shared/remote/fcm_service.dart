import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dio_helper.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  /// Get the current FCM token
  static String? get fcmToken => _fcmToken;

  /// Initialize FCM and request permissions
  static Future<void> init() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM: Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        await _getToken();

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM: Token refreshed');
          _fcmToken = newToken;
          // You can send the new token to the server here if user is logged in
        });
      }
    } catch (e) {
      debugPrint('FCM: Error initializing: $e');
    }
  }

  /// Get FCM token
  static Future<String?> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM: Token obtained: ${_fcmToken?.substring(0, 20)}...');
      return _fcmToken;
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
      return null;
    }
  }

  /// Get fresh FCM token (force refresh)
  static Future<String?> getFreshToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      return _fcmToken;
    } catch (e) {
      debugPrint('FCM: Error getting fresh token: $e');
      return null;
    }
  }

  /// Send FCM token to server
  static Future<bool> sendTokenToServer() async {
    if (_fcmToken == null) {
      await _getToken();
    }

    if (_fcmToken == null) {
      debugPrint('FCM: No token available to send');
      return false;
    }

    try {
      final response = await DioHelper.putData(
        url: 'driver/fcm-token',
        data: {
          'fcm_token': _fcmToken,
        },
      );

      debugPrint('FCM: Token sent to server successfully');
      debugPrint('FCM: Server response: ${response.data}');
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('FCM: Error sending token to server: $e');
      return false;
    }
  }

  /// Delete FCM token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM: Token deleted');
    } catch (e) {
      debugPrint('FCM: Error deleting token: $e');
    }
  }
}
