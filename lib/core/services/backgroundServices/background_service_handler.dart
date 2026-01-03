import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/services/silentModeServices/silent_mode_manager_service.dart';
import 'package:prayer_time/core/services/dio_client.dart';
import 'package:prayer_time/core/services/notificationServices/scheduled_notification_service.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  log('[BackgroundService] ═══════════════════════════════════════');
  log('[BackgroundService] Service starting at ${DateTime.now()}');
  log('[BackgroundService] ═══════════════════════════════════════');

  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.reload();

  final storageServices = StorageServices(sharedPreferences);
  final cacheService = CacheService(storageServices);
  final silentModeService = SilentModeManagerService(
    storageServices,
    cacheService,
  );

  final languageCode = storageServices.getString('languageCode') ?? 'en';
  final locale = Locale(languageCode);

  AppLocalizations? l10n;
  try {
    l10n = await AppLocalizations.delegate.load(locale);
    log('[BackgroundService] Localization loaded: $languageCode');
  } catch (e) {
    log('[BackgroundService] Localization loading error: $e');
  }

  // Service event listeners
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      log('[BackgroundService] Foreground service activated');
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      log('[BackgroundService] Background service activated');
    });
  }

  service.on('stopService').listen((event) {
    log('[BackgroundService] Service stopping');
    service.stopSelf();
  });

  service.on('cacheUpdated').listen((event) async {
    log('[BackgroundService] Cache update event received');
    await sharedPreferences.reload();
    await _refreshNotification(service, cacheService, storageServices, l10n);
    await silentModeService.checkAndToggleSilentMode();
  });

  // İlk yükleme - Cache dolana kadar bekle
  log('[BackgroundService] Waiting for initial cache load...');
  await _waitForInitialCache(service, cacheService, l10n, sharedPreferences);

  // Servis başladığında scheduled notifications'ı ayarla
  await _rescheduleNotificationsFromService(storageServices, cacheService);

  // Son güncelleme gününü takip et
  int lastUpdateDay = DateTime.now().day;

  // ═══════════════════════════════════════════════════════════
  // ANA TIMER: Dakikalık güncelleme
  // ═══════════════════════════════════════════════════════════
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      await sharedPreferences.reload();

      final now = DateTime.now();

      // ═══════════════════════════════════════════════════════════
      // GECE YARISI KONTROLÜ: Yeni güne geçiş
      // ═══════════════════════════════════════════════════════════
      if (now.day != lastUpdateDay) {
        log('[BackgroundService] ═══════════════════════════════════════');
        log('[BackgroundService] 🌙 YENİ GÜN TESPİT EDİLDİ: ${now.day}');
        log('[BackgroundService] ═══════════════════════════════════════');

        lastUpdateDay = now.day;

        // Yarının vakitlerini bugüne taşı
        await _rotateDailyTimings(cacheService);

        // API'den yarının vakitlerini çek
        await _fetchTomorrowTimings(cacheService, storageServices);

        // Bildirimleri yeniden zamanla
        await _rescheduleNotificationsFromService(
          storageServices,
          cacheService,
        );

        log('[BackgroundService] ✅ Yeni gün güncellemesi tamamlandı');
      }

      // Normal dakikalık güncelleme
      await _refreshNotification(service, cacheService, storageServices, l10n);
      await silentModeService.checkAndToggleSilentMode();
    }
  });
}

/// Yarının vakitlerini bugüne taşı
Future<void> _rotateDailyTimings(CacheService cacheService) async {
  log('[BackgroundService] Yarının vakitleri bugüne taşınıyor...');

  final tomorrowTimings = cacheService.getNextDayTimings();
  if (tomorrowTimings != null) {
    await cacheService.saveDailyTimings(tomorrowTimings);
    log('[BackgroundService] ✓ Vakitler taşındı');
  } else {
    log('[BackgroundService] ⚠ Yarının vakitleri bulunamadı');
  }
}

