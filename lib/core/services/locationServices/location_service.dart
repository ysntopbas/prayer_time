import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('SERVICE_DISABLED');
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

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (e) {
      throw Exception('Konum alınamadı: $e');
    }
  }

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
        Placemark place = placemarks[0];
        return {
          'city': place.administrativeArea ?? 'Unknown',
          'country': place.country ?? 'Unknown',
          'countryCode': place.isoCountryCode ?? 'Unknown',
          'subAdministrativeArea': place.subAdministrativeArea ?? 'Unknown',
        };
      }
      return null;
    } catch (e) {
      throw Exception('Şehir bilgisi alınamadı: $e');
    }
  }

  Future<Map<String, String>?> getCurrentCity() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    return await getCityFromCoordinates(position.latitude, position.longitude);
  }
}
