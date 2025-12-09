import 'package:permission_handler/permission_handler.dart';
import 'package:prayer_time/core/services/storage_services.dart';

class BatteryOptimizationService {
  static const String _hasShownBatteryDialogKey = 'has_shown_battery_dialog';

  final StorageServices _storageServices;

  BatteryOptimizationService(this._storageServices);

  /// Daha önce pil optimizasyonu diyalogu gösterildi mi?
  bool hasShownBatteryDialog() {
    return _storageServices.getBool(_hasShownBatteryDialogKey) ?? false;
  }

  /// Pil optimizasyonu diyalogu gösterildi olarak işaretle
  Future<void> markBatteryDialogAsShown() async {
    await _storageServices.saveBool(_hasShownBatteryDialogKey, true);
  }

  /// Pil optimizasyonu iznini kontrol et
  Future<bool> isBatteryOptimizationDisabled() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Pil optimizasyonu ayarlarını aç
  Future<void> requestBatteryOptimizationPermission() async {
    await Permission.ignoreBatteryOptimizations.request();
  }
}
