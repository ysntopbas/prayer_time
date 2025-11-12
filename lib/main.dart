import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/routing/app_router.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/location_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/cubit/monthly_cubit.dart';
import 'package:prayer_time/features/weeklyPrayer/presentation/cubit/weekly_cubit.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context);
    final storageServices = StorageServices(sharedPreferences);
    final cacheService = CacheService(storageServices);
    final batteryOptimizationService = BatteryOptimizationService(
      sharedPreferences,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsCubit(
            storageServices,
            LocationService(),
            batteryOptimizationService,
          ),
        ),
        BlocProvider(create: (_) => HomeCubit(cacheService)),
        BlocProvider(create: (_) => MonthlyCubit(cacheService)),
        BlocProvider(create: (_) => WeeklyCubit(cacheService)),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: Locale(state.languageCode),
            debugShowCheckedModeBanner: false,
            title: l10nL?.headerTitle ?? 'Prayer Time',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
