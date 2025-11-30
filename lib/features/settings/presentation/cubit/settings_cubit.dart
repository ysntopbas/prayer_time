import 'dart:convert';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/settings/extensions/settings_cubit_extension.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/services/notificationServices/notification_manager_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageServices storageServices;
  final LocationService locationService;
  final BatteryOptimizationService batteryOptimizationService;
  final NotificationManagerService notificationManagerService;

  SettingsCubit(
    this.storageServices,
    this.locationService,
    this.batteryOptimizationService,
    this.notificationManagerService,
  ) : super(const SettingsState()) {
    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    final isDarkMode = storageServices.getBool('isDarkMode') ?? false;
    final languageCode = storageServices.getString('languageCode') ?? 'en';
    final cityName = storageServices.getString('cityName');
    final countryName = storageServices.getString('countryName');
    final subAdministrativeArea = storageServices.getString(
      'subAdministrativeArea',
    );
    final mainNotificationsEnabled =
        storageServices.getBool('mainNotificationsEnabled') ?? false;
    final mainSilentModeEnabled =
        storageServices.getBool('mainSilentModeEnabled') ?? false;
    final notificationSettings = _loadNotificationSettings();
    final silentModeSettings = _loadSilentModeSettings();

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

    if (newValue && await shouldShowBatteryDialog()) {
      emit(
        state.copyWith(
          mainNotificationsEnabled: newValue,
          shouldShowBatteryDialog: true,
        ),
      );
    } else {
      emit(state.copyWith(mainNotificationsEnabled: newValue));
    }

    storageServices.saveBool('mainNotificationsEnabled', newValue);

    if (newValue) {
      // Ana switch açıldığında tüm namazları default olarak aktif et
      await _enableAllNotificationsWithDefaults();
    } else {
      // Ana switch kapandığında tüm bildirimleri kapat ve iptal et
      _disableAllNotifications(); // await kaldırıldı çünkü void döndürüyor
      await notificationManagerService.cancelAllScheduledNotifications();
    }

    // Bildirimleri yeniden zamanla (sadece açıksa)
    if (newValue) {
      await notificationManagerService.scheduleAllNotifications();
    }
  }

  Future<void> _enableAllNotificationsWithDefaults() async {
    for (final prayer in PrayerType.values) {
      final currentSettings = state.notificationBeforePraysSettings;
      final prayerKey = prayer.key;
      // currentPrayerSetting değişkenini kaldırdık çünkü kullanılmıyordu

      // Her namaz için default ayarlarla aktif et
      final updated = const NotificationBeforePrays(
        isEnabled: true,
        minutesBefore: 10, // Default 10 dakika
      );

      final newSettings = currentSettings.updateByKey(prayerKey, updated);

      await storageServices.saveString(
        '${prayerKey}_notification',
        jsonEncode(updated.toJson()),
      );

      emit(state.copyWith(notificationBeforePraysSettings: newSettings));
    }
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

  void mainToggleSilentMode() async {
    final newValue = !state.mainSilentModeEnabled;

    if (newValue && await shouldShowBatteryDialog()) {
      emit(
        state.copyWith(
          mainSilentModeEnabled: newValue,
          shouldShowBatteryDialog: true,
        ),
      );
    } else {
      emit(state.copyWith(mainSilentModeEnabled: newValue));
    }

    storageServices.saveBool('mainSilentModeEnabled', newValue);

    if (!newValue) {
      _disableAllSilentModes();
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

      // Her ayar değişikliğinde bildirimleri yeniden zamanla
      await notificationManagerService.scheduleAllNotifications();

      log(
        '✅ $prayerKey bildirimi güncellendi: enabled=${updated.isEnabled}, minutes=${updated.minutesBefore}',
      );
    } catch (e) {
      log('❌ Bildirim ayarı güncellenirken hata: $e');
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
    } catch (e) {
      log('Sessiz mod ayarı güncellenirken hata: $e');
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

        // Konum değiştiğinde bildirimleri yeniden zamanla
        log('📍 Konum güncellendi, bildirimler yeniden zamanlanıyor...');
        await notificationManagerService.scheduleAllNotifications();
        log('✅ Konum değişikliği sonrası bildirimler güncellendi');

        // Background service'i yeniden başlat (yeni cache ile)
        log('🔄 Background service yeniden başlatılıyor...');
        await _restartBackgroundService();
        log('✅ Background service yeniden başlatıldı');
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

      // Önce service'i durdur
      service.invoke('stopService');
      await Future.delayed(const Duration(seconds: 1));

      // Sonra yeniden başlat
      final isRunning = await service.isRunning();
      if (!isRunning) {
        await service.startService();
      }

      // Foreground mode'a geç
      service.invoke('setAsForeground');

      log('✓ Background service cache ile senkronize edildi');
    } catch (e) {
      log('❌ Background service restart hatası: $e');
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

  void clearBatteryDialogFlag() {
    emit(state.copyWith(shouldShowBatteryDialog: false));
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
