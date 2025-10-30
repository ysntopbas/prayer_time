import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Konum izinlerini kontrol eder ve gerekirse kullanıcıdan ister
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisi etkin mi kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Kullanıcının mevcut konumunu alır
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;

    try {
      final bedii = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return bedii;
    } catch (e) {
      throw Exception('Konum alınamadı: $e');
    }
  }

  /// Koordinatlardan şehir ve ülke bilgisi alır
  Future<Map<String, String>?> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        inspect(placemarks);
        Placemark place = placemarks[0];
        return {
          'city': place.administrativeArea ?? 'Unknown',
          'country': place.country ?? 'Unknown',
          'countryCode': place.isoCountryCode ?? 'Unknown',
        };
      }
      return null;
    } catch (e) {
      throw Exception('Şehir bilgisi alınamadı: $e');
    }
  }

  /// Kullanıcının konumuna göre şehir bilgisini alır
  Future<Map<String, String>?> getCurrentCity() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    return await getCityFromCoordinates(position.latitude, position.longitude);
  }
}
