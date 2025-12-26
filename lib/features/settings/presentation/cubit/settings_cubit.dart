import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/services/battery_optimization_service.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/features/settings/extensions/settings_cubit_extension.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/services/notificationServices/notification_manager_service.dart';
import 'package:sound_mode/permission_handler.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageServices storageServices;
  final LocationService locationService;
  final BatteryOptimizationService batteryOptimizationService;
  final NotificationManagerService notificationManagerService;
  final String deviceLanguageCode =
      PlatformDispatcher.instance.locale.languageCode;

  SettingsCubit(
    this.storageServices,
    this.locationService,
    this.batteryOptimizationService,
    this.notificationManagerService,
  ) : super(
        SettingsState(
          isDarkMode: false,
          languageCode: PlatformDispatcher.instance.locale.languageCode,
        ),
      ) {
    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    final isDarkMode = storageServices.getBool('isDarkMode') ?? false;
    final languageCode =
        storageServices.getString('languageCode') ?? deviceLanguageCode;

    final cacheService = CacheService(storageServices);
    final cachedLocation = cacheService.getCachedLocation();

    String? cityName = storageServices.getString('cityName');
    String? countryName = storageServices.getString('countryName');
    String? subAdministrativeArea = storageServices.getString(
      'subAdministrativeArea',
    );

    if (cityName == null &&
        cachedLocation != null &&
        cachedLocation.isNotEmpty) {
      cityName = cachedLocation['city'];
      countryName = cachedLocation['country'];
      subAdministrativeArea = cachedLocation['subAdministrativeArea'];

      storageServices.saveString('cityName', cityName ?? '');
      storageServices.saveString('countryName', countryName ?? '');
      storageServices.saveString(
        'subAdministrativeArea',
        subAdministrativeArea ?? '',
      );
    }

    final mainNotificationsEnabled =
        storageServices.getBool('mainNotificationsEnabled') ?? false;
    final mainSilentModeEnabled =
        storageServices.getBool('mainSilentModeEnabled') ?? false;
    final notificationSettings = _loadNotificationSettings();
    final silentModeSettings = _loadSilentModeSettings();
    final notificationSound =
        storageServices.getString('notificationSound') ?? "flute";

    emit(
      SettingsState(
        isDarkMode: isDarkMode,
        languageCode: languageCode,
        cityName: cityName,
        countryName: countryName,
        subAdministrativeArea: subAdministrativeArea,
        mainNotificationsEnabled: mainNotificationsEnabled,
        mainSilentModeEnabled: mainSilentModeEnabled,
        notificationBeforePraysSettings: notificationSettings,
        silentModeDuringPraysSettings: silentModeSettings,
        notificationSound: notificationSound,
      ),
    );
  }

  NotificationBeforePraysSettings _loadNotificationSettings() {
    return NotificationBeforePraysSettings(
      fajr: storageServices.loadSingleNotificationSetting('fajr_notification'),
      sunrise: storageServices.loadSingleNotificationSetting(
        'sunrise_notification',
      ),
      dhuhr: storageServices.loadSingleNotificationSetting(
        'dhuhr_notification',
      ),
      asr: storageServices.loadSingleNotificationSetting('asr_notification'),
      maghrib: storageServices.loadSingleNotificationSetting(
        'maghrib_notification',
      ),
      isha: storageServices.loadSingleNotificationSetting('isha_notification'),
    );
  }

  SilentModeDuringPraysSettings _loadSilentModeSettings() {
    return SilentModeDuringPraysSettings(
      fajr: storageServices.loadSingleSilentModeSetting('fajr_silent'),
      sunrise: storageServices.loadSingleSilentModeSetting('sunrise_silent'),
      dhuhr: storageServices.loadSingleSilentModeSetting('dhuhr_silent'),
      asr: storageServices.loadSingleSilentModeSetting('asr_silent'),
      maghrib: storageServices.loadSingleSilentModeSetting('maghrib_silent'),
      isha: storageServices.loadSingleSilentModeSetting('isha_silent'),
    );
  }

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
    storageServices.saveBool('isDarkMode', state.isDarkMode);
  }

  void changeLanguage(String languageCode) {
    emit(state.copyWith(languageCode: languageCode));
    storageServices.saveString('languageCode', languageCode);

    notificationManagerService.scheduleAllNotifications();
  }

  void changeNotificationSound(String notificationSound) {
    emit(state.copyWith(notificationSound: notificationSound));
    storageServices.saveString('notificationSound', notificationSound);
  }

  Future<bool> shouldShowBatteryDialog() async {
    return !batteryOptimizationService.hasShownBatteryDialog();
  }

  Future<void> markBatteryDialogShown() async {
    await batteryOptimizationService.markBatteryDialogAsShown();
  }

  Future<void> requestBatteryPermission() async {
    await batteryOptimizationService.requestBatteryOptimizationPermission();
  }

  void mainToggleNotifications() async {
    final newValue = !state.mainNotificationsEnabled;

    emit(state.copyWith(mainNotificationsEnabled: newValue));

    storageServices.saveBool('mainNotificationsEnabled', newValue);

    if (newValue) {
      log('[Notifications]  ANA BİLDİRİM AÇILDI');
      await _enableAllNotificationsWithDefaults();
      log(
        '[Notifications]  Tüm bildirimler varsayılan ayarlarla aktif edildi (10 dk önce)',
      );
    } else {
      log('[Notifications]  ANA BİLDİRİM KAPATILDI');
      _disableAllNotifications();
      await notificationManagerService.cancelAllScheduledNotifications();
      log('[Notifications]  Tüm bildirimler iptal edildi');
    }

    if (newValue) {
      await notificationManagerService.scheduleAllNotifications();
      _logAllNotificationSettings();
    }
  }

  void mainToggleSilentMode() async {
    final newValue = !state.mainSilentModeEnabled;

    if (newValue) {
      final permissionStatus = await PermissionHandler.permissionsGranted;

      if (permissionStatus != true) {
        emit(
          state.copyWith(
            mainSilentModeEnabled: false,
            needsPermissionDialog: true,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(mainSilentModeEnabled: newValue));
    storageServices.saveBool('mainSilentModeEnabled', newValue);

    if (newValue) {
      log('[SilentMode]  ANA SESSİZ MOD AÇILDI');
      _logAllSilentModeSettings();
    } else {
      log('[SilentMode]  ANA SESSİZ MOD KAPATILDI');
      _disableAllSilentModes();
      log('[SilentMode] Tüm sessiz mod ayarları devre dışı bırakıldı');
    }
  }

  // İzin dialog'u gösterildikten sonra çağrılacak
  void clearPermissionDialogFlag() {
    emit(state.copyWith(needsPermissionDialog: false));
  }

  // İzin verildikten sonra sessiz modu açmak için
  Future<void> enableSilentModeAfterPermission() async {
    emit(state.copyWith(mainSilentModeEnabled: true));
    await storageServices.saveBool('mainSilentModeEnabled', true);

    log('[SilentMode]  ANA SESSİZ MOD AÇILDI (İzin verildikten sonra)');
    _logAllSilentModeSettings();
  }

  Future<void> _enableAllNotificationsWithDefaults() async {
    for (final prayer in PrayerType.values) {
      await updateNotificationSetting(
        prayerType: prayer,
        isEnabled: true,
        minutesBefore: 10,
      );
    }
  }

  //  Tüm bildirim ayarlarını logla (CREATED BY COPILOT)
  void _logAllNotificationSettings() {
    log('[Notifications] ═══════════════════════════════════════');
    log('[Notifications]  AKTİF BİLDİRİM AYARLARI:');
    log('[Notifications] ═══════════════════════════════════════');

    final settings = state.notificationBeforePraysSettings;
    int activeCount = 0;

    if (settings.fajr.isEnabled) {
      activeCount++;
      log('[Notifications]  İmsak: ${settings.fajr.minutesBefore} dakika önce');
    }
    if (settings.sunrise.isEnabled) {
      activeCount++;
      log(
        '[Notifications]  GÜNEŞ: ${settings.sunrise.minutesBefore} dakika önce',
      );
    }
    if (settings.dhuhr.isEnabled) {
      activeCount++;
      log('[Notifications]  ÖĞLE: ${settings.dhuhr.minutesBefore} dakika önce');
    }
    if (settings.asr.isEnabled) {
      activeCount++;
      log('[Notifications]  İKİNDİ: ${settings.asr.minutesBefore} dakika önce');
    }
    if (settings.maghrib.isEnabled) {
      activeCount++;
      log(
        '[Notifications]  AKŞAM: ${settings.maghrib.minutesBefore} dakika önce',
      );
    }
    if (settings.isha.isEnabled) {
      activeCount++;
      log('[Notifications]  YATSI: ${settings.isha.minutesBefore} dakika önce');
    }

    log('[Notifications] ═══════════════════════════════════════');
    log('[Notifications]  Toplam $activeCount vakit için bildirim aktif');
    log('[Notifications] ═══════════════════════════════════════');
  }

  //  Tüm sessiz mod ayarlarını logla (CREATED BY COPILOT)
  void _logAllSilentModeSettings() {
    log('[SilentMode] ═══════════════════════════════════════');
    log('[SilentMode]  AKTİF SESSİZ MOD AYARLARI:');
    log('[SilentMode] ═══════════════════════════════════════');

    final settings = state.silentModeDuringPraysSettings;
    int activeCount = 0;

    if (settings.fajr.isEnabled) {
      activeCount++;
      log(
        '[SilentMode]  İmsak: ${settings.fajr.minutesBefore} dk önce → ${settings.fajr.minutesAfter} dk sonra',
      );
    }
    if (settings.sunrise.isEnabled) {
      activeCount++;
      log(
        '[SilentMode] GÜNEŞ: ${settings.sunrise.minutesBefore} dk önce → ${settings.sunrise.minutesAfter} dk sonra',
      );
    }
    if (settings.dhuhr.isEnabled) {
      activeCount++;
      log(
        '[SilentMode]  ÖĞLE: ${settings.dhuhr.minutesBefore} dk önce → ${settings.dhuhr.minutesAfter} dk sonra',
      );
    }
    if (settings.asr.isEnabled) {
      activeCount++;
      log(
        '[SilentMode]  İKİNDİ: ${settings.asr.minutesBefore} dk önce → ${settings.asr.minutesAfter} dk sonra',
      );
    }
    if (settings.maghrib.isEnabled) {
      activeCount++;
      log(
        '[SilentMode]  AKŞAM: ${settings.maghrib.minutesBefore} dk önce → ${settings.maghrib.minutesAfter} dk sonra',
      );
    }
    if (settings.isha.isEnabled) {
      activeCount++;
      log(
        '[SilentMode]  YATSI: ${settings.isha.minutesBefore} dk önce → ${settings.isha.minutesAfter} dk sonra',
      );
    }

    log('[SilentMode] ═══════════════════════════════════════');
    log('[SilentMode]  Toplam $activeCount vakit için sessiz mod aktif');
    log('[SilentMode] ═══════════════════════════════════════');
  }

  void _disableAllNotifications() {
    for (final prayer in PrayerType.values) {
      final prayerKey = prayer.key;
      final currentSettings = state.notificationBeforePraysSettings;
      final currentPrayerSetting = currentSettings.getByKey(prayerKey);

      if (currentPrayerSetting != null) {
        final updated = currentPrayerSetting.copyWith(isEnabled: false);
        final newSettings = currentSettings.updateByKey(prayerKey, updated);

        storageServices.saveString(
          '${prayerKey}_notification',
          jsonEncode(updated.toJson()),
        );

        emit(state.copyWith(notificationBeforePraysSettings: newSettings));
      }
    }
  }

  void _disableAllSilentModes() {
    for (final prayer in PrayerType.values) {
      updateSilentModeSetting(prayerType: prayer, isEnabled: false);
    }
  }

  Future<void> updateNotificationSetting({
    required PrayerType prayerType,
    bool? isEnabled,
    int? minutesBefore,
  }) async {
    try {
      final currentSettings = state.notificationBeforePraysSettings;
      final prayerKey = prayerType.key;

      final currentPrayerSetting = currentSettings.getByKey(prayerKey);
      if (currentPrayerSetting == null) return;

      final updated = currentPrayerSetting.copyWith(
        isEnabled: isEnabled,
        minutesBefore: minutesBefore,
      );

      final newSettings = currentSettings.updateByKey(prayerKey, updated);

      await storageServices.saveString(
        '${prayerKey}_notification',
        jsonEncode(updated.toJson()),
      );

      emit(state.copyWith(notificationBeforePraysSettings: newSettings));

      await notificationManagerService.scheduleAllNotifications();

      // GÜNCELLEME: Daha detaylı log
      final prayerNameMap = {
        'fajr': 'İmsak',
        'sunrise': 'GÜNEŞ',
        'dhuhr': 'ÖĞLE',
        'asr': 'İKİNDİ',
        'maghrib': 'AKŞAM',
        'isha': 'YATSI',
      };

      final prayerName = prayerNameMap[prayerKey] ?? prayerKey.toUpperCase();

      if (updated.isEnabled) {
        log(
          '[Notifications]  $prayerName bildirimi AÇILDI: ${updated.minutesBefore} dakika önce',
        );
      } else {
        log('[Notifications]  $prayerName bildirimi KAPATILDI');
      }
    } catch (e) {
      log('[Notifications]  Bildirim ayarı güncellenirken hata: $e');
    }
  }

  Future<void> updateSilentModeSetting({
    required PrayerType prayerType,
    bool? isEnabled,
    int? minutesBefore,
    int? minutesAfter,
  }) async {
    try {
      final currentSettings = state.silentModeDuringPraysSettings;
      final prayerKey = prayerType.key;

      final currentPrayerSetting = currentSettings.getByKey(prayerKey);
      if (currentPrayerSetting == null) return;

      final updated = currentPrayerSetting.copyWith(
        isEnabled: isEnabled,
        minutesBefore: minutesBefore,
        minutesAfter: minutesAfter,
      );

      final newSettings = currentSettings.updateByKey(prayerKey, updated);

      await storageServices.saveString(
        '${prayerKey}_silent',
        jsonEncode(updated.toJson()),
      );

      emit(state.copyWith(silentModeDuringPraysSettings: newSettings));

      // GÜNCELLEME: Daha detaylı log
      final prayerNameMap = {
        'fajr': 'İmsak',
        'sunrise': 'GÜNEŞ',
        'dhuhr': 'ÖĞLE',
        'asr': 'İKİNDİ',
        'maghrib': 'AKŞAM',
        'isha': 'YATSI',
      };

      final prayerName = prayerNameMap[prayerKey] ?? prayerKey.toUpperCase();

      if (updated.isEnabled) {
        log(
          '[SilentMode]  $prayerName sessiz modu AÇILDI: ${updated.minutesBefore} dk önce → ${updated.minutesAfter} dk sonra',
        );
      } else {
        log('[SilentMode]  $prayerName sessiz modu KAPATILDI');
      }
    } catch (e) {
      log('[SilentMode]  Sessiz mod ayarı güncellenirken hata: $e');
    }
  }

  Future<void> updateLocation() async {
    emit(state.copyWith(isLocationLoading: true));

    try {
      final isServiceEnabled = await locationService.isLocationServiceEnabled();

      if (!isServiceEnabled) {
        emit(state.copyWith(isLocationLoading: false));
        throw Exception('SERVICE_DISABLED');
      }

      final locationData = await locationService.getCurrentCity();

      if (locationData != null) {
        final cityName = locationData['city'];
        final countryName = locationData['country'];
        final subAdministrativeArea = locationData['subAdministrativeArea'];

        await storageServices.saveString('cityName', cityName ?? '');
        await storageServices.saveString('countryName', countryName ?? '');
        await storageServices.saveString(
          'subAdministrativeArea',
          subAdministrativeArea ?? '',
        );

        emit(
          state.copyWith(
            cityName: cityName,
            countryName: countryName,
            subAdministrativeArea: subAdministrativeArea,
            isLocationLoading: false,
          ),
        );

        log('Konum güncellendi, bildirimler yeniden zamanlanıyor...');
        await notificationManagerService.scheduleAllNotifications();
        log('Konum değişikliği sonrası bildirimler güncellendi');

        log('Background service yeniden başlatılıyor...');
        await _restartBackgroundService();
        log('Background service yeniden başlatıldı');
      } else {
        emit(state.copyWith(isLocationLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLocationLoading: false));
      rethrow;
    }
  }

  Future<void> _restartBackgroundService() async {
    try {
      final service = FlutterBackgroundService();

      service.invoke('stopService');
      await Future.delayed(const Duration(seconds: 1));

      final isRunning = await service.isRunning();
      if (!isRunning) {
        await service.startService();
      }

      service.invoke('setAsForeground');

      log('Background service cache ile senkronize edildi');
    } catch (e) {
      log('Background service restart hatası: $e');
    }
  }

  Map<String, String>? getSavedLocation() {
    final cityName = state.cityName;
    final countryName = state.countryName;
    final subAdministrativeArea = state.subAdministrativeArea;

    if (cityName != null && countryName != null) {
      return {
        'city': cityName,
        'country': countryName,
        'subAdministrativeArea': subAdministrativeArea ?? '',
      };
    }
    return null;
  }

  Future<void> startBackgroundService() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
      log('Background service başlatıldı');
    } else {
      service.invoke('setAsForeground');
      log('Background service zaten çalışıyor, foreground mode aktif');
    }
  }

  Future<void> stopBackgroundService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    log('Background service durduruldu');
  }
}
