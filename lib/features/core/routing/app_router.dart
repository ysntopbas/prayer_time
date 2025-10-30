import 'package:go_router/go_router.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/screens/calendar_screen.dart';
import 'package:prayer_time/features/core/routing/app_routes.dart';
import 'package:prayer_time/features/home/presentation/screens/home_screen.dart';
import 'package:prayer_time/features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
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
    ],
  );
}
