import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/services/dio_client.dart';
import 'package:prayer_time/features/core/services/location_service.dart';

class HomeRepository {
  String? cityName;
  final Dio _dio = DioClient.dio;
  final LocationService _locationService = LocationService();

  Future<Timings> getPrayerTimes() async {
    final String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // Kullanıcının konumunu al
    Map<String, String>? locationData;
    try {
      locationData = await _locationService.getCurrentCity();
      cityName = locationData?['city'];
    } catch (e) {
      // Konum alınamazsa varsayılan Kayseri kullan
      log('Konum alınamadı, varsayılan konum kullanılacak: $e');
    }
    final Map<String, dynamic> queryParameters = {
      'city': locationData?['city'] ?? 'Kayseri',
      'country': locationData?['country'] ?? 'TR',
      'method': 13,
      'timezonestring': 'Europe/Istanbul',
      'calendarMethod': 'DIYANET',
    };

    final String endpoint = '/timingsByCity/$todayDate';

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final prayerResponse = PrayerTimeResponse.fromJson(response.data);

      if (prayerResponse.data.timings != null) {
        return prayerResponse.data.timings!;
      } else {
        throw Exception('API\'den namaz vakitleri (timings) alınamadı.');
      }
    } on DioException catch (e) {
      throw Exception('Dio hatası: ${e.message}');
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }

  Future<Timings> getNextPrayerTimes() async {
    final String tomorrowDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final Map<String, dynamic> queryParameters = {
      'address': cityName ?? 'Kayseri',
      'country': 'TR',
      'method': 13,
      'timezonestring': 'Europe/Istanbul',
      'calendarMethod': 'DIYANET',
    };

    final String endpoint = '/nextPrayerByAddress/$tomorrowDate';

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final prayerResponse = PrayerTimeResponse.fromJson(response.data);

      if (prayerResponse.data.timings != null) {
        return prayerResponse.data.timings!;
      } else {
        throw Exception('API\'den namaz vakitleri (timings) alınamadı.');
      }
    } on DioException catch (e) {
      throw Exception('Dio hatası: ${e.message}');
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }
}
