import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/services/cache_service.dart';

// Bu 'sl' (Service Locator) bizim sihirli kutumuz
final sl = GetIt.instance;

Future<void> init() async {
  //! External (Harici Paketler)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core Services

  sl.registerLazySingleton(() => StorageServices(sl()));

  sl.registerLazySingleton(() => CacheService(sl()));
}
