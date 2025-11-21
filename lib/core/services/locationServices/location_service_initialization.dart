import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceInitialization {
  final BuildContext context;

  LocationServiceInitialization(this.context);

  /// Bu fonksiyon:
  /// 1. GPS açık mı bakar. Kapalıysa açtırır ve (tekrardan) kontrol eder.
  /// 2. İzin verilmiş mi bakar. Verilmemişse ister.
  /// 3. Her şey tamamsa `true`, kullanıcı vazgeçerse `false` döner.
  Future<bool> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. AŞAMA: Cihazın Konum Servisi (GPS) Açık mı?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Servis Kapalı! Kullanıcıya Dialog göster.
      bool userWantsToOpenSettings = await _showEnableGpsDialog();

      if (userWantsToOpenSettings) {
        // Kullanıcı "Ayarları Aç" dedi.
        await Geolocator.openLocationSettings();

        // KRİTİK NOKTA: Kullanıcı ayarlardan geri döndü.
        // Fonksiyonu baştan çağırıyoruz (Recursion).
        // Böylece GPS'i açıp açmadığını tekrar kontrol ediyoruz.
        return await initialize();
      } else {
        // Kullanıcı "Vazgeç" dedi. Varsayılan şehirle devam edilecek.
        return false;
      }
    }

    // 2. AŞAMA: İzin Kontrolü (GPS açıksa buraya geçer)
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // İzin verilmedi
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Kalıcı engellendi (Ayarlara gitmesi lazım ama şimdilik false dönelim)
      return false;
    }

    // 3. AŞAMA: Başarılı
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
                onPressed: () => Navigator.of(context).pop(false), // Vazgeç
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // Ayarları Aç
                child: const Text("Ayarları Aç"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
