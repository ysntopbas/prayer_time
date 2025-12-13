import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/notificationServices/scheduled_notification_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class NotificationManagerService {
  final StorageServices _storageServices;
  final ScheduledNotificationService _scheduledNotificationService;
  final CacheService _cacheService;

  NotificationManagerService(
    this._storageServices,
    this._scheduledNotificationService,
    this._cacheService,
  );

  Timings? getTodayTimings() {
    return _cacheService.getDailyTimings();
  }

  NotificationBeforePraysSettings loadAllNotificationSettings() {
    return NotificationBeforePraysSettings(
      fajr: _loadSingleNotificationSetting('fajr_notification'),
      sunrise: _loadSingleNotificationSetting('sunrise_notification'),
      dhuhr: _loadSingleNotificationSetting('dhuhr_notification'),
      asr: _loadSingleNotificationSetting('asr_notification'),
      maghrib: _loadSingleNotificationSetting('maghrib_notification'),
      isha: _loadSingleNotificationSetting('isha_notification'),
    );
  }

  NotificationBeforePrays _loadSingleNotificationSetting(String key) {
    final jsonString = _storageServices.getString(key);
    if (jsonString == null) {
      return const NotificationBeforePrays();
    }
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return NotificationBeforePrays.fromJson(jsonMap);
  }

  Future<void> scheduleAllNotifications() async {
    final baseTimings = getTodayTimings();

    if (baseTimings == null) {
      //Logs Created by COPILOT
      log('[Notifications]  Cache\'de namaz vakti bulunamadı');
      return;
    }

    final isMainEnabled =
        _storageServices.getBool('mainNotificationsEnabled') ?? false;

    if (!isMainEnabled) {
      log(
        '[Notifications]  Ana bildirim switch\'i kapalı, tüm bildirimler iptal ediliyor',
      );
      await cancelAllScheduledNotifications();
      return;
    }

    final userSettings = loadAllNotificationSettings();
    final String langCode = _storageServices.getString('languageCode') ?? 'en';
    final Locale locale = Locale(langCode);
    final l10n = await AppLocalizations.delegate.load(locale);

    // Önce tüm eski bildirimleri iptal et
    await cancelAllScheduledNotifications();
    //Logs Created by COPILOT
    log('[Notifications] 🗑️ Eski bildirimler temizlendi');
    log('[Notifications] ═══════════════════════════════════════');
    log('[Notifications] 📅 YENİ BİLDİRİMLER ZAMANLANIYOR...');
    log('[Notifications] ═══════════════════════════════════════');

    int scheduledCount = 0;

    if (userSettings.fajr.isEnabled && baseTimings.fajr != null) {
      await _schedulePrayerNotification(
        prayerName: l10n.fajr,
        baseTimeStr: baseTimings.fajr!,
        setting: userSettings.fajr,
        notificationId: 101,
        l10n: l10n,
      );
      scheduledCount++;
    }

    if (userSettings.sunrise.isEnabled && baseTimings.sunrise != null) {
      await _schedulePrayerNotification(
        prayerName: l10n.sunrise,
        baseTimeStr: baseTimings.sunrise!,
        setting: userSettings.sunrise,
        notificationId: 102,
        l10n: l10n,
      );
      scheduledCount++;
    }

    if (userSettings.dhuhr.isEnabled && baseTimings.dhuhr != null) {
      await _schedulePrayerNotification(
        prayerName: l10n.dhuhr,
        baseTimeStr: baseTimings.dhuhr!,
        setting: userSettings.dhuhr,
        notificationId: 103,
        l10n: l10n,
      );
      scheduledCount++;
    }

    if (userSettings.asr.isEnabled && baseTimings.asr != null) {
      await _schedulePrayerNotification(
        prayerName: l10n.asr,
        baseTimeStr: baseTimings.asr!,
        setting: userSettings.asr,
        notificationId: 104,
        l10n: l10n,
      );
      scheduledCount++;
    }

    if (userSettings.maghrib.isEnabled && baseTimings.maghrib != null) {
      await _schedulePrayerNotification(
        prayerName: l10n.maghrib,
        baseTimeStr: baseTimings.maghrib!,
        setting: userSettings.maghrib,
        notificationId: 105,
        l10n: l10n,
      );
      scheduledCount++;
    }

    if (userSettings.isha.isEnabled && baseTimings.isha != null) {
      await _schedulePrayerNotification(
        prayerName: l10n.isha,
        baseTimeStr: baseTimings.isha!,
        setting: userSettings.isha,
        notificationId: 106,
        l10n: l10n,
      );
      scheduledCount++;
    }
    //Logs Created by COPILOT
    log('[Notifications] ═══════════════════════════════════════');
    log('[Notifications] ✅ Toplam $scheduledCount bildirim zamanlandı');
    log('[Notifications] ═══════════════════════════════════════');
  }

  Future<void> _schedulePrayerNotification({
    required String prayerName,
    required String baseTimeStr,
    required NotificationBeforePrays setting,
    required int notificationId,
    required AppLocalizations l10n,
  }) async {
    if (!setting.isEnabled) {
      await _scheduledNotificationService.cancelScheduledNotification(
        notificationId,
      );
      log('[Notifications]  $prayerName bildirimi kapalı');
      return;
    }

    final baseTime = _parseTime(baseTimeStr);
    final minutesBefore = setting.minutesBefore;
    final scheduledTime = baseTime.subtract(Duration(minutes: minutesBefore));

    if (scheduledTime.isBefore(DateTime.now())) {
      log('[Notifications]  $prayerName bildirimi geçmiş ($scheduledTime)');
      return;
    }

    await _scheduledNotificationService.showScheduleNotification(
      id: notificationId,
      title: '$prayerName - ${l10n.prayTime}',
      body: '$minutesBefore ${l10n.minutes} ${l10n.leftMinutes}',
      scheduledTime: scheduledTime,
      channelId: 'prayer_notifications',
      channelName: l10n.notificationBeforePrayTime,
      channelDescription: 'Namaz vakti bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'prayer_time_icon_notification',
    );

    final baseTimeFormatted =
        '${baseTime.hour.toString().padLeft(2, '0')}:${baseTime.minute.toString().padLeft(2, '0')}';
    final scheduledTimeFormatted =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';

    log(
      '[Notifications]  $prayerName → Vakit: $baseTimeFormatted | Bildirim: $scheduledTimeFormatted ($minutesBefore dk önce)',
    );
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _scheduledNotificationService.cancelAllScheduledNotifications();
    //Logs Created by COPILOT
    log('[Notifications] 🔕 Tüm zamanlanmış bildirimler iptal edildi');
  }

  DateTime _parseTime(String timeStr) {
    try {
      // "05:30 (EET)" formatından "05:30" çıkar
      final cleanTime = timeStr.split('(').first.trim();
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      log(' Time parse hatası: $e');
      return DateTime.now();
    }
  }
}
