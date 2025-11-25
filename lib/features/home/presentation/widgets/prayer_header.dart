import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class PrayerHeader extends StatelessWidget {
  final String subAdministrativeArea;
  final String cityName;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const PrayerHeader({
    super.key,
    required this.subAdministrativeArea,
    required this.cityName,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat(
      'EEEE, MMMM d, yyyy',
      Localizations.localeOf(context).languageCode,
    );
    final appTheme = Theme.of(context);
    final l10nL = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appTheme.colorScheme.primary,
              appTheme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10nL.headerTitle,
                  style: appTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  '$subAdministrativeArea, $cityName',
                  style: appTheme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(now),
                  style: appTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mosque, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