/// API'den yarının vakitlerini çek
Future<void> _fetchTomorrowTimings(
  CacheService cacheService,
  StorageServices storageServices,
) async {
  log('[BackgroundService] API\'den yarının vakitleri çekiliyor...');

  final cachedLocation = cacheService.getCachedLocation();
  if (cachedLocation == null) {
    log('[BackgroundService] ⚠ Konum bulunamadı, API çağrısı yapılamıyor');
    return;
  }

  try {
    final city = cachedLocation['city'] ?? 'Istanbul';
    final subAdministrativeArea =
        cachedLocation['subAdministrativeArea'] ?? 'Fatih';
    final country = cachedLocation['country'] ?? 'TR';

    final tomorrow = DateTime.now().add(const Duration(days: 1));

    final response = await DioClient.dio.get(
      '/timingsByAddress/${tomorrow.day}-${tomorrow.month}-${tomorrow.year}',
      queryParameters: {
        'address': '$subAdministrativeArea, $city, $country',
        'method': 13,
        'timezonestring': 'Europe/Istanbul',
        'calendarMethod': 'DIYANET',
      },
    );

    if (response.statusCode == 200) {
      final prayerModel = PrayerTimeModel.fromJson(response.data['data']);
      if (prayerModel.timings != null) {
        await cacheService.saveNextDayTimings(prayerModel.timings!);
        log('[BackgroundService] ✓ Yarının vakitleri kaydedildi');
        log('[BackgroundService]   Fajr: ${prayerModel.timings?.fajr}');
      }
    }
  } catch (e) {
    log('[BackgroundService] ❌ API hatası: $e');
  }
}

/// Servis içinden scheduled notifications'ı yeniden ayarla
Future<void> _rescheduleNotificationsFromService(
  StorageServices storageServices,
  CacheService cacheService,
) async {
  log('[BackgroundService] Scheduled notifications yeniden ayarlanıyor...');

  final isMainEnabled =
      storageServices.getBool('mainNotificationsEnabled') ?? false;
  if (!isMainEnabled) {
    log('[BackgroundService] Ana bildirim switch\'i kapalı');
    return;
  }

  final timings = cacheService.getDailyTimings();
  if (timings == null) {
    log('[BackgroundService] Cache\'de vakit bulunamadı');
    return;
  }

  final scheduledService = ScheduledNotificationService();
  final langCode = storageServices.getString('languageCode') ?? 'en';
  final l10n = await AppLocalizations.delegate.load(Locale(langCode));

  // Tüm eski bildirimleri iptal et
  await scheduledService.cancelAllScheduledNotifications();

  // Her namaz için bildirim ayarla
  final prayers = [
    {'key': 'fajr', 'name': l10n.fajr, 'time': timings.fajr, 'id': 101},
    {
      'key': 'sunrise',
      'name': l10n.sunrise,
      'time': timings.sunrise,
      'id': 102,
    },
    {'key': 'dhuhr', 'name': l10n.dhuhr, 'time': timings.dhuhr, 'id': 103},
    {'key': 'asr', 'name': l10n.asr, 'time': timings.asr, 'id': 104},
    {
      'key': 'maghrib',
      'name': l10n.maghrib,
      'time': timings.maghrib,
      'id': 105,
    },
    {'key': 'isha', 'name': l10n.isha, 'time': timings.isha, 'id': 106},
  ];

  int scheduledCount = 0;

  for (final prayer in prayers) {
    final settingJson = storageServices.getString(
      '${prayer['key']}_notification',
    );
    if (settingJson == null) continue;

    try {
      final setting = jsonDecode(settingJson) as Map<String, dynamic>;
      final isEnabled = setting['isEnabled'] as bool? ?? false;
      final minutesBefore = setting['minutesBefore'] as int? ?? 10;

      if (!isEnabled) continue;

      final timeStr = prayer['time'] as String?;
      if (timeStr == null) continue;

      final scheduledTime = _parseTime(
        timeStr,
      ).subtract(Duration(minutes: minutesBefore));

      if (scheduledTime.isBefore(DateTime.now())) {
        log('[BackgroundService] ${prayer['name']} geçmiş, atlanıyor');
        continue;
      }

      await scheduledService.showScheduleNotification(
        id: prayer['id'] as int,
        title: '${prayer['name']} - ${l10n.prayTime}',
        body: '$minutesBefore ${l10n.minutes} ${l10n.leftMinutes}',
        scheduledTime: scheduledTime,
        channelId: 'prayer_notifications',
        channelName: l10n.notificationBeforePrayTime,
      );

      scheduledCount++;
      log(
        '[BackgroundService] ✓ ${prayer['name']} zamanlandı: ${_formatTime(scheduledTime)}',
      );
    } catch (e) {
      log('[BackgroundService] ${prayer['key']} hata: $e');
    }
  }

  log('[BackgroundService] ═══════════════════════════════════════');
  log('[BackgroundService] ✅ $scheduledCount bildirim zamanlandı');
  log('[BackgroundService] ═══════════════════════════════════════');
}

