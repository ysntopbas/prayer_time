import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/dio_client.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';

class WeeklyRepository {
  String? cityName;
  String? subAdministrativeArea;
  final Dio _dio = DioClient.dio;
  final LocationService _locationService = LocationService();
  final CacheService _cacheService;

  WeeklyRepository(this._cacheService);

  Future<List<PrayerTimeModel>> getWeeklyPrayerTimes({
    Map<String, String>? savedLocation,
  }) async {
    Map<String, String>? locationData;

    // Önce kaydedilmiş konumu kullan
    if (savedLocation != null) {
      locationData = savedLocation;
      cityName = savedLocation['city'];
      subAdministrativeArea = savedLocation['subAdministrativeArea'];
    } else {
      // Kaydedilmiş konum yoksa GPS'ten al
      try {
        locationData = await _locationService.getCurrentCity();
        cityName = locationData?['city'];
        subAdministrativeArea = locationData?['subAdministrativeArea'];
      } catch (e) {
        log('Konum alınamadı: $e');
      }
    }

    // Konum değişikliğini kontrol et
    final locationChanged = _cacheService.hasLocationChanged(locationData);

    // Cache'den veri al
    if (!locationChanged && !_cacheService.shouldUpdateWeekly()) {
      final cachedTimings = _cacheService.getWeeklyTimings();
      if (cachedTimings != null && cachedTimings.isNotEmpty) {
        log('Haftalık namaz vakitleri cache\'den alındı');
        return cachedTimings;
      }
    }

    // API'den veri çek
    final String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String weekLaterDate = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now().add(const Duration(days: 7)));

    final String city = locationData?['city'] ?? 'Kayseri';
    subAdministrativeArea =
        locationData?['subAdministrativeArea'] ?? 'Melikgazi';
    final String country = locationData?['country'] ?? 'TR';
    final Map<String, dynamic> queryParameters = {
      'address': '$subAdministrativeArea, $city, $country',
      'method': 13,
      'timezonestring': 'Europe/Istanbul',
      'calendarMethod': 'DIYANET',
    };

    final String endpoint =
        '/calendarByAddress/from/$todayDate/to/$weekLaterDate';

    try {
      log('Haftalık namaz vakitleri API\'den çekiliyor');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final List<dynamic> jsonList = response.data['data'];

      if (jsonList.isNotEmpty) {
        final List<PrayerTimeModel> prayerList = jsonList
            .map(
              (jsonDay) =>
                  PrayerTimeModel.fromJson(jsonDay as Map<String, dynamic>),
            )
            .toList();

        // Cache'e kaydet
        await _cacheService.saveWeeklyTimings(prayerList);
        log('Haftalık namaz vakitleri cache\'e kaydedildi');

        return prayerList;
      } else {
        throw Exception('API\'den haftalık namaz vakitleri alınamadı.');
      }
    } on DioException catch (e) {
      // Hata durumunda cache'den dön
      final cachedTimings = _cacheService.getWeeklyTimings();
      if (cachedTimings != null && cachedTimings.isNotEmpty) {
        log('API hatası, cache\'den veri döndürülüyor');
        return cachedTimings;
      }
      throw Exception('WEEKLY REPO Dio hatası: ${e.message}');
    } catch (e) {
      // Hata durumunda cache'den dön
      final cachedTimings = _cacheService.getWeeklyTimings();
      if (cachedTimings != null && cachedTimings.isNotEmpty) {
        log('Hata oluştu, cache\'den veri döndürülüyor');
        return cachedTimings;
      }
      throw Exception('WEEKLY REPO Bir hata oluştu: $e');
    }
  }
}
