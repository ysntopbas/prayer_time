import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/init/locator.dart' as di;

class InstantNotificationService {
  final StorageServices storageServices;

  static final InstantNotificationService _instance =
      InstantNotificationService._internal(
        storageServices: di.sl<StorageServices>(),
      );

  factory InstantNotificationService() => _instance;

  InstantNotificationService._internal({required this.storageServices});

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    final soundFileName =
        storageServices.getString('notificationSound') ?? 'flute';

    log(' [InstantNotification] Channel: $channelId, Sound: $soundFileName');

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundFileName),
      icon: 'prayer_time_icon_notification',
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: '$soundFileName.wav',
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? channelDescription,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    try {
      await _plugin.show(
        id,
        title,
        body,
        _notificationDetails(
          channelId: channelId,
          channelName: channelName,
          channelDescription: channelDescription,
          importance: importance,
          priority: priority,
        ),
        payload: payload,
      );
      log(' Notification sent successfully - ID: $id, Channel: $channelId');
    } catch (e) {
      log(' Notification error: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    log('Notification cancelled - ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    log('All notifications cancelled');
  }

  // Android notification channel'ı sil
  Future<void> deleteNotificationChannel(String channelId) async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      try {
        await androidImplementation.deleteNotificationChannel(channelId);
        log(' Deleted notification channel: $channelId');
      } catch (e) {
        log(' Error deleting channel: $e');
      }
    }
  }
}
