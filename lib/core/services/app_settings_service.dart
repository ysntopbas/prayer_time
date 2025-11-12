import 'package:app_settings/app_settings.dart';

/// A service class for handling app settings operations.
/// This service provides methods to open various system settings
/// and can be reused across different projects.
class AppSettingsService {
  /// Private constructor to prevent instantiation
  const AppSettingsService._();

  /// Opens a specific app settings page based on the provided type
  ///
  /// [type] - The type of settings page to open
  /// [asAnotherTask] - If true, opens the settings in a separate task (Android)
  static Future<void> openSettings({
    required AppSettingsType type,
    bool asAnotherTask = false,
  }) async {
    await AppSettings.openAppSettings(type: type, asAnotherTask: asAnotherTask);
  }

  /// Opens a specific app settings panel (iOS)
  ///
  /// [type] - The type of settings panel to open
  static Future<void> openSettingsPanel(AppSettingsPanelType type) async {
    await AppSettings.openAppSettingsPanel(type);
  }

  // Commonly used settings shortcuts

  /// Opens WiFi settings
  static Future<void> openWifiSettings() async {
    await openSettings(type: AppSettingsType.wifi);
  }

  /// Opens location settings
  static Future<void> openLocationSettings() async {
    await openSettings(type: AppSettingsType.location);
  }

  /// Opens notification settings
  static Future<void> openNotificationSettings() async {
    await openSettings(type: AppSettingsType.notification);
  }

  /// Opens bluetooth settings
  static Future<void> openBluetoothSettings() async {
    await openSettings(type: AppSettingsType.bluetooth);
  }

  /// Opens app-specific settings
  static Future<void> openAppSettings() async {
    await openSettings(type: AppSettingsType.settings);
  }

  /// Opens battery optimization settings
  static Future<void> openBatteryOptimizationSettings() async {
    await openSettings(type: AppSettingsType.batteryOptimization);
  }

  /// Opens security settings
  static Future<void> openSecuritySettings() async {
    await openSettings(type: AppSettingsType.security);
  }

  /// Opens display settings
  static Future<void> openDisplaySettings() async {
    await openSettings(type: AppSettingsType.display);
  }

  /// Opens sound settings
  static Future<void> openSoundSettings() async {
    await openSettings(type: AppSettingsType.sound);
  }

  /// Opens accessibility settings
  static Future<void> openAccessibilitySettings() async {
    await openSettings(
      type: AppSettingsType.accessibility,
      asAnotherTask: true,
    );
  }

  /// Opens data roaming settings
  static Future<void> openDataRoamingSettings() async {
    await openSettings(type: AppSettingsType.dataRoaming);
  }

  /// Opens date settings
  static Future<void> openDateSettings() async {
    await openSettings(type: AppSettingsType.date);
  }

  /// Opens internal storage settings
  static Future<void> openInternalStorageSettings() async {
    await openSettings(type: AppSettingsType.internalStorage);
  }

  /// Opens NFC settings
  static Future<void> openNfcSettings() async {
    await openSettings(type: AppSettingsType.nfc);
  }

  /// Opens VPN settings
  static Future<void> openVpnSettings() async {
    await openSettings(type: AppSettingsType.vpn, asAnotherTask: true);
  }

  /// Opens device settings
  static Future<void> openDeviceSettings() async {
    await openSettings(type: AppSettingsType.device, asAnotherTask: true);
  }

  /// Opens developer settings
  static Future<void> openDeveloperSettings() async {
    await openSettings(type: AppSettingsType.developer, asAnotherTask: true);
  }

  /// Opens hotspot settings
  static Future<void> openHotspotSettings() async {
    await openSettings(type: AppSettingsType.hotspot, asAnotherTask: true);
  }

  /// Opens APN settings
  static Future<void> openApnSettings() async {
    await openSettings(type: AppSettingsType.apn, asAnotherTask: true);
  }

  /// Opens alarm settings
  static Future<void> openAlarmSettings() async {
    await openSettings(type: AppSettingsType.alarm, asAnotherTask: true);
  }

  /// Opens subscription settings
  static Future<void> openSubscriptionSettings() async {
    await openSettings(
      type: AppSettingsType.subscriptions,
      asAnotherTask: true,
    );
  }

  /// Opens camera settings
  static Future<void> openCameraSettings() async {
    await openSettings(type: AppSettingsType.camera, asAnotherTask: true);
  }

  /// Opens lock and password settings
  static Future<void> openLockAndPasswordSettings() async {
    await openSettings(type: AppSettingsType.lockAndPassword);
  }

  /// Opens manage unknown app sources settings
  static Future<void> openManageUnknownAppSourcesSettings() async {
    await openSettings(type: AppSettingsType.manageUnknownAppSources);
  }

  // iOS Settings Panel shortcuts

  /// Opens WiFi settings panel (iOS)
  static Future<void> openWifiPanel() async {
    await openSettingsPanel(AppSettingsPanelType.wifi);
  }

  /// Opens NFC settings panel (iOS)
  static Future<void> openNfcPanel() async {
    await openSettingsPanel(AppSettingsPanelType.nfc);
  }

  /// Opens internet connectivity panel (iOS)
  static Future<void> openInternetConnectivityPanel() async {
    await openSettingsPanel(AppSettingsPanelType.internetConnectivity);
  }

  /// Opens volume panel (iOS)
  static Future<void> openVolumePanel() async {
    await openSettingsPanel(AppSettingsPanelType.volume);
  }
}
