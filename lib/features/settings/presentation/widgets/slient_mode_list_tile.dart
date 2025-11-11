import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class SilentModeListTile extends StatelessWidget {
  const SilentModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context);
    final appTheme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final mainSilentModeEnabled = state.mainSilentModeEnabled;

        return Column(
          children: [
            // Ana Switch
            ListTile(
              leading: Icon(
                Icons.volume_off,
                color: appTheme.colorScheme.primary,
              ),
              title: Text(l10nL!.silentMode),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: mainSilentModeEnabled,
                    onChanged: (value) {
                      context.read<SettingsCubit>().mainToggleSilentMode();
                    },
                  ),
                  Icon(
                    mainSilentModeEnabled
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),

            // Alt Ayarlar
            if (mainSilentModeEnabled)
              _buildPrayerSilentModeSettings(
                context,
                state,
                mainSilentModeEnabled,
                l10nL,
                appTheme,
              ),
          ],
        );
      },
    );
  }

  Widget _buildPrayerSilentModeSettings(
    BuildContext context,
    SettingsState state,
    bool mainEnabled,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final prayers = {
      'fajr': (l10n.fajr, state.silentModeDuringPraysSettings.fajr),
      'sunrise': (l10n.sunrise, state.silentModeDuringPraysSettings.sunrise),
      'dhuhr': (l10n.dhuhr, state.silentModeDuringPraysSettings.dhuhr),
      'asr': (l10n.asr, state.silentModeDuringPraysSettings.asr),
      'maghrib': (l10n.maghrib, state.silentModeDuringPraysSettings.maghrib),
      'isha': (l10n.isha, state.silentModeDuringPraysSettings.isha),
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
          final prayerKey = entry.key;
          final prayerName = entry.value.$1;
          final prayerSettings = entry.value.$2;

          return ExpansionTile(
            leading: Icon(
              Icons.volume_off,
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
                        context.read<SettingsCubit>().updateSilentModeSetting(
                          prayerName: prayerKey,
                          isEnabled: value,
                        );
                      }
                    : null,
              ),
            ),
            children: [
              // Before Duration
              ListTile(
                title: Text('${l10n.before} (${l10n.minutes})'),
                trailing: TextButton(
                  onPressed: mainEnabled && prayerSettings.isEnabled
                      ? () {
                          _showDurationPicker(
                            context,
                            prayerKey,
                            prayerSettings.minutesBefore,
                            true,
                            l10n,
                          );
                        }
                      : null,
                  child: Text(
                    '${prayerSettings.minutesBefore} ${l10n.minutes}',
                    style: TextStyle(
                      color: mainEnabled && prayerSettings.isEnabled
                          ? theme.colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ),
              ),

              // After Duration
              ListTile(
                title: Text('${l10n.after} (${l10n.minutes})'),
                trailing: TextButton(
                  onPressed: mainEnabled && prayerSettings.isEnabled
                      ? () {
                          _showDurationPicker(
                            context,
                            prayerKey,
                            prayerSettings.minutesAfter,
                            false,
                            l10n,
                          );
                        }
                      : null,
                  child: Text(
                    '${prayerSettings.minutesAfter} ${l10n.minutes}',
                    style: TextStyle(
                      color: mainEnabled && prayerSettings.isEnabled
                          ? theme.colorScheme.primary
                          : Colors.grey,
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

  void _showDurationPicker(
    BuildContext context,
    String prayerKey,
    int currentMinutes,
    bool isBefore,
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
                initialItem: (currentMinutes ~/ 5) - 1,
              ),
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                selectedMinutes = (index + 1) * 5;
              },
              children: List<Widget>.generate(24, (index) {
                final minutes = (index + 1) * 5;
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
                context.read<SettingsCubit>().updateSilentModeSetting(
                  prayerName: prayerKey,
                  minutesBefore: isBefore ? selectedMinutes : null,
                  minutesAfter: !isBefore ? selectedMinutes : null,
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
