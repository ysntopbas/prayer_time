import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/dio_client.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';

class HomeRepository {
  final Dio _dio = DioClient.dio;
  final LocationService _locationService = LocationService();
  final CacheService _cacheService;
  String? cityName;
  String? subAdministrativeArea;
  String? countryName;

  HomeRepository(this._cacheService);

  Future<Timings> getPrayerTimes({Map<String, String>? savedLocation}) async {
    Map<String, String>? locationData;

    if (savedLocation != null) {
      locationData = savedLocation;
      cityName = savedLocation['city'];
      subAdministrativeArea = savedLocation['subAdministrativeArea'];
    } else {
      try {
        locationData = await _locationService.getCurrentCity();
        cityName = locationData?['city'];
        subAdministrativeArea = locationData?['subAdministrativeArea'];
      } catch (e) {
        log('Konum alınamadı, varsayılan konum kullanılacak: $e');
      }
      log("$locationData");
    }

    // Background service için: Konum değişmediyse ve aynı gün ise cache'den dön
    final locationChanged = _cacheService.hasLocationChanged(locationData);

    if (!locationChanged && !_cacheService.shouldUpdateDaily()) {
      final cachedTimings = _cacheService.getDailyTimings();
      if (cachedTimings != null) {
        log('Günlük namaz vakitleri cache\'den alındı');
        return cachedTimings;
      }
    }

    // Konum değiştiyse cache'i temizle
    if (locationChanged && locationData != null) {
      log('Konum değişti! Cache temizleniyor ve yeniden kaydediliyor...');
      await _cacheService.clearAllCache();
      await _cacheService.saveCachedLocation(locationData);

      await _cacheService.storageServices.saveString(
        'cityName',
        locationData['city'] ?? '',
      );
      await _cacheService.storageServices.saveString(
        'countryName',
        locationData['country'] ?? '',
      );
      await _cacheService.storageServices.saveString(
        'subAdministrativeArea',
        locationData['subAdministrativeArea'] ?? '',
      );

      log('Cache temizlendi ve yeni konum kaydedildi');
    }

    final String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String city = locationData?['city'] ?? 'Istanbul';
    final String subAdministrativeArea2 =
        locationData?['subAdministrativeArea'] ?? 'Fatih';
    final String country = locationData?['country'] ?? 'TR';
    final Map<String, dynamic> queryParameters = {
      'address': '$subAdministrativeArea2, $city, $country',
      'method': 13,
      'timezonestring': 'Europe/Istanbul',
      'calendarMethod': 'DIYANET',
    };

    final String endpoint = '/timingsByAddress/$todayDate';

    try {
      log('Günlük namaz vakitleri API\'den çekiliyor');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final prayerResponse = PrayerTimeResponse.fromJson(response.data);

      if (prayerResponse.data.timings != null) {
        await _cacheService.saveDailyTimings(prayerResponse.data.timings!);
        // Güncelleme zamanını kaydet
        await _cacheService.updateLastUpdateTime();
        log('Günlük namaz vakitleri cache\'e kaydedildi');
        return prayerResponse.data.timings!;
      } else {
        throw Exception('API\'den namaz vakitleri (timings) alınamadı.');
      }
    } on DioException catch (e) {
      final cachedTimings = _cacheService.getDailyTimings();
      if (cachedTimings != null) {
        log('API hatası, cache\'den veri döndürülüyor');
        return cachedTimings;
      }
      throw Exception('Dio hatası: ${e.message}');
    } catch (e) {
      final cachedTimings = _cacheService.getDailyTimings();
      if (cachedTimings != null) {
        log('Hata oluştu, cache\'den veri döndürülüyor');
        return cachedTimings;
      }
      throw Exception('Bir hata oluştu: $e');
    }
  }

  Future<Timings> getNextPrayerTimes({
    Map<String, String>? savedLocation,
  }) async {
    Map<String, String>? locationData;

    if (savedLocation != null) {
      locationData = savedLocation;
    } else {
      try {
        locationData = await _locationService.getCurrentCity();
      } catch (e) {
        log('Konum alınamadı: $e');
      }
    }

    final locationChanged = _cacheService.hasLocationChanged(locationData);

    if (!locationChanged && !_cacheService.shouldUpdateDaily()) {
      final cachedTimings = _cacheService.getNextDayTimings();
      if (cachedTimings != null) {
        log('Yarının namaz vakitleri cache\'den alındı');

        return cachedTimings;
      }
    }

    final String tomorrowDate = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now().add(const Duration(days: 1)));
    final String city = locationData?['city'] ?? 'Istanbul';
    final String subAdministrativeArea2 =
        locationData?['subAdministrativeArea'] ?? 'Fatih';
    final String country = locationData?['country'] ?? 'TR';
    final Map<String, dynamic> queryParameters = {
      'address': '$subAdministrativeArea2, $city, $country',
      'method': 13,
      'timezonestring': 'Europe/Istanbul',
      'calendarMethod': 'DIYANET',
    };

    final String endpoint = '/timingsByAddress/$tomorrowDate';

    try {
      log('Yarının namaz vakitleri API\'den çekiliyor');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final prayerResponse = PrayerTimeResponse.fromJson(response.data);

      if (prayerResponse.data.timings != null) {
        // Cache'e kaydet
        await _cacheService.saveNextDayTimings(prayerResponse.data.timings!);
        log('Yarının namaz vakitleri cache\'e kaydedildi');
        return prayerResponse.data.timings!;
      } else {
        throw Exception('API\'den namaz vakitleri (timings) alınamadı.');
      }
    } on DioException catch (e) {
      // Hata durumunda cache'den dön
      final cachedTimings = _cacheService.getNextDayTimings();
      if (cachedTimings != null) {
        log('API hatası, cache\'den veri döndürülüyor');
        return cachedTimings;
      }
      throw Exception('HOME REPO Dio hatası: ${e.message}');
    } catch (e) {
      // Hata durumunda cache'den dön
      final cachedTimings = _cacheService.getNextDayTimings();
      if (cachedTimings != null) {
        log('Hata oluştu, cache\'den veri döndürülüyor');
        return cachedTimings;
      }
      throw Exception('Bir hata oluştu: $e');
    }
  }
}
