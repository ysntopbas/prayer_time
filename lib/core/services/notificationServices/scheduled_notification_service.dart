import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/init/locator.dart' as di;
import 'package:timezone/timezone.dart' as tz;

class ScheduledNotificationService {
  final StorageServices storageServices;

  static final ScheduledNotificationService _instance =
      ScheduledNotificationService._internal(
        storageServices: di.sl<StorageServices>(),
      );

  factory ScheduledNotificationService() => _instance;

  ScheduledNotificationService._internal({required this.storageServices});

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    bool playSound = true,
    bool enableVibration = true,
  }) {
    final soundFileName =
        storageServices.getString('notificationSound') ?? 'flute';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      playSound: playSound,
      sound: playSound
          ? RawResourceAndroidNotificationSound(soundFileName)
          : null,
      icon: 'prayer_time_icon_notification',
      enableVibration: enableVibration,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      sound: playSound ? 'default' : null,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> showScheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    required String channelName,
    String? channelDescription,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    bool playSound = true,
    bool enableVibration = true,
    DateTimeComponents? matchDateTimeComponents,
    String? icon,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notificationDetails(
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        playSound: playSound,
        enableVibration: enableVibration,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: payload,
    );
  }

  Future<void> cancelScheduledNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
