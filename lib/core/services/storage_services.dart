import 'dart:convert';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  final SharedPreferences _preferences;

  StorageServices(this._preferences);

  Future<void> saveString(String key, String value) async =>
      await _preferences.setString(key, value);
  String? getString(String key) => _preferences.getString(key);

  Future<void> saveInt(String key, int value) async =>
      await _preferences.setInt(key, value);
  int? getInt(String key) => _preferences.getInt(key);

  Future<void> saveBool(String key, bool value) async =>
      await _preferences.setBool(key, value);
  bool? getBool(String key) => _preferences.getBool(key);

  Future<void> remove(String key) async => await _preferences.remove(key);
  Future<void> clear() async => await _preferences.clear();

  NotificationBeforePrays loadSingleNotificationSetting(String key) {
    final jsonString = _preferences.getString(key);
    if (jsonString != null) {
      try {
        return NotificationBeforePrays.fromJson(jsonDecode(jsonString));
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
        return SilentModeDuringPrays.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return const SilentModeDuringPrays();
      }
    }
    return const SilentModeDuringPrays();
  }
}
