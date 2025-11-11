import 'dart:convert';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/storage_services.dart';

class CacheService {
  final StorageServices _storageServices;

  CacheService(this._storageServices);

  // Cache Keys
  static const String _dailyTimingsKey = 'daily_timings';
  static const String _weeklyTimingsKey = 'weekly_timings';
  static const String _monthlyTimingsKey = 'monthly_timings';
  static const String _nextDayTimingsKey = 'next_day_timings';
  static const String _lastDailyUpdateKey = 'last_daily_update';
  static const String _lastWeeklyUpdateKey = 'last_weekly_update';
  static const String _lastMonthlyUpdateKey = 'last_monthly_update';
  static const String _cachedLocationKey = 'cached_location';

  // Günlük namaz vakitlerini kaydet
  Future<void> saveDailyTimings(Timings timings) async {
    final json = jsonEncode(timings.toJson());
    await _storageServices.saveString(_dailyTimingsKey, json);
    await _storageServices.saveString(
      _lastDailyUpdateKey,
      DateTime.now().toIso8601String(),
    );
  }

  // Günlük namaz vakitlerini al
  Timings? getDailyTimings() {
    final json = _storageServices.getString(_dailyTimingsKey);
    if (json == null) return null;
    return Timings.fromJson(jsonDecode(json));
  }

  // Yarının namaz vakitlerini kaydet
  Future<void> saveNextDayTimings(Timings timings) async {
    final json = jsonEncode(timings.toJson());
    await _storageServices.saveString(_nextDayTimingsKey, json);
  }

  // Yarının namaz vakitlerini al
  Timings? getNextDayTimings() {
    final json = _storageServices.getString(_nextDayTimingsKey);
    if (json == null) return null;
    return Timings.fromJson(jsonDecode(json));
  }

  // Haftalık namaz vakitlerini kaydet
  Future<void> saveWeeklyTimings(List<PrayerTimeModel> timings) async {
    final jsonList = timings.map((e) => e.toJson()).toList();
    final json = jsonEncode(jsonList);
    await _storageServices.saveString(_weeklyTimingsKey, json);
    await _storageServices.saveString(
      _lastWeeklyUpdateKey,
      DateTime.now().toIso8601String(),
    );
  }

  // Haftalık namaz vakitlerini al
  List<PrayerTimeModel>? getWeeklyTimings() {
    final json = _storageServices.getString(_weeklyTimingsKey);
    if (json == null) return null;
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((e) => PrayerTimeModel.fromJson(e)).toList();
  }

  // Aylık namaz vakitlerini kaydet
  Future<void> saveMonthlyTimings(List<PrayerTimeModel> timings) async {
    final jsonList = timings.map((e) => e.toJson()).toList();
    final json = jsonEncode(jsonList);
    await _storageServices.saveString(_monthlyTimingsKey, json);
    await _storageServices.saveString(
      _lastMonthlyUpdateKey,
      DateTime.now().toIso8601String(),
    );
  }

  // Aylık namaz vakitlerini al
  List<PrayerTimeModel>? getMonthlyTimings() {
    final json = _storageServices.getString(_monthlyTimingsKey);
    if (json == null) return null;
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((e) => PrayerTimeModel.fromJson(e)).toList();
  }

  // Cache'lenmiş konumu kaydet
  Future<void> saveCachedLocation(Map<String, String> location) async {
    final json = jsonEncode(location);
    await _storageServices.saveString(_cachedLocationKey, json);
  }

  // Cache'lenmiş konumu al
  Map<String, String>? getCachedLocation() {
    final json = _storageServices.getString(_cachedLocationKey);
    if (json == null) return null;
    return Map<String, String>.from(jsonDecode(json));
  }

  // Günlük güncelleme gerekli mi?
  bool shouldUpdateDaily() {
    final lastUpdate = _storageServices.getString(_lastDailyUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateDate = DateTime.parse(lastUpdate);
    final now = DateTime.now();

    // Gün değiştiyse güncelle
    return lastUpdateDate.day != now.day ||
        lastUpdateDate.month != now.month ||
        lastUpdateDate.year != now.year;
  }

  // Haftalık güncelleme gerekli mi?
  bool shouldUpdateWeekly() {
    final lastUpdate = _storageServices.getString(_lastWeeklyUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateDate = DateTime.parse(lastUpdate);
    final now = DateTime.now();

    // 7 gün geçtiyse güncelle
    final difference = now.difference(lastUpdateDate);
    return difference.inDays >= 7;
  }

  // Aylık güncelleme gerekli mi?
  bool shouldUpdateMonthly() {
    final lastUpdate = _storageServices.getString(_lastMonthlyUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateDate = DateTime.parse(lastUpdate);
    final now = DateTime.now();

    // Ay değiştiyse güncelle
    return lastUpdateDate.month != now.month || lastUpdateDate.year != now.year;
  }

  // Konum değişti mi kontrol et
  bool hasLocationChanged(Map<String, String>? newLocation) {
    if (newLocation == null) return false;

    final cachedLocation = getCachedLocation();
    if (cachedLocation == null) return true;

    return cachedLocation['city'] != newLocation['city'] ||
        cachedLocation['country'] != newLocation['country'] ||
        cachedLocation['subAdministrativeArea'] !=
            newLocation['subAdministrativeArea'];
  }

  // Tüm cache'i temizle
  Future<void> clearAllCache() async {
    await _storageServices.remove(_dailyTimingsKey);
    await _storageServices.remove(_weeklyTimingsKey);
    await _storageServices.remove(_monthlyTimingsKey);
    await _storageServices.remove(_nextDayTimingsKey);
    await _storageServices.remove(_lastDailyUpdateKey);
    await _storageServices.remove(_lastWeeklyUpdateKey);
    await _storageServices.remove(_lastMonthlyUpdateKey);
    await _storageServices.remove(_cachedLocationKey);
  }
}
