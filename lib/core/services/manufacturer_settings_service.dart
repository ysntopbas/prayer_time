import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ManufacturerSettingsService {
  static Future<String?> getManufacturer() async {
    if (!Platform.isAndroid) return null;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.manufacturer.toLowerCase();
  }

  static Future<void> showManufacturerSettingsDialog(
    BuildContext context,
  ) async {
    final manufacturer = await getManufacturer();
    if (manufacturer == null) return;

    final settings = _getManufacturerSettings(manufacturer);
    if (settings == null) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${settings['brand']} Ayarları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Uygulamanın arka planda düzgün çalışması için aşağıdaki ayarları yapmanız gerekiyor:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                (settings['steps'] as List).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. '),
                      Expanded(child: Text(settings['steps'][index])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anladım'),
          ),
          if (settings['settingsUrl'] != null)
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(settings['settingsUrl']);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text('Ayarlara Git'),
            ),
        ],
      ),
    );
  }

  static Map<String, dynamic>? _getManufacturerSettings(String manufacturer) {
    switch (manufacturer) {
      case 'xiaomi':
      case 'redmi':
      case 'poco':
        return {
          'brand': 'Xiaomi/MIUI',
          'steps': [
            'Ayarlar > Uygulamalar > Uygulamaları Yönet > Prayer Time > Otomatik başlatma: AÇIK',
            'Ayarlar > Pil ve Performans > Prayer Time > Kısıtlama yok',
            'Son uygulamalar ekranında Prayer Time\'ı aşağı kaydırarak kilitleyin (🔒 simgesi görünecek)',
            'Güvenlik > Arka plan etkinliği > Prayer Time\'a izin verin',
          ],
        };
      case 'samsung':
        return {
          'brand': 'Samsung',
          'steps': [
            'Ayarlar > Pil ve cihaz bakımı > Pil > Arka plan kullanım sınırları',
            'Prayer Time\'ı "Hiçbir zaman uyutma" listesine ekleyin',
            'Ayarlar > Uygulamalar > Prayer Time > Pil > Sınırsız',
          ],
        };
      case 'huawei':
      case 'honor':
        return {
          'brand': 'Huawei/Honor',
          'steps': [
            'Ayarlar > Uygulamalar > Prayer Time > Pil > Manuel olarak yönet',
            'Ayarlar > Pil > Uygulama başlatma > Prayer Time > Manuel yönet (3 seçeneği de açın)',
            'Telefon Yöneticisi > Otomatik başlatma yöneticisi > Prayer Time: AÇIK',
          ],
        };
      case 'oppo':
      case 'realme':
      case 'oneplus':
        return {
          'brand': 'OPPO/Realme/OnePlus',
          'steps': [
            'Ayarlar > Pil > Prayer Time > Arka plan etkinliği izin ver',
            'Ayarlar > Uygulamalar > Prayer Time > Otomatik başlatma: AÇIK',
            'Son uygulamalar > Prayer Time\'ı kilitleyin',
          ],
        };
      default:
        return {
          'brand': 'Android',
          'steps': [
            'Ayarlar > Uygulamalar > Prayer Time > Pil > Kısıtlama yok',
            'Ayarlar > Pil > Pil optimizasyonu > Prayer Time > Optimize etme',
          ],
        };
    }
  }
}
