import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/services/backgroundServices/background_service_handler.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceInitialization {
  static const String _notificationChannelId = 'namaz_vakti_servisi';
  static const String _notificationChannelName = 'Namaz Vakti Servisi';
  static const int _foregroundServiceNotificationId = 888;

  Future<void> initializeBackgroundService() async {
    await _createNotificationChannel();

    // Get localized strings
    final sharedPreferences = await SharedPreferences.getInstance();
    final storageServices = StorageServices(sharedPreferences);
    final languageCode = storageServices.getString('languageCode') ?? 'en';
    final locale = Locale(languageCode);

    AppLocalizations? l10n;
    try {
      l10n = await AppLocalizations.delegate.load(locale);
    } catch (e) {
      // Fallback to default values
    }

    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.specialUse],
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: l10n?.prayTime ?? 'Prayer Time',
        initialNotificationContent: l10n?.prayTimeNotAvailable ?? 'Loading...',
        foregroundServiceNotificationId: _foregroundServiceNotificationId,
        autoStart: true,
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
