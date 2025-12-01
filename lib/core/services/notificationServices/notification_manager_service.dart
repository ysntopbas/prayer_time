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
      log('Base timings null, bildirimler zamanlanamıyor');
      return;
    }

    final isMainEnabled =
        _storageServices.getBool('mainNotificationsEnabled') ?? false;

    if (!isMainEnabled) {
      log('Ana bildirim switch\'i kapalı, tüm bildirimler iptal ediliyor');
      await cancelAllScheduledNotifications();
      return;
    }

    final userSettings = loadAllNotificationSettings();
    final String langCode = _storageServices.getString('languageCode') ?? 'en';
    final Locale locale = Locale(langCode);
    final l10n = await AppLocalizations.delegate.load(locale);

    // Önce tüm eski bildirimleri iptal et
    await cancelAllScheduledNotifications();
    log(' Eski bildirimler temizlendi');

    log(' Yeni bildirimler zamanlanıyor...');

    await _schedulePrayerNotification(
      prayerName: l10n.fajr,
      baseTimeStr: baseTimings.fajr!,
      setting: userSettings.fajr,
      notificationId: 101,
      l10n: l10n,
    );

    await _schedulePrayerNotification(
      prayerName: l10n.sunrise,
      baseTimeStr: baseTimings.sunrise!,
      setting: userSettings.sunrise,
      notificationId: 102,
      l10n: l10n,
    );

    await _schedulePrayerNotification(
      prayerName: l10n.dhuhr,
      baseTimeStr: baseTimings.dhuhr!,
      setting: userSettings.dhuhr,
      notificationId: 103,
      l10n: l10n,
    );

    await _schedulePrayerNotification(
      prayerName: l10n.asr,
      baseTimeStr: baseTimings.asr!,
      setting: userSettings.asr,
      notificationId: 104,
      l10n: l10n,
    );

    await _schedulePrayerNotification(
      prayerName: l10n.maghrib,
      baseTimeStr: baseTimings.maghrib!,
      setting: userSettings.maghrib,
      notificationId: 105,
      l10n: l10n,
    );

    await _schedulePrayerNotification(
      prayerName: l10n.isha,
      baseTimeStr: baseTimings.isha!,
      setting: userSettings.isha,
      notificationId: 106,
      l10n: l10n,
    );

    log(' Tüm bildirimler başarıyla zamanlandı');
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
      log('$prayerName bildirimi kapalı, iptal edildi');
      return;
    }

    final baseTime = _parseTime(baseTimeStr);
    final minutesBefore = setting.minutesBefore;
    final scheduledTime = baseTime.subtract(Duration(minutes: minutesBefore));

    if (scheduledTime.isBefore(DateTime.now())) {
      log(
        ' $prayerName bildirimi geçmiş bir zaman ($scheduledTime), atlanıyor',
      );
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
    );

    log(
      ' $prayerName bildirimi zamanlandı: $scheduledTime ($minutesBefore dk önce)',
    );
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _scheduledNotificationService.cancelAllScheduledNotifications();
    log('Tüm bildirimler iptal edildi');
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
