import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  log('[BackgroundService] Service starting...');

  // SharedPreferences'i yeniden yukle (disk'ten taze veri)
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.reload(); // ONEMLI: Disk'ten yeniden oku

  final storageServices = StorageServices(sharedPreferences);
  final cacheService = CacheService(storageServices);

  final languageCode = storageServices.getString('languageCode') ?? 'en';
  final locale = Locale(languageCode);

  AppLocalizations? l10n;
  try {
    l10n = await AppLocalizations.delegate.load(locale);
    log('[BackgroundService] Localization loaded: $languageCode');
  } catch (e) {
    log('[BackgroundService] Localization loading error: $e');
  }

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

  // Cache guncellendiginde tetiklenecek event
  service.on('cacheUpdated').listen((event) async {
    log('[BackgroundService] Cache update event received');

    // SharedPreferences'i yeniden yukle (disk'ten taze veri cek)
    await sharedPreferences.reload();
    log('[BackgroundService] SharedPreferences reloaded from disk');

    // Kisa bir delay - disk yaziminin tam bitmesini garanti et
    await Future.delayed(const Duration(milliseconds: 300));

    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      // Yeni cache ile localization'i yukle
      final currentLanguageCode =
          storageServices.getString('languageCode') ?? 'en';
      AppLocalizations? currentL10n;

      try {
        currentL10n = await AppLocalizations.delegate.load(
          Locale(currentLanguageCode),
        );
      } catch (e) {
        log('[BackgroundService] Localization reload error: $e');
        currentL10n = l10n;
      }

      // YENI CACHE ILE bildirimi guncelle
      final notificationData = _calculateNextPrayer(cacheService, currentL10n);

      // Cache verilerini loglayalim
      final todayTimings = cacheService.getDailyTimings();
      final cachedLocation = cacheService.getCachedLocation();
      log(
        '[BackgroundService] Cached Location: ${cachedLocation?['city']} / ${cachedLocation?['subAdministrativeArea']}',
      );
      log('[BackgroundService] Today Fajr: ${todayTimings?.fajr}');

      service.setForegroundNotificationInfo(
        title: notificationData['title'] as String,
        content: notificationData['content'] as String,
      );

      log(
        '[BackgroundService] Cache updated, notification refreshed: ${notificationData['content']}',
      );
    }
  });

  // ILK YUKLEME - Cache dolana kadar bekle
  log('[BackgroundService] Waiting for initial cache load...');
  await _waitForInitialCache(service, cacheService, l10n, sharedPreferences);

  // Dakikalik guncelleme timer'i
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      // Her dakika disk'ten yeniden oku
      await sharedPreferences.reload();

      final currentLanguageCode =
          storageServices.getString('languageCode') ?? 'en';
      AppLocalizations? currentL10n;

      try {
        currentL10n = await AppLocalizations.delegate.load(
          Locale(currentLanguageCode),
        );
      } catch (e) {
        log('[BackgroundService] Localization reload error: $e');
        currentL10n = l10n;
      }

      final notificationData = _calculateNextPrayer(cacheService, currentL10n);

      service.setForegroundNotificationInfo(
        title: notificationData['title'] as String,
        content: notificationData['content'] as String,
      );

      log(
        '[BackgroundService] Periodic update: ${notificationData['content']}',
      );
    }
  });
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

        service.setForegroundNotificationInfo(
          title: notificationData['title'] as String,
          content: notificationData['content'] as String,
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
    final cachedLocation = cacheService.getCachedLocation();

    log('[BackgroundService] _calculateNextPrayer called');
    log(
      '[BackgroundService]   Location: ${cachedLocation?['city']} / ${cachedLocation?['subAdministrativeArea']}',
    );
    log('[BackgroundService]   Fajr: ${todayTimings?.fajr}');
    log('[BackgroundService]   Dhuhr: ${todayTimings?.dhuhr}');

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
