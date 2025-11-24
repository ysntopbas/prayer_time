import 'package:go_router/go_router.dart';
import 'package:prayer_time/features/compass/presentation/screens/compass_page.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/screens/monthly_prayer_time.dart';
import 'package:prayer_time/core/routing/app_routes.dart';
import 'package:prayer_time/features/home/presentation/screens/home_screen.dart';
import 'package:prayer_time/features/settings/presentation/screens/settings_screen.dart';
import 'package:prayer_time/features/splashScreen/splash_screen.dart';
import 'package:prayer_time/features/weeklyPrayer/presentation/screens/weekly_prayer_time.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.monthlyPrayerTime,
        builder: (context, state) => const MonthlyPrayerTimeScreen(),
      ),
      GoRoute(
        path: AppRoutes.compassPage,
        builder: (context, state) => const CompassPage(),
      ),
      GoRoute(
        path: AppRoutes.weeklyPrayerTime,
        builder: (context, state) => const WeeklyPrayerTimeScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}
