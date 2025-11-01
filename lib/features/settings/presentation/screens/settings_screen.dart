import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;
    final appTheme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: l10nL.settingsPageTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: const Icon(Icons.mosque, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Icon(Icons.settings, size: 100, color: appTheme.colorScheme.primary),
          Divider(
            height: 30,
            thickness: 5,
            color: appTheme.colorScheme.primary,
          ),
          // Tema
          BlocSelector<SettingsCubit, SettingsState, bool>(
            selector: (state) {
              return state.isDarkMode;
            },
            builder: (context, isDarkMode) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return SwitchListTile(
                    value: isDarkMode,
                    inactiveThumbColor: appTheme.colorScheme.primary,
                    onChanged: (bool value) {
                      // Tema değiştirme
                      context.read<SettingsCubit>().toggleDarkMode();
                    },
                    secondary: Icon(
                      Icons.brightness_6,
                      color: appTheme.colorScheme.primary,
                    ),
                    title: Text(l10nL.darkMode),
                  );
                },
              );
            },
          ),
          Divider(color: appTheme.colorScheme.primary),

          // Dil Seçeneği
          BlocSelector<SettingsCubit, SettingsState, String>(
            selector: (state) {
              return state.languageCode;
            },
            builder: (context, languageCode) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return ListTile(
                    leading: Icon(
                      Icons.language,
                      color: appTheme.colorScheme.primary,
                    ),
                    title: Text(l10nL.language),
                    subtitle: Text(
                      languageCode == 'en'
                          ? 'English'
                          : languageCode == 'tr'
                          ? 'Türkçe'
                          : 'Unknown',
                    ),
                    onTap: () {
                      _showLanguageSelectionDialog(context);
                    },
                  );
                },
              );
            },
          ),
          Divider(color: appTheme.colorScheme.primary),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    //Her dil, diğer her dilde aynı gözükmesi için HardCoded girildi
    final l10nL = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10nL.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.read<SettingsCubit>().changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Türkçe'),
                onTap: () {
                  context.read<SettingsCubit>().changeLanguage('tr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
