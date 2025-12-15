import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          // Modern gradient drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10nL.drawerTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: l10nL.drawerHomePageTile,
                  onTap: () {
                    context.pop();
                    context.push('/home');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.view_week,
                  title: l10nL.weeklyPrayCalendar,
                  onTap: () {
                    context.pop();
                    context.push('/weekly-prayer-time');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_month_rounded,
                  title: l10nL.drawermonthlyPrayerTimePageTile,
                  onTap: () {
                    context.pop();
                    context.push('/monthly-prayer-time');
                  },
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: l10nL.drawerSettingsPageTile,
                  onTap: () {
                    context.pop();
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.info_outline)],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${l10nL.version} 1.0.0",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        l10nL.ownerName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(bottom: 12)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
