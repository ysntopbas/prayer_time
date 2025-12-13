import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/silentModeServices/silent_mode_manager_service.dart';

//  (Service Locator)
final sl = GetIt.instance;

Future<void> init() async {
  //! External (Harici Paketler)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core Services

  sl.registerLazySingleton(() => StorageServices(sl()));

  sl.registerLazySingleton(() => CacheService(sl()));

  // YENI: Silent Mode Service
  sl.registerLazySingleton(() => SilentModeManagerService(sl(), sl()));
}

Future<void> resetLocator() async {
  await sl.reset(); // Kutuyu tamamen boşalt
  await init(); // Kutuyu tekrar doldur
}
