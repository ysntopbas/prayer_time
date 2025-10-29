import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  final SharedPreferences _preferences;

  StorageServices(this._preferences);

  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
