import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class InstantNotificationService {
  static final InstantNotificationService _instance =
      InstantNotificationService._internal();

  factory InstantNotificationService() => _instance;

  InstantNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
    );

    const iosDetails = DarwinNotificationDetails();

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
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
