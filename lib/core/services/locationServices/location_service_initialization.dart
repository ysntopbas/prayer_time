import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/core/init/locator.dart';
import 'package:prayer_time/core/services/cache_service.dart';

class LocationServiceInitialization {
  final BuildContext context;

  LocationServiceInitialization(this.context);

  Future<bool> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    final CacheService cacheService = sl<CacheService>();
    final cachedData = cacheService.getCachedLocation();
    final bool hasCache = cachedData != null && cachedData.isNotEmpty;

    if (!serviceEnabled && !hasCache) {
      bool userWantsToOpenSettings = await _showEnableGpsDialog();

      if (userWantsToOpenSettings) {
        await Geolocator.openLocationSettings();

        await Future.delayed(const Duration(milliseconds: 1500));

        serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled) {
          return await initialize();
        }
      } else {
        return false;
      }
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedDialog();
      return false;
    }

    return true;
  }

  /// Kullanıcıya GPS açtırma kutusu
  Future<bool> _showEnableGpsDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Konum Servisi Kapalı"),
            content: const Text(
              "Namaz vakitlerini doğru hesaplayabilmemiz için cihazınızın konumunu açmanız gerekmektedir.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Ayarları Aç"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konum İzni Gerekli"),
        content: const Text(
          "Konum izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından konum iznini açın.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tamam"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
            },
            child: const Text("Ayarları Aç"),
          ),
        ],
      ),
    );
  }
}
