import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationInitializationService {
  static final NotificationInitializationService _instance =
      NotificationInitializationService._internal();

  factory NotificationInitializationService() => _instance;

  NotificationInitializationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init({
    String? androidIcon,
    String? timeZone,
    void Function(NotificationResponse)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    if (timeZone != null) {
      tz.setLocalLocation(tz.getLocation(timeZone));
    }

    final androidSettings = AndroidInitializationSettings(
      androidIcon ?? 'prayer_time_icon_notification',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }
}
