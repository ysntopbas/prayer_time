import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class SilentModeManagerService {
  final StorageServices _storageServices;
  final CacheService _cacheService;

  SilentModeManagerService(this._storageServices, this._cacheService);

  Future<void> checkAndToggleSilentMode() async {
    try {
      final isMainSilentEnabled =
          _storageServices.getBool('mainSilentModeEnabled') ?? false;

      if (!isMainSilentEnabled) {
        log('[SilentMode] Ana sessiz mod kapalı, kontrol atlanıyor');
        return;
      }

      // Cache'den namaz vakitlerini al
      final todayTimings = _cacheService.getDailyTimings();
      final tomorrowTimings = _cacheService.getNextDayTimings();

      if (todayTimings == null) {
        log('[SilentMode] Cache\'de namaz vakti bulunamadı');
        return;
      }

      final settings = _loadAllSilentModeSettings();
      final now = DateTime.now();

      final silentModeInfo = _shouldBeSilent(
        now,
        todayTimings,
        tomorrowTimings,
        settings,
      );

      if (silentModeInfo['shouldBeSilent'] == true) {
        final prayerName = silentModeInfo['prayerName'] as String;
        final startTime = silentModeInfo['startTime'] as DateTime;
        final endTime = silentModeInfo['endTime'] as DateTime;

        await _setSilentMode();
        //Logs Created by COPILOT
        log('[SilentMode] ═══════════════════════════════════════');
        log('[SilentMode] 🔇 SESSİZ MOD AKTİF');
        log('[SilentMode] 📿 Vakit: $prayerName');
        log('[SilentMode] ⏰ Başlangıç: ${_formatTime(startTime)}');
        log('[SilentMode] ⏱️ Bitiş: ${_formatTime(endTime)}');
        log('[SilentMode] ⏳ Kalan: ${_getRemainingTime(now, endTime)}');
        log('[SilentMode] ═══════════════════════════════════════');
      } else {
        // Sessiz mod kapatılmalı mı kontrol et
        final wasInSilentPeriod = await _wasRecentlyInSilentPeriod(
          now,
          todayTimings,
          settings,
        );

        if (wasInSilentPeriod) {
          await _setNormalMode();
          //Logs Created by COPILOT
          log('[SilentMode] ═══════════════════════════════════════');
          log('[SilentMode] 🔊 SESSİZ MOD KAPANDI');
          log('[SilentMode] ✅ Normal mod aktif');
          log('[SilentMode] ⏰ Zaman: ${_formatTime(now)}');
          log('[SilentMode] ═══════════════════════════════════════');
        }
      }
    } catch (e) {
      //Logs Created by COPILOT
      log('[SilentMode] ⚠️ Hata: $e');
    }
  }

  // Zaman formatlama
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Kalan süreyi hesapla
  String _getRemainingTime(DateTime now, DateTime endTime) {
    final difference = endTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours saat $minutes dakika';
    } else {
      return '$minutes dakika';
    }
  }

  /// Sessiz mod aktif olmalı mı kontrol eder
  Map<String, dynamic> _shouldBeSilent(
    DateTime now,
    Timings todayTimings,
    Timings? tomorrowTimings,
    SilentModeDuringPraysSettings settings,
  ) {
    // Tüm namaz vakitlerini kontrol et
    final prayers = [
      {
        'name': 'Fajr',
        'time': todayTimings.fajr,
        'setting': settings.fajr,
        'isTomorrow': false,
      },
      {
        'name': 'Sunrise',
        'time': todayTimings.sunrise,
        'setting': settings.sunrise,
        'isTomorrow': false,
      },
      {
        'name': 'Dhuhr',
        'time': todayTimings.dhuhr,
        'setting': settings.dhuhr,
        'isTomorrow': false,
      },
      {
        'name': 'Asr',
        'time': todayTimings.asr,
        'setting': settings.asr,
        'isTomorrow': false,
      },
      {
        'name': 'Maghrib',
        'time': todayTimings.maghrib,
        'setting': settings.maghrib,
        'isTomorrow': false,
      },
      {
        'name': 'Isha',
        'time': todayTimings.isha,
        'setting': settings.isha,
        'isTomorrow': false,
      },
    ];

    // Yarının İmsak namazını da ekle (gece yarısından sonra için)
    if (tomorrowTimings != null && tomorrowTimings.fajr != null) {
      prayers.add({
        'name': 'Fajr',
        'time': tomorrowTimings.fajr,
        'setting': settings.fajr,
        'isTomorrow': true,
      });
    }

    for (final prayer in prayers) {
      final timeStr = prayer['time'] as String?;
      final setting = prayer['setting'] as SilentModeDuringPrays;
      final isTomorrow = prayer['isTomorrow'] as bool;

      // Eğer bu namaz için sessiz mod kapalıysa atla
      if (!setting.isEnabled || timeStr == null) continue;

      // Namaz vaktini parse et
      final prayerTime = _parseTime(timeStr, now, isTomorrow: isTomorrow);
      if (prayerTime == null) continue;

      // Sessiz mod başlangıç ve bitiş zamanlarını hesapla
      final silentStartTime = prayerTime.subtract(
        Duration(minutes: setting.minutesBefore),
      );
      final silentEndTime = prayerTime.add(
        Duration(minutes: setting.minutesAfter),
      );

      // Şu an sessiz mod periyodunda mıyız?
      if (now.isAfter(silentStartTime) && now.isBefore(silentEndTime)) {
        return {
          'shouldBeSilent': true,
          'prayerName': prayer['name'],
          'startTime': silentStartTime,
          'endTime': silentEndTime,
        };
      }
    }

    return {'shouldBeSilent': false};
  }

  Future<bool> _wasRecentlyInSilentPeriod(
    DateTime now,
    Timings todayTimings,
    SilentModeDuringPraysSettings settings,
  ) async {
    try {
      // Mevcut ringer mode'u kontrol et
      final currentMode = await SoundMode.ringerModeStatus;

      // Zaten normal moddaysa, işlem yapma
      if (currentMode == RingerModeStatus.normal) {
        return false;
      }

      // Son 10 dakika içinde bir sessiz mod periyodu bittiyse true dön
      final prayers = [
        {'time': todayTimings.fajr, 'setting': settings.fajr},
        {'time': todayTimings.sunrise, 'setting': settings.sunrise},
        {'time': todayTimings.dhuhr, 'setting': settings.dhuhr},
        {'time': todayTimings.asr, 'setting': settings.asr},
        {'time': todayTimings.maghrib, 'setting': settings.maghrib},
        {'time': todayTimings.isha, 'setting': settings.isha},
      ];

      for (final prayer in prayers) {
        final timeStr = prayer['time'] as String?;
        final setting = prayer['setting'] as SilentModeDuringPrays;

        if (!setting.isEnabled || timeStr == null) continue;

        final prayerTime = _parseTime(timeStr, now);
        if (prayerTime == null) continue;

        final silentEndTime = prayerTime.add(
          Duration(minutes: setting.minutesAfter),
        );

        // Sessiz mod periyodu son 10 dakika içinde bittiyse
        final timeSinceEnd = now.difference(silentEndTime);
        if (timeSinceEnd.inSeconds >= 0 && timeSinceEnd.inMinutes < 10) {
          return true;
        }
      }

      return false;
    } catch (e) {
      log('[SilentMode] Error checking recent silent period: $e');
      return false;
    }
  }

  SilentModeDuringPraysSettings _loadAllSilentModeSettings() {
    return SilentModeDuringPraysSettings(
      fajr: _loadSingleSilentModeSetting('fajr_silent'),
      sunrise: _loadSingleSilentModeSetting('sunrise_silent'),
      dhuhr: _loadSingleSilentModeSetting('dhuhr_silent'),
      asr: _loadSingleSilentModeSetting('asr_silent'),
      maghrib: _loadSingleSilentModeSetting('maghrib_silent'),
      isha: _loadSingleSilentModeSetting('isha_silent'),
    );
  }

  SilentModeDuringPrays _loadSingleSilentModeSetting(String key) {
    final jsonString = _storageServices.getString(key);
    if (jsonString == null) {
      return const SilentModeDuringPrays();
    }
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return SilentModeDuringPrays.fromJson(jsonMap);
    } catch (e) {
      log('[SilentMode] Error loading setting for $key: $e');
      return const SilentModeDuringPrays();
    }
  }

  DateTime? _parseTime(
    String timeStr,
    DateTime referenceDate, {
    bool isTomorrow = false,
  }) {
    try {
      final cleanTime = timeStr.split('(').first.trim();
      final parts = cleanTime.split(':');

      if (parts.length < 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      var date = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        hour,
        minute,
      );

      // Yarının vakti ise 1 gün ekle
      if (isTomorrow) {
        date = date.add(const Duration(days: 1));
      }

      return date;
    } catch (e) {
      log('[SilentMode] Error parsing time "$timeStr": $e');
      return null;
    }
  }

  /// Telefonu sessiz moda al
  ///Logs Created by COPILOT

  Future<void> _setSilentMode() async {
    try {
      await SoundMode.setSoundMode(RingerModeStatus.silent);
      log('[SilentMode] 📵 Telefon sessiz moda alındı');
    } on PlatformException catch (e) {
      log('[SilentMode] ⚠️ İzin gerekli: $e');
      // await _openDoNotDisturbSettings();
    } catch (e) {
      log('[SilentMode] ⚠️ Sessiz mod hatası: $e');
    }
  }

  /// Telefonu normal moda al
  /// Logs Created by COPILOT
  Future<void> _setNormalMode() async {
    try {
      await SoundMode.setSoundMode(RingerModeStatus.normal);
      log('[SilentMode] 🔔 Telefon normal moda alındı');
    } on PlatformException catch (e) {
      log('[SilentMode] ⚠️ İzin gerekli: $e');
    } catch (e) {
      log('[SilentMode] ⚠️ Normal mod hatası: $e');
    }
  }

  /// Telefonu titreşim moduna al
  // Future<void> _setVibrateMode() async {
  //   try {
  //     await SoundMode.setSoundMode(RingerModeStatus.vibrate);
  //     log('[SilentMode] Vibrate Mode Activated');
  //   } on PlatformException catch (e) {
  //     log('[SilentMode] Permission needed to activate Vibrate Mode: $e');
  //   } catch (e) {
  //     log('[SilentMode] Error activating vibrate mode: $e');
  //   }
  // }

  /// Do Not Disturb ayarlarını aç
  /// Logs Created by COPILOT
  // Future<void> _openDoNotDisturbSettings() async {
  //   try {
  //     await PermissionHandler.openDoNotDisturbSetting();
  //     log('[SilentMode] Opened Do Not Disturb Settings');
  //   } catch (e) {
  //     log('[SilentMode] Error opening DND settings: $e');
  //   }
  // }

  /// Sessiz mod iznini kontrol et
  /// Logs Created by COPILOT
  Future<bool> checkPermission() async {
    try {
      return await PermissionHandler.permissionsGranted ?? false;
    } catch (e) {
      log('[SilentMode] Error checking permission: $e');
      return false;
    }
  }

  /// Sessiz mod iznini iste
  /// Logs Created by COPILOT
  // Future<void> requestPermission() async {
  //   try {
  //     await _openDoNotDisturbSettings();
  //   } catch (e) {
  //     log('[SilentMode] Error requesting permission: $e');
  //   }
  // }
}
