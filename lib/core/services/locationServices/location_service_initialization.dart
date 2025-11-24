import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceInitialization {
  final BuildContext context;

  LocationServiceInitialization(this.context);

  Future<bool> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cihazın Konum Servisi (GPS) Açık mı?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Servis Kapalı! Kullanıcıya Dialog göster.
      bool userWantsToOpenSettings = await _showEnableGpsDialog();

      if (userWantsToOpenSettings) {
        // Kullanıcı "Ayarları Aç" dedi.
        await Geolocator.openLocationSettings();

        //Kullanıcının ayarlardan dönmesini bekle
        await Future.delayed(const Duration(milliseconds: 1500));

        //GPS'in açılıp açılmadığını kontrol et
        serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled) {
          // GPS hala kapalı, tekrar dialog göster
          return await initialize();
        }
        // GPS açıldı, devam et
      } else {
        // Kullanıcı "Vazgeç" dedi. Varsayılan şehirle devam edilecek.
        return false;
      }
    }

    //  İzin Kontrolü (GPS açıksa buraya geçer)
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // İzin verilmedi
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Kalıcı engellendi
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

  /// Konum izni kalıcı olarak reddedildiğinde gösterilecek dialog
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
