import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';

class NotificationManagerService {
  final StorageServices storageServices;
  NotificationManagerService({required this.storageServices});

  NotificationBeforePraysSettings loadNotificationSettings() {
    return NotificationBeforePraysSettings(
      fajr: storageServices.loadSingleNotificationSetting('fajr_notification'),
      sunrise: storageServices.loadSingleNotificationSetting(
        'sunrise_notification',
      ),
      dhuhr: storageServices.loadSingleNotificationSetting(
        'dhuhr_notification',
      ),
      asr: storageServices.loadSingleNotificationSetting('asr_notification'),
      maghrib: storageServices.loadSingleNotificationSetting(
        'maghrib_notification',
      ),
      isha: storageServices.loadSingleNotificationSetting('isha_notification'),
    );
  }
}
