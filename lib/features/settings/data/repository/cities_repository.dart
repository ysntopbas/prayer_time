import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:prayer_time/features/settings/data/models/city_model.dart';

class CitiesRepository {
  List<CityModel>? _cachedCities;

  Future<List<CityModel>> loadCities() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/jsons/turkey_cities.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _cachedCities = jsonList
          .map((json) => CityModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedCities!.sort((a, b) => a.displayName.compareTo(b.displayName));

      return _cachedCities!;
    } catch (e) {
      throw Exception('Şehirler yüklenemedi: $e');
    }
  }

  Future<CityModel?> getCityByName(String cityName) async {
    final cities = await loadCities();
    final lowerCityName = cityName.toLowerCase();

    return cities.cast<CityModel?>().firstWhere(
      (city) =>
          city!.name.toLowerCase() == lowerCityName ||
          city.displayName.toLowerCase() == lowerCityName,
      orElse: () => null,
    );
  }

  Future<CityModel?> getCityByPlate(String plate) async {
    final cities = await loadCities();

    return cities.cast<CityModel?>().firstWhere(
      (city) => city!.plate == plate,
      orElse: () => null,
    );
  }

  Future<List<CityModel>> searchCities(String query) async {
    if (query.isEmpty) {
      return await loadCities();
    }

    final cities = await loadCities();
    final lowerQuery = query.toLowerCase();

    return cities.where((city) {
      return city.name.toLowerCase().contains(lowerQuery) ||
          city.displayName.toLowerCase().contains(lowerQuery) ||
          city.plate.contains(query);
    }).toList();
  }

  List<String> searchCounties(CityModel city, String query) {
    if (query.isEmpty) {
      return city.counties.map((c) => CityModel.capitalizeCounty(c)).toList();
    }

    final lowerQuery = query.toLowerCase();

    return city.counties
        .where((county) => county.toLowerCase().contains(lowerQuery))
        .map((c) => CityModel.capitalizeCounty(c))
        .toList();
  }

  void clearCache() {
    _cachedCities = null;
  }
}
