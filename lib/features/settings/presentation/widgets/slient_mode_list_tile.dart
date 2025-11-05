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
    final appThme = Theme.of(context);
    final prayTimeName = [
      l10nL?.fajr ?? "Fajr",
      l10nL?.sunrise ?? "Sunrise",
      l10nL?.dhuhr ?? "Dhuhr",
      l10nL?.asr ?? "Asr",
      l10nL?.maghrib ?? "Maghrib",
      l10nL?.isha ?? "Isha",
    ];
    return BlocSelector<SettingsCubit, SettingsState, bool>(
      selector: (state) {
        return state.mainSilentModeEnabled;
      },
      builder: (context, mainSilentModeEnabled) {
        return Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: appThme.colorScheme.primary,
              ),
              title: Text(l10nL!.silentMode),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: mainSilentModeEnabled,
                    onChanged: (bool value) {
                      context.read<SettingsCubit>().mainToggleSilentMode();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      mainSilentModeEnabled
                          ? l10nL.notificationOn
                          : l10nL.notificationOff,
                      style: TextStyle(color: appThme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: mainSilentModeEnabled
                  ? _buildCollapsibleContent(context, prayTimeName)
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildCollapsibleContent(
  BuildContext context,
  List<String> prayTimeName,
) {
  final l10nL = AppLocalizations.of(context)!;
  final appTheme = Theme.of(context);

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),

    itemCount: prayTimeName.length,
    itemBuilder: (context, int index) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          leading: Icon(
            Icons.notifications,
            color: appTheme.colorScheme.primary,
          ),
          title: Text(prayTimeName[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  showPickerDialgo(context).then((duration) {});
                },
                child: Text(l10nL.selectTime),
              ),
              Switch(value: true, onChanged: (bool value) {}),

              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  true
                      ? AppLocalizations.of(context)!.notificationOn
                      : AppLocalizations.of(context)!.notificationOff,
                  style: TextStyle(color: appTheme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<Duration?> showPickerDialgo(BuildContext context) {
  Duration selectedDuration = const Duration(minutes: 10);
  final l10nL = AppLocalizations.of(context)!;
  final appTheme = Theme.of(context);

  return showDialog<Duration>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(l10nL.selectTime),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 200,
              width: 300,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: selectedDuration,
                minuteInterval: 5,
                onTimerDurationChanged: (Duration newDuration) {
                  selectedDuration = newDuration;
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text(l10nL.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(l10nL.done),
            onPressed: () {
              Navigator.of(context).pop(selectedDuration);
            },
          ),
        ],
      );
    },
  );
}
