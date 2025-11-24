import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/settings/extensions/settings_cubit_extension.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class NotificationSwitchListTile extends StatelessWidget {
  const NotificationSwitchListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context);
    final appTheme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final mainNotificationsEnabled = state.mainNotificationsEnabled;

        return Column(
          children: [
            // Ana Switch
            ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: appTheme.colorScheme.primary,
              ),
              title: Text(l10nL!.notificationBeforePrayTime),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: mainNotificationsEnabled,
                    onChanged: (value) {
                      context.read<SettingsCubit>().mainToggleNotifications();
                    },
                  ),
                  Icon(
                    mainNotificationsEnabled
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),

            // Alt Ayarlar (Expandable)
            if (mainNotificationsEnabled)
              _buildPrayerNotificationSettings(
                context,
                state,
                mainNotificationsEnabled,
                l10nL,
                appTheme,
              ),
          ],
        );
      },
    );
  }

  Widget _buildPrayerNotificationSettings(
    BuildContext context,
    SettingsState state,
    bool mainEnabled,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final prayers = {
      PrayerType.fajr: (l10n.fajr, state.notificationBeforePraysSettings.fajr),
      PrayerType.sunrise: (
        l10n.sunrise,
        state.notificationBeforePraysSettings.sunrise,
      ),
      PrayerType.dhuhr: (
        l10n.dhuhr,
        state.notificationBeforePraysSettings.dhuhr,
      ),
      PrayerType.asr: (l10n.asr, state.notificationBeforePraysSettings.asr),
      PrayerType.maghrib: (
        l10n.maghrib,
        state.notificationBeforePraysSettings.maghrib,
      ),
      PrayerType.isha: (l10n.isha, state.notificationBeforePraysSettings.isha),
    };

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: prayers.entries.map((entry) {
          final prayerType = entry.key;
          final prayerName = entry.value.$1;
          final prayerSettings = entry.value.$2;

          return Column(
            children: [
              // Ana ListTile (Namaz adı + Switch)
              ListTile(
                leading: Icon(
                  Icons.alarm,
                  color: prayerSettings.isEnabled && mainEnabled
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
                title: Text(
                  prayerName,
                  style: TextStyle(color: mainEnabled ? null : Colors.grey),
                ),
                trailing: Opacity(
                  opacity: mainEnabled ? 1.0 : 0.5,
                  child: Switch(
                    value: prayerSettings.isEnabled,
                    onChanged: mainEnabled
                        ? (value) {
                            context
                                .read<SettingsCubit>()
                                .updateNotificationSetting(
                                  prayerType: prayerType,
                                  isEnabled: value,
                                );
                          }
                        : null,
                  ),
                ),
              ),

              if (prayerSettings.isEnabled && mainEnabled)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        _showMinutePicker(
                          context,
                          prayerType,
                          prayerSettings.minutesBefore,
                          l10n,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.before,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${prayerSettings.minutesBefore} ${l10n.minutes}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showMinutePicker(
    BuildContext context,
    PrayerType prayerType,
    int currentMinutes,
    AppLocalizations l10n,
  ) {
    int selectedMinutes = currentMinutes;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectTime),
          content: SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: (currentMinutes ~/ 5).clamp(0, 12),
              ),
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                selectedMinutes = (index) * 5;
              },
              children: List<Widget>.generate(13, (index) {
                final minutes = (index) * 5;
                return Center(
                  child: Text(
                    '$minutes ${l10n.minutes}',
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final minutesToSave = selectedMinutes == 0
                    ? 0
                    : selectedMinutes;

                context.read<SettingsCubit>().updateNotificationSetting(
                  prayerType: prayerType,
                  minutesBefore: minutesToSave,
                );
                Navigator.pop(context);
              },
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }
}
