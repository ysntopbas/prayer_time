import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/services/dio_client.dart';
import 'package:prayer_time/features/core/services/location_service.dart';

class MonthlyRepository {
  String? cityName;
  final Dio _dio = DioClient.dio;
  final LocationService _locationService = LocationService();

  Future<List<PrayerTimeModel>> getMonthlyPrayerTimes() async {
    final now = DateTime.now();
    final String currentMonth = DateFormat('MM').format(now);
    final String currentYear = DateFormat('yyyy').format(now);
    // Kullanıcının konumunu al
    Map<String, String>? locationData;
    try {
      locationData = await _locationService.getCurrentCity();
      cityName = locationData?['city'];
    } catch (e) {
      // Konum alınamazsa varsayılan Kayseri kullan
    }
    final Map<String, dynamic> queryParameters = {
      'city': locationData?['city'] ?? 'Kayseri',
      'country': locationData?['country'] ?? 'TR',
      'method': 13,
      'timezonestring': 'Europe/Istanbul',
      'calendarMethod': 'DIYANET',
    };

    final String endpoint = '/calendarByCity/$currentYear/$currentMonth';

    try {
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
        return prayerList;
      } else {
        throw Exception('API\'den  aylık namaz vakitleri  alınamadı.');
      }
    } on DioException catch (e) {
      throw Exception('MONTHLY REPO Dio hatası: ${e.message}');
    } catch (e) {
      throw Exception('MONTHLY REPO Bir hata oluştu: $e');
    }
  }
}
