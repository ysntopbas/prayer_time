import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class SoundModeChangeTestScreen extends StatefulWidget {
  const SoundModeChangeTestScreen({super.key});

  @override
  State<SoundModeChangeTestScreen> createState() =>
      _SoundModeChangeTestScreenState();
}

class _SoundModeChangeTestScreenState extends State<SoundModeChangeTestScreen> {
  RingerModeStatus _soundMode = RingerModeStatus.unknown;
  String? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _getCurrentSoundMode();
    _checkPermissionStatus();
  }

  /// Mevcut ses modunu getirir
  Future<void> _getCurrentSoundMode() async {
    RingerModeStatus ringerStatus = RingerModeStatus.unknown;
    try {
      ringerStatus = await SoundMode.ringerModeStatus;
    } catch (err) {
      ringerStatus = RingerModeStatus.unknown;
    }
    if (mounted) {
      setState(() {
        _soundMode = ringerStatus;
      });
    }
  }

  /// İzin durumunu kontrol eder
  Future<void> _checkPermissionStatus() async {
    bool? permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;
    } catch (err) {
      log(err.toString());
    }

    if (mounted) {
      setState(() {
        _permissionStatus = permissionStatus == true
            ? "İzin Verildi (Yönetilebilir)"
            : "İzin Verilmedi (Sessize Alınamaz)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ses Modu Testi")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.notifications_active,
                  size: 50,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  'Şu anki Mod: $_soundMode',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('İzin Durumu: $_permissionStatus'),
                const SizedBox(height: 30),

                // --- BUTONLAR ---
                _buildActionButton(
                  "Mevcut Durumu Gör",
                  _getCurrentSoundMode,
                  Colors.blue,
                ),
                _buildActionButton(
                  "Normal (Sesli) Mod",
                  () => _changeSoundMode(RingerModeStatus.normal),
                  Colors.green,
                ),
                _buildActionButton(
                  "Titreşim Modu",
                  () => _changeSoundMode(RingerModeStatus.vibrate),
                  Colors.orange,
                ),
                _buildActionButton(
                  "Sessiz Mod (Namaz Modu)",
                  () => _changeSoundMode(RingerModeStatus.silent),
                  Colors.red,
                ),
                const Divider(),
                _buildActionButton(
                  "İzin Ayarlarını Aç",
                  _openDoNotDisturbSettings,
                  Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }

  /// Tek bir fonksiyon üzerinden tüm mod geçişlerini yönetiyoruz
  Future<void> _changeSoundMode(RingerModeStatus mode) async {
    try {
      // Modu değiştirmeyi dene
      var status = await SoundMode.setSoundMode(mode);

      if (mounted) {
        setState(() {
          _soundMode = status;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Mod değiştirildi: $mode")));
      }
    } on PlatformException {
      // HATA: İzin yoksa buraya düşer
      log('Do Not Disturb access permissions required!');
      if (mounted) {
        _showPermissionDialog();
      }
    } catch (e) {
      log("Bilinmeyen hata: $e");
    }
  }

  /// Kullanıcıya izin vermesi gerektiğini anlatan pencere
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("İzin Gerekiyor"),
        content: const Text(
          "Namaz vakitlerinde telefonun tamamen sessize alınabilmesi için 'Rahatsız Etme' erişimine izin vermeniz gerekmektedir.\n\nAyarları açıp uygulamanızı bulup izni aktif edin.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openDoNotDisturbSettings();
            },
            child: const Text("Ayarları Aç"),
          ),
        ],
      ),
    );
  }

  Future<void> _openDoNotDisturbSettings() async {
    await PermissionHandler.openDoNotDisturbSetting();
    // Kullanıcı ayarlardan geri döndüğünde durumu tekrar kontrol edelim
    // Biraz gecikme veriyoruz ki ayarlar güncellensin
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissionStatus();
  }
}
