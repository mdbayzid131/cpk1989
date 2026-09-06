import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'closete_updates';
  static const String channelName = 'Closeté Updates';
  static const String channelDescription =
      'Notifications regarding orders, item authentication, and seller details';

  bool _isInitialized = false;

  /// Initialize Firebase Push Notifications and Foreground Channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 2. Request User Permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('User notification permission status: ${settings.authorizationStatus}');
      }

      // 3. Initialize Local Notifications for Foreground Channel
      await _setupLocalNotifications();

      // 4. Register FCM Token with Backend API
      await registerDeviceToken();

      // 5. Token Refresh Listener
      _fcm.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken);
      });

      // 6. Handle Messages in Foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      // 7. Handle Background/Terminated Notification Tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message.data);
      });

      // Check initial message if launched from terminated state
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage.data);
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('PushNotificationService initialization error: $e');
      }
    }
  }

  /// Setup Android Notification Channel and Local Plugin Settings
  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          // Payload parsing if needed
        }
      },
    );

    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Register current FCM Token with Backend Server: POST /notifications/devices
  Future<void> registerDeviceToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          if (kDebugMode) {
            print(
              'APNS token is not set yet (likely running on iOS Simulator). Skipping FCM token registration.',
            );
          }
          return;
        }
      }

      String? token = await _fcm.getToken();
      if (kDebugMode) {
        print('\n==================== 🔥 FCM TOKEN 🔥 ====================');
        print('FCM TOKEN: $token');
        print('=======================================================\n');
      }
      if (token != null && token.isNotEmpty) {
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get FCM registration token: $e');
      }
    }
  }

  /// Send FCM token and device info to Backend
  Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      final authToken = await StorageService.getString(StorageConstants.bearerToken);
      if (authToken.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ PushNotificationService: User not logged in yet, skipping backend device registration.');
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_installation_id');
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = const Uuid().v4();
        await prefs.setString('device_installation_id', deviceId);
      }

      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'web';

      NotificationRepository repo;
      if (Get.isRegistered<NotificationRepository>()) {
        repo = Get.find<NotificationRepository>();
      } else if (Get.isRegistered<ApiClient>()) {
        repo = NotificationRepository(apiClient: Get.find<ApiClient>());
      } else {
        final apiClient = Get.put(ApiClient(), permanent: true);
        repo = NotificationRepository(apiClient: apiClient);
      }

      final response = await repo.registerDevice(
        registrationToken: fcmToken,
        platform: platform,
        deviceId: deviceId,
      );
      if (kDebugMode) {
        print('FCM Token registration API status: ${response.statusCode}');
        print('FCM Token successfully registered with backend server ($platform).');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering FCM token with backend: $e');
      }
    }
  }

  /// Unregister device token during Logout: DELETE /notifications/devices
  Future<void> unregisterDeviceToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        NotificationRepository repo;
        if (Get.isRegistered<NotificationRepository>()) {
          repo = Get.find<NotificationRepository>();
        } else if (Get.isRegistered<ApiClient>()) {
          repo = NotificationRepository(apiClient: Get.find<ApiClient>());
        } else {
          final apiClient = Get.put(ApiClient(), permanent: true);
          repo = NotificationRepository(apiClient: apiClient);
        }
        await repo.unregisterDevice(registrationToken: token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering FCM device token: $e');
      }
    }
  }

  /// Display Foreground Push Notification using Flutter Local Notifications
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Closeté Notification',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  /// Handle Notification Click Navigation based on `data.screen`
  void _handleNotificationClick(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final String? screen = data['screen'];
    final String? orderId = data['orderId'];
    final String? productId = data['productId'];

    switch (screen) {
      case 'order_details':
        if (orderId != null && orderId.isNotEmpty) {
          Get.toNamed(AppRoutes.myPurchaseDetails, arguments: {'orderId': orderId});
        } else {
          Get.toNamed(AppRoutes.bottomNavBar);
        }
        break;
      case 'product_details':
        if (productId != null && productId.isNotEmpty) {
          Get.toNamed(AppRoutes.itemDetail, arguments: productId);
        }
        break;
      case 'wishlist':
        Get.toNamed(AppRoutes.bottomNavBar);
        break;
      case 'seller_onboarding':
        Get.toNamed(AppRoutes.sellerProfile);
        break;
      default:
        Get.toNamed(AppRoutes.notification);
        break;
    }
  }
}
