import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  log('Arka plan servisi');

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      log('Foreground service olarak ayarlandı');
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      log('Background service olarak ayarlandı');
    });
  }

  service.on('stopService').listen((event) {
    log('Servis durduruluyor');
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Bildirimi güncelle
        service.setForegroundNotificationInfo(
          title: "Namaz Vakti Servisi Aktif",
          content:
              "Son güncelleme: ${DateTime.now().toString().substring(11, 19)}",
        );
        log('Foreground service çalışıyor');
      } else {
        log('Background service çalışıyor');
      }
    }

    // Namaz vakti kontrolü
    // Bildirim zamanlaması
    // Sessiz mod aktivasyonu
  });
}
