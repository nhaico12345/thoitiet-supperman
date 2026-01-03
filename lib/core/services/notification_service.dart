// Quản lý thông báo local
// Gửi thông báo tức thì, thông báo định kỳ hàng ngày và xử lý click.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../router/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    // Get and log FCM token
    await _getFCMToken();

    // ===== FCM SETUP =====
    // 1. Yêu cầu quyền thông báo
    await _requestFCMPermission();

    // 2. Đăng ký topics
    await _subscribeToTopics();

    // 3. Listen for foreground messages
    _setupFCMListeners();

    // 4. Click handlers
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleNotificationClick(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // 5. Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Nhận được tin nhắn khi ứng dụng đang ở foreground!');
        print('Data tin nhắn: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Tin nhắn chứa thông báo: ${message.notification}');
        }
        showInstantNotification(
          title: message.notification?.title ?? 'Cảnh báo thời tiết',
          body: message.notification?.body ?? 'Có thông tin mới',
        );
      }
    });
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      print(
        "Notification clicked: ${response.payload}, actionId: ${response.actionId}",
      );
    }

    if (response.actionId == 'view_details') {
      _navigateToHome();
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    try {
      appRouter.go('/');
    } catch (e) {
      if (kDebugMode) print("Nav error from notification: $e");
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'weather_alerts',
      'Cảnh báo thời tiết',
      description: 'Thông báo về các cảnh báo thời tiết quan trọng',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'weather_alerts',
          'Cảnh báo thời tiết',
          channelDescription: 'Thông báo về các cảnh báo thời tiết quan trọng',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> showRichNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'weather_alerts',
          'Cảnh báo thời tiết',
          channelDescription: 'Thông báo về các cảnh báo thời tiết quan trọng',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(''),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'view_details',
              'Xem chi tiết',
              showsUserInterface: true,
            ),
          ],
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification',
          'Thông báo hàng ngày',
          channelDescription: 'Thông báo thời tiết sáng và tối',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print("========================================");
        print("FCM TOKEN: $token");
        print("========================================");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
      }
    }
  }

  /// Yêu cầu quyền thông báo từ người dùng (Android 13+, iOS)
  Future<void> _requestFCMPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

    if (kDebugMode) {
      print('FCM Permission status: ${settings.authorizationStatus}');
    }
  }

  /// Đăng ký topic để nhận thông báo hàng loạt
  Future<void> _subscribeToTopics() async {
    await FirebaseMessaging.instance.subscribeToTopic('weather_alerts');
    if (kDebugMode) {
      print('Subscribed to topic: weather_alerts');
    }
  }

  /// Xử lý khi người dùng click vào thông báo
  void _handleNotificationClick(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification clicked! Data: ${message.data}');
    }

    final type = message.data['type'];
    if (type == 'weather_alert') {
      appRouter.go('/alerts');
    } else {
      appRouter.go('/');
    }
  }

  /// Xử lý khi FCM token được refresh
  void _onTokenRefresh(String newToken) {
    if (kDebugMode) {
      print('FCM Token refreshed: $newToken');
    }
  }

  /// Lấy FCM token hiện tại (public method)
  Future<String?> getCurrentFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // ===== FCM TOPIC MANAGEMENT =====

  /// Đăng ký topic cảnh báo nguy hiểm
  Future<void> subscribeToAlerts() async {
    await FirebaseMessaging.instance.subscribeToTopic('weather_alerts');
    if (kDebugMode) {
      print('Subscribed to topic: weather_alerts');
    }
  }

  /// Hủy đăng ký topic cảnh báo nguy hiểm
  Future<void> unsubscribeFromAlerts() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('weather_alerts');
    if (kDebugMode) {
      print('Unsubscribed from topic: weather_alerts');
    }
  }

  /// Đăng ký topic thông báo sáng
  Future<void> subscribeToMorningBrief() async {
    await FirebaseMessaging.instance.subscribeToTopic('morning_brief');
    if (kDebugMode) {
      print('Subscribed to topic: morning_brief');
    }
  }

  /// Hủy đăng ký topic thông báo sáng
  Future<void> unsubscribeFromMorningBrief() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('morning_brief');
    if (kDebugMode) {
      print('Unsubscribed from topic: morning_brief');
    }
  }

  /// Đăng ký topic thông báo tối
  Future<void> subscribeToEveningForecast() async {
    await FirebaseMessaging.instance.subscribeToTopic('evening_forecast');
    if (kDebugMode) {
      print('Subscribed to topic: evening_forecast');
    }
  }

  /// Hủy đăng ký topic thông báo tối
  Future<void> unsubscribeFromEveningForecast() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('evening_forecast');
    if (kDebugMode) {
      print('Unsubscribed from topic: evening_forecast');
    }
  }
}
