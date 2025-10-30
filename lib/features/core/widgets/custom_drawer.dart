import 'package:flutter/material.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/screens/calendar_screen.dart';
import 'package:prayer_time/features/home/presentation/screens/home_screen.dart';
import 'package:prayer_time/features/settings/presentation/screens/settings_screen.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              l10n.drawerTitle,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l10n.drawerHomePageTile),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.drawerSettingsPageTile),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(l10n.drawermonthlyPrayerTimePageTile),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlyPrayerTimeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
