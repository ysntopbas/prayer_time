import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppTheme.getBackgroundColor(context), // DEĞİŞTİ
      child: Column(
        children: [
          // Modern gradient drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.getDrawerGradientStart(context), // DEĞİŞTİ
                  AppTheme.getDrawerGradientEnd(context), // DEĞİŞTİ
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
                    color: AppTheme.textWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppTheme.textWhite,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10nL.drawerTitle,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 22,
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

                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppTheme.cardBorderColor,
                ),
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
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.getBorderColor(context)), // DEĞİŞTİ
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.getTertiaryTextColor(context), // DEĞİŞTİ
                  size: 18,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${l10nL.version} 1.0.0",
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context), // DEĞİŞTİ
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      l10nL.ownerName,
                      style: TextStyle(
                        color: AppTheme.getTertiaryTextColor(context), // DEĞİŞTİ
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
