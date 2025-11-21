import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
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
    //Debug logs for timings
    log(
      'Scheduling notifications with base timings fajr: ${baseTimings?.fajr}',
    );
    log(
      'Scheduling notifications with base timings sunrise: ${baseTimings?.sunrise}',
    );
    log(
      'Scheduling notifications with base timings dhuhr: ${baseTimings?.dhuhr}',
    );
    log('Scheduling notifications with base timings asr: ${baseTimings?.asr}');
    log(
      'Scheduling notifications with base timings maghrib: ${baseTimings?.maghrib}',
    );
    log(
      'Scheduling notifications with base timings isha: ${baseTimings?.isha}',
    );
    final userSettings = loadAllNotificationSettings();
    final String langCode = _storageServices.getString('languageCode') ?? 'en';
    final Locale locale = Locale(langCode);

    if (baseTimings == null) {
      return;
    }

    final isMainEnabled =
        _storageServices.getBool('mainNotificationsEnabled') ?? false;
    if (!isMainEnabled) {
      _scheduledNotificationService.cancelAllScheduledNotifications();
      return;
    }

    final l10n = await AppLocalizations.delegate.load(locale);

    planPrayer(l10n.fajr, baseTimings.fajr!, userSettings.fajr, l10n);
    log(
      'planPrayer LOG Scheduling notification for Fajr at ${l10n.fajr}, ${baseTimings.fajr!},${userSettings.fajr}',
    );
    planPrayer(l10n.sunrise, baseTimings.sunrise!, userSettings.sunrise, l10n);
    planPrayer(l10n.dhuhr, baseTimings.dhuhr!, userSettings.dhuhr, l10n);
    planPrayer(l10n.asr, baseTimings.asr!, userSettings.asr, l10n);
    planPrayer(l10n.maghrib, baseTimings.maghrib!, userSettings.maghrib, l10n);
    planPrayer(l10n.isha, baseTimings.isha!, userSettings.isha, l10n);
  }

  void planPrayer(
    String prayerName,
    String baseTimeStr,
    NotificationBeforePrays setting,
    AppLocalizations l10n,
  ) {
    if (!setting.isEnabled) {
      return;
    }

    final baseTime = _parseTime(baseTimeStr);
    final offset = setting.minutesBefore;

    final scheduledTime = baseTime.subtract(Duration(minutes: offset));

    if (scheduledTime.isAfter(DateTime.now())) {
      _scheduledNotificationService.showScheduleNotification(
        id: 2,
        title: '$prayerName - ${l10n.prayTime}',
        body: '$offset ${l10n.leftMinutes}',
        scheduledTime: scheduledTime,
        channelId: 'scheduled_prayer_reminders',
        channelName: 'Scheduled Prayer Reminders',
      );
    }
  }

  DateTime _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }
}
