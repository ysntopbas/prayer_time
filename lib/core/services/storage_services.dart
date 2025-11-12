import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  final SharedPreferences _preferences;

  StorageServices(this._preferences);

  // String kaydet
  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  // String oku
  String? getString(String key) {
    return _preferences.getString(key);
  }

  // Int kaydet
  Future<void> saveInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  // Int oku
  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  // Bool kaydet
  Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  // Bool oku
  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  // Anahtar sil
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  // Tüm verileri temizle
  Future<void> clear() async {
    await _preferences.clear();
  }

  NotificationBeforePrays loadSingleNotificationSetting(String key) {
    final jsonString = _preferences.getString(key);
    if (jsonString != null) {
      try {
        return NotificationBeforePrays.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } catch (e) {
        return const NotificationBeforePrays();
      }
    }
    return const NotificationBeforePrays();
  }

  SilentModeDuringPrays loadSingleSilentModeSetting(String key) {
    final jsonString = _preferences.getString(key);
    if (jsonString != null) {
      try {
        return SilentModeDuringPrays.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } catch (e) {
        return const SilentModeDuringPrays();
      }
    }
    return const SilentModeDuringPrays();
  }
}

class BatteryOptimizationService {
  static const String _hasShownBatteryDialogKey = 'has_shown_battery_dialog';

  final SharedPreferences _prefs;

  BatteryOptimizationService(this._prefs);

  /// Daha önce pil optimizasyonu diyalogu gösterildi mi?
  bool hasShownBatteryDialog() {
    return _prefs.getBool(_hasShownBatteryDialogKey) ?? false;
  }

  /// Pil optimizasyonu diyalogu gösterildi olarak işaretle
  Future<void> markBatteryDialogAsShown() async {
    await _prefs.setBool(_hasShownBatteryDialogKey, true);
  }

  /// Pil optimizasyonu iznini kontrol et
  Future<bool> isBatteryOptimizationDisabled() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Pil optimizasyonu ayarlarını aç
  Future<void> requestBatteryOptimizationPermission() async {
    await Permission.ignoreBatteryOptimizations.request();
  }

  /// Cache'i temizle (test için)
  Future<void> resetBatteryDialogFlag() async {
    await _prefs.remove(_hasShownBatteryDialogKey);
  }
}
