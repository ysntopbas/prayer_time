import 'dart:convert';
import 'dart:developer';

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

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    try {
      String jsonString = json.encode(value);
      await _preferences.setString(key, jsonString);
    } catch (e) {
      log('StorageServices - saveMap Error: $e');
    }
  }

  Map<String, dynamic>? getMap(String key) {
    try {
      final String? jsonString = _preferences.getString(key);
      if (jsonString == null) {
        return null;
      }
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      log('StorageServices - getMap Error: $e');
      return null;
    }
  }
}
