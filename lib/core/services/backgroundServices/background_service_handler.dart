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

  log('Background service başlatılıyor...');

  final sharedPreferences = await SharedPreferences.getInstance();
  final storageServices = StorageServices(sharedPreferences);
  final cacheService = CacheService(storageServices);

  final languageCode = storageServices.getString('languageCode') ?? 'en';
  final locale = Locale(languageCode);

  AppLocalizations? l10n;
  try {
    l10n = await AppLocalizations.delegate.load(locale);
    log('Localization yüklendi: $languageCode');
  } catch (e) {
    log('Localization yükleme hatası: $e');
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      log('Foreground service olarak ayarlandı');
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      log('Background service olarak ayarlandı');
    });
  }

  service.on('stopService').listen((event) {
    log('Servis durduruluyor');
    service.stopSelf();
  });

  // İlk güncelleme flag'ini EN BAŞTA tanımla
  bool isFirstUpdateDone = false;
  int checkAttempts = 0;
  const maxAttempts = 60;

  // Cache güncellendiğinde tetiklenecek event
  service.on('cacheUpdated').listen((event) async {
    log('Cache güncelleme eventi alındı, bildirim yenileniyor...');

    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      // Reload localization
      final currentLanguageCode =
          storageServices.getString('languageCode') ?? 'en';
      AppLocalizations? currentL10n;

      try {
        currentL10n = await AppLocalizations.delegate.load(
          Locale(currentLanguageCode),
        );
      } catch (e) {
        log('Localization reload hatası: $e');
        currentL10n = l10n;
      }

      // Yeni cache ile bildirimi güncelle
      final notificationData = _calculateNextPrayer(cacheService, currentL10n);

      service.setForegroundNotificationInfo(
        title: notificationData['title'] as String,
        content: notificationData['content'] as String,
      );

      log(
        'Cache güncelleme sonrası bildirim yenilendi: ${notificationData['content']}',
      );

      // İlk güncelleme flag'ini true yap (eğer false ise)
      isFirstUpdateDone = true;
    }
  });

  // İlk güncellemeyi bekle - cache dolu olana kadar
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    checkAttempts++;

    if (isFirstUpdateDone) {
      timer.cancel();
      return;
    }

    if (checkAttempts > maxAttempts) {
      log('Maksimum deneme sayısına ulaşıldı, timer durduruluyor');
      timer.cancel();
      return;
    }

    final todayTimings = cacheService.getDailyTimings();
    final tomorrowTimings = cacheService.getNextDayTimings();

    log('Cache kontrol ediliyor (deneme $checkAttempts/$maxAttempts)...');
    log('Today timings: ${todayTimings != null ? "VAR" : "YOK"}');
    log('Tomorrow timings: ${tomorrowTimings != null ? "VAR" : "YOK"}');

    if (todayTimings != null && tomorrowTimings != null) {
      log('✓ Cache dolu! İlk notification gösteriliyor');

      if (service is AndroidServiceInstance &&
          await service.isForegroundService()) {
        final notificationData = _calculateNextPrayer(cacheService, l10n);

        service.setForegroundNotificationInfo(
          title: notificationData['title'] as String,
          content: notificationData['content'] as String,
        );

        log('✓ İlk notification gösterildi: ${notificationData['content']}');
        isFirstUpdateDone = true;
        timer.cancel();
      }
    } else {
      log('✗ Cache henüz boş, bekleniyor...');
    }
  });

  // Dakikalık güncelleme timer'ı
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (!isFirstUpdateDone) {
      log('İlk güncelleme henüz yapılmadı, dakikalık güncelleme atlanıyor...');
      return;
    }

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        final currentLanguageCode =
            storageServices.getString('languageCode') ?? 'en';
        AppLocalizations? currentL10n;

        try {
          currentL10n = await AppLocalizations.delegate.load(
            Locale(currentLanguageCode),
          );
        } catch (e) {
          log('Localization reload hatası: $e');
          currentL10n = l10n;
        }

        final notificationData = _calculateNextPrayer(
          cacheService,
          currentL10n,
        );

        service.setForegroundNotificationInfo(
          title: notificationData['title'] as String,
          content: notificationData['content'] as String,
        );

        log(
          'Foreground notification güncellendi: ${notificationData['content']}',
        );
      }
    }
  });
}

Map<String, String> _calculateNextPrayer(
  CacheService cacheService,
  AppLocalizations? l10n,
) {
  try {
    final todayTimings = cacheService.getDailyTimings();
    final tomorrowTimings = cacheService.getNextDayTimings();

    if (todayTimings == null || tomorrowTimings == null) {
      log('⚠ Cache boş, bildirim gösterilemiyor');
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

    // Format: "07:59 left" veya sadece dakika varsa "45 dk kaldı"
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
    log('Hata oluştu: $e');
    return {
      'title': l10n?.prayTime ?? 'Prayer Time',
      'content': 'Error: ${e.toString()}',
    };
  }
}

String _getPrayerIcon(String prayerName, AppLocalizations? l10n) {
  // Prayer name'e göre emoji icon döndür
  if (prayerName == l10n?.fajr || prayerName == 'Fajr') {
    return '🌙'; // Fajr
  } else if (prayerName == l10n?.sunrise || prayerName == 'Sunrise') {
    return '🌅'; // Sunrise
  } else if (prayerName == l10n?.dhuhr || prayerName == 'Dhuhr') {
    return '☀️'; // Dhuhr
  } else if (prayerName == l10n?.asr || prayerName == 'Asr') {
    return '🌤️'; // Asr
  } else if (prayerName == l10n?.maghrib || prayerName == 'Maghrib') {
    return '🌆'; // Maghrib
  } else if (prayerName == l10n?.isha || prayerName == 'Isha') {
    return '🌃'; // Isha
  }
  return '🕌'; // Default mosque icon
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
      log('Time parse error: $e');
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
