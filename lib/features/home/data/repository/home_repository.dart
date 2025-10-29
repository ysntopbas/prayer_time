import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/features/calendar/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/services/dio_client.dart';

class HomeRepository {
  final Dio _dio = DioClient.dio;

  Future<Timings> getPrayerTimes() async {
    final String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    final Map<String, dynamic> queryParameters = {
      'city': 'Kayseri',
      'country': 'TR',
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
}
