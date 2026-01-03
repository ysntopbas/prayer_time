import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/init/locator.dart' as di;
import 'package:timezone/timezone.dart' as tz;

class ScheduledNotificationService {
  StorageServices? _storageServices;

  // Lazy getter - GetIt hazır olduğunda alır
  StorageServices get storageServices {
    _storageServices ??= di.sl<StorageServices>();
    return _storageServices!;
  }

  static final ScheduledNotificationService _instance =
      ScheduledNotificationService._internal();

  factory ScheduledNotificationService() => _instance;

  ScheduledNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  String _getChannelIdWithSound(String baseChannelId) {
    final soundFileName =
        storageServices.getString('notificationSound') ?? 'flute';
    return '${baseChannelId}_$soundFileName';
  }

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

    final dynamicChannelId = _getChannelIdWithSound(channelId);

    log(
      '[ScheduledNotification] Channel: $dynamicChannelId, Sound: $soundFileName',
    );

    final androidDetails = AndroidNotificationDetails(
      dynamicChannelId,
      '$channelName ($soundFileName)',
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
      sound: playSound ? '$soundFileName.wav' : null,
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
    try {
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

      final dynamicChannelId = _getChannelIdWithSound(channelId);
      log(
        ' Scheduled notification - ID: $id, Time: $scheduledTime, Channel: $dynamicChannelId',
      );
    } catch (e) {
      log('Scheduled notification error: $e');
      rethrow;
    }
  }

  Future<void> cancelScheduledNotification(int id) async {
    await _plugin.cancel(id);
    log(' Cancelled scheduled notification - ID: $id');
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _plugin.cancelAll();
    log(' All scheduled notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  /// Android notification channel'ı sil
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

  /// Belirli bir base channel ID için tüm ses varyantlarını siler
  Future<void> deleteAllSoundChannelVariants(String baseChannelId) async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return;

    // Bilinen tüm ses dosyaları için channel'ları sil
    final soundFiles = [
      'flute',
      'flute2',
      'bicycle_ring',
      'wolf_howling',
      'clear_tone',
      'fire',
      'flute3',
      'harp',
      'hawk',
      'positive_sound',
      'tick_tock_alarm',
      'tick_tock_alarm2',
      'wolf_pack_howling',
    ];

    for (final sound in soundFiles) {
      final channelId = '${baseChannelId}_$sound';
      try {
        await androidImplementation.deleteNotificationChannel(channelId);
        log(' Deleted channel variant: $channelId');
      } catch (e) {
        // Channel yoksa hata vermez, sessizce devam et
      }
    }
  }
}
