import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/services/backgroundServices/background_service_handler.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceInitialization {
  static const String _notificationChannelId = 'namaz_vakti_servisi';
  static const String _notificationChannelName = 'Namaz Vakti Servisi';
  static const int _foregroundServiceNotificationId = 888;

  Future<void> initializeBackgroundService() async {
    await _createNotificationChannel();

    final sharedPreferences = await SharedPreferences.getInstance();
    final storageServices = StorageServices(sharedPreferences);
    final languageCode = storageServices.getString('languageCode') ?? 'en';
    final locale = Locale(languageCode);

    AppLocalizations? l10n;
    try {
      l10n = await AppLocalizations.delegate.load(locale);
    } catch (e) {
      log('Localization loading error during service init: $e');
    }

    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        autoStartOnBoot: true, // Telefon yeniden başladığında otomatik başlat
        initialNotificationTitle: l10n?.serviceTitle ?? 'Prayer Time Service',
        initialNotificationContent: l10n?.prayTime ?? 'Loading prayer times...',
        foregroundServiceNotificationId: _foregroundServiceNotificationId,
      ),
    );

    await service.startService();

    // İlk başlangıçta cache varsa kontrol et, yoksa servise bildir
    final cacheService = CacheService(storageServices);
    if (cacheService.getDailyTimings() == null ||
        cacheService.getNextDayTimings() == null) {
      log('[BackgroundService] No initial cache, service will fetch data');
    }
  }

  /// Notification channel oluştur
  Future<void> _createNotificationChannel() async {
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Namaz vakti hatırlatmaları ve sessiz mod için kullanılır',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false, // Badge gösterme
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}
