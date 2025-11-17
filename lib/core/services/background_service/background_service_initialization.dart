import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/services/background_service/background_service_handler.dart';

class BackgroundServiceInitialization {
  static const String _notificationChannelId = 'namaz_vakti_servisi';
  static const String _notificationChannelName = 'Namaz Vakti Servisi';
  static const String _initialNotificationTitle = 'Namaz Vakti Servisi';
  static const String _initialNotificationContent = 'Servis başlatılıyor...';
  static const int _foregroundServiceNotificationId = 888;

  Future<void> initializeBackgroundService() async {
    //  Önce notification channel'ı oluştur bunu oluşturmazsak build kısmında sürekli hata veriyor UNUTMA!!
    await _createNotificationChannel();

    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: _initialNotificationTitle,
        initialNotificationContent: _initialNotificationContent,
        foregroundServiceNotificationId: _foregroundServiceNotificationId,
      ),
    );

    await service.startService();
  }

  /// Notification channel oluştur
  Future<void> _createNotificationChannel() async {
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Namaz vakti hatırlatmaları ve sessiz mod için kullanılır',
      importance: Importance.low, // Foreground service için LOW yeterli
      playSound: false,
      enableVibration: false,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}