DateTime _parseTime(String timeStr) {
  final cleanTime = timeStr.split('(').first.trim();
  final parts = cleanTime.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// Foreground notification'ı güncelle
Future<void> _refreshNotification(
  ServiceInstance service,
  CacheService cacheService,
  StorageServices storageServices,
  AppLocalizations? l10n,
) async {
  if (service is AndroidServiceInstance &&
      await service.isForegroundService()) {
    final notificationData = _calculateNextPrayer(cacheService, l10n);

    await _updateForegroundNotification(
      notificationData['title'] as String,
      notificationData['content'] as String,
    );
  }
}

// Ongoing foreground notification gonder
Future<void> _updateForegroundNotification(String title, String content) async {
  const int notificationId = 888;
  const String channelId = 'namaz_vakti_servisi';

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channelId,
    'Namaz Vakti Servisi',
    channelDescription:
        'Namaz vakti hatırlatmaları ve sessiz mod için kullanılır',
    importance: Importance.low,
    priority: Priority.low,
    ongoing: true, // BU EN ONEMLI: Bildirimi silinemez yap
    autoCancel: false, // Tıklandığında otomatik silinmesin
    playSound: false,
    enableVibration: false,
    showWhen: false,
    icon: 'prayer_time_icon_notification', // Kendi icon'unuz varsa
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await notificationsPlugin.show(
    notificationId,
    title,
    content,
    notificationDetails,
  );
}

// Ilk cache yuklemesini bekleyen fonksiyon
Future<void> _waitForInitialCache(
  ServiceInstance service,
  CacheService cacheService,
  AppLocalizations? l10n,
  SharedPreferences sharedPreferences,
) async {
  int attempts = 0;
  const maxAttempts = 60; // 5 dakika (5 saniyede bir kontrol)

  while (attempts < maxAttempts) {
    // Her kontrol oncesi disk'ten yeniden oku
    await sharedPreferences.reload();
    await Future.delayed(const Duration(milliseconds: 200));

    final todayTimings = cacheService.getDailyTimings();
    final tomorrowTimings = cacheService.getNextDayTimings();
    final cachedLocation = cacheService.getCachedLocation();

    log(
      '[BackgroundService] Cache check (attempt ${attempts + 1}/$maxAttempts)',
    );
    log(
      '[BackgroundService]   Today: ${todayTimings != null ? "Available" : "Not available"}',
    );
    log(
      '[BackgroundService]   Tomorrow: ${tomorrowTimings != null ? "Available" : "Not available"}',
    );
    log(
      '[BackgroundService]   Location: ${cachedLocation?['city'] ?? "Not available"}',
    );

    if (todayTimings != null && tomorrowTimings != null) {
      log('[BackgroundService] Cache ready! Showing initial notification');

      if (service is AndroidServiceInstance &&
          await service.isForegroundService()) {
        final notificationData = _calculateNextPrayer(cacheService, l10n);

        // Ongoing bildirim gonder
        await _updateForegroundNotification(
          notificationData['title'] as String,
          notificationData['content'] as String,
        );

        log(
          '[BackgroundService] Initial notification displayed: ${notificationData['content']}',
        );
      }
      return;
    }

    attempts++;
    await Future.delayed(const Duration(seconds: 5));
  }

  log('[BackgroundService] Cache could not be loaded, max attempts reached');
}

Map<String, String> _calculateNextPrayer(
  CacheService cacheService,
  AppLocalizations? l10n,
) {
  try {
    final todayTimings = cacheService.getDailyTimings();
    final tomorrowTimings = cacheService.getNextDayTimings();
    // final cachedLocation = cacheService.getCachedLocation();

    log('[BackgroundService] _calculateNextPrayer called');
    // log(
    //   '[BackgroundService]   Location: ${cachedLocation?['city']} / ${cachedLocation?['subAdministrativeArea']}',
    // );
    // log('[BackgroundService]   Fajr: ${todayTimings?.fajr}');
    // log('[BackgroundService]   Dhuhr: ${todayTimings?.dhuhr}');

    if (todayTimings == null || tomorrowTimings == null) {
      log('[BackgroundService] Cache is empty, cannot display notification');
      return {
        'title': l10n?.prayTime ?? 'Prayer Time',
        'content': l10n?.prayTimeNotAvailable ?? 'Loading prayer times...',
      };
    }

    final now = DateTime.now();
    final nextPrayerInfo = _getNextPrayerInfo(
      todayTimings,
      tomorrowTimings,
      now,
      l10n,
    );

    if (nextPrayerInfo == null) {
      return {
        'title': l10n?.prayTime ?? 'Prayer Time',
        'content': l10n?.prayTimeNotAvailable ?? 'No prayer times available',
      };
    }

    final remainingTime = nextPrayerInfo['remainingTime'] as Duration;
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    final prayerName = nextPrayerInfo['name'] as String;
    final prayerIcon = _getPrayerIcon(prayerName, l10n);

    String timeFormat;
    if (hours > 0) {
      timeFormat =
          '$hours:${minutes.toString().padLeft(2, '0')} ${l10n?.leftMinutes ?? 'left'}';
    } else {
      timeFormat =
          '$minutes ${l10n?.minutes ?? 'min'} ${l10n?.leftMinutes ?? 'left'}';
    }

    return {
      'title': '${l10n?.nextPrayer ?? 'Next Prayer'}: $prayerName',
      'content': '$prayerIcon $timeFormat',
    };
  } catch (e) {
    log('[BackgroundService] Error occurred: $e');
    return {
      'title': l10n?.prayTime ?? 'Prayer Time',
      'content': 'Error: ${e.toString()}',
    };
  }
}

String _getPrayerIcon(String prayerName, AppLocalizations? l10n) {
  if (prayerName == l10n?.fajr || prayerName == 'Fajr') {
    return '🌙';
  } else if (prayerName == l10n?.sunrise || prayerName == 'Sunrise') {
    return '🌅';
  } else if (prayerName == l10n?.dhuhr || prayerName == 'Dhuhr') {
    return '☀️';
  } else if (prayerName == l10n?.asr || prayerName == 'Asr') {
    return '🌤️';
  } else if (prayerName == l10n?.maghrib || prayerName == 'Maghrib') {
    return '🌆';
  } else if (prayerName == l10n?.isha || prayerName == 'Isha') {
    return '🌃';
  }
  return '🕌';
}

Map<String, dynamic>? _getNextPrayerInfo(
  Timings todayTimings,
  Timings tomorrowTimings,
  DateTime now,
  AppLocalizations? l10n,
) {
  DateTime? parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final cleanTime = timeStr.split('(').first.trim();
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      log('[BackgroundService] Time parse error: $e');
    }
    return null;
  }

  final prayers = [
    {
      'name': l10n?.fajr ?? 'Fajr',
      'time': todayTimings.fajr,
      'isTomorrow': false,
    },
    {
      'name': l10n?.sunrise ?? 'Sunrise',
      'time': todayTimings.sunrise,
      'isTomorrow': false,
    },
    {
      'name': l10n?.dhuhr ?? 'Dhuhr',
      'time': todayTimings.dhuhr,
      'isTomorrow': false,
    },
    {'name': l10n?.asr ?? 'Asr', 'time': todayTimings.asr, 'isTomorrow': false},
    {
      'name': l10n?.maghrib ?? 'Maghrib',
      'time': todayTimings.maghrib,
      'isTomorrow': false,
    },
    {
      'name': l10n?.isha ?? 'Isha',
      'time': todayTimings.isha,
      'isTomorrow': false,
    },
    {
      'name': l10n?.fajr ?? 'Fajr',
      'time': tomorrowTimings.fajr,
      'isTomorrow': true,
    },
  ];

  for (var prayer in prayers) {
    final prayerTime = parseTime(prayer['time'] as String?);
    if (prayerTime != null) {
      DateTime targetTime = prayerTime;
      if (prayer['isTomorrow'] == true) {
        targetTime = targetTime.add(const Duration(days: 1));
      }

      if (now.isBefore(targetTime)) {
        final remaining = targetTime.difference(now);
        return {
          'remainingTime': remaining,
          'name': prayer['name'],
          'time': prayer['time'],
        };
      }
    }
  }

  return null;
}
