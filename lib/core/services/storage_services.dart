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
}
