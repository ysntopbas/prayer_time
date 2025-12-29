import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/widgets/searchable_bottom_sheet.dart';
import 'package:prayer_time/core/widgets/selection_list_tile.dart';
import 'package:prayer_time/features/settings/data/models/city_model.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class CitySelection extends StatelessWidget {
  const CitySelection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = Theme.of(context);

    // İlk yüklemede şehirleri çek
    context.read<SettingsCubit>().loadCities();

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.cities != current.cities ||
          previous.isCitiesLoading != current.isCitiesLoading ||
          previous.citiesError != current.citiesError ||
          previous.selectedCity != current.selectedCity ||
          previous.selectedCounty != current.selectedCounty ||
          previous.isLocationLoading != current.isLocationLoading,
      builder: (context, state) {
        if (state.isCitiesLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.citiesError != null) {
          return _buildErrorWidget(context, state.citiesError!, l10n);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                l10n.manualLocationSelection,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),

              // 1. Country Selection (Locked)
              SelectionListTile.locked(
                title: l10n.turkey,
                subtitle: l10n.country,
                leading: const Text("🇹🇷", style: TextStyle(fontSize: 24)),
                backgroundColor: appTheme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),

              // 2. City Selection
              SelectionListTile.withIcon(
                title: state.selectedCity?.displayName ?? l10n.selectCity,
                subtitle: l10n.city,
                icon: Icons.location_city,
                iconColor: appTheme.colorScheme.primary,
                onTap: () => _showCitySelectionSheet(context, state.cities),
              ),
              const SizedBox(height: 12),

              // 3. County Selection
              SelectionListTile.withIcon(
                title: state.selectedCounty ?? l10n.selectDistrict,
                subtitle: l10n.district,
                icon: Icons.location_on,
                iconColor: state.selectedCity == null
                    ? Colors.grey
                    : Colors.orange,
                isEnabled: state.selectedCity != null,
                backgroundColor: state.selectedCity == null
                    ? Colors.grey[100]
                    : null,
                onTap: state.selectedCity == null
                    ? () => _showSelectCityFirstMessage(context, l10n)
                    : () => _showCountySelectionSheet(
                        context,
                        state.selectedCity!,
                      ),
              ),

              // Selected Location Display & Save Button
              if (state.selectedCity != null && state.selectedCounty != null)
                _buildSelectedLocationCard(context, state, appTheme, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String error,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<SettingsCubit>().loadCities(),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLocationCard(
    BuildContext context,
    SettingsState state,
    ThemeData appTheme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appTheme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: appTheme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                color: appTheme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectedLocation,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.selectedCity!.displayName} / ${state.selectedCounty}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appTheme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isLocationLoading
                ? null
                : () => _saveLocation(context),
            icon: state.isLocationLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(l10n.saveLocation),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectCityFirstMessage(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectCityFirst)));
  }

  void _showCitySelectionSheet(BuildContext context, List<CityModel> cities) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = Theme.of(context);
    final cubit = context.read<SettingsCubit>();

    SearchableBottomSheet.show<CityModel>(
      context: context,
      title: l10n.selectCity,
      searchHint: l10n.searchCity,
      items: cities,
      onSearch: (query) => cubit.searchCities(query),
      onItemSelected: (city) => cubit.selectCity(city),
      itemBuilder: (context, city, onTap) => ListTile(
        leading: CircleAvatar(
          backgroundColor: appTheme.colorScheme.primary.withValues(alpha: 0.1),
          child: Text(
            city.plate,
            style: TextStyle(
              color: appTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(city.displayName),
        subtitle: Text('${city.counties.length} ${l10n.districts}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showCountySelectionSheet(BuildContext context, CityModel city) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SettingsCubit>();

    final counties = city.counties
        .map((c) => CityModel.capitalizeCounty(c))
        .toList();

    SearchableBottomSheet.show<String>(
      context: context,
      title: '${city.displayName} ${l10n.districts}',
      searchHint: l10n.searchDistrict,
      items: counties,
      onSearchSync: (query) => cubit.searchCounties(query),
      onItemSelected: (county) => cubit.selectCounty(county),
      itemBuilder: (context, county, onTap) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: const Icon(Icons.location_on, color: Colors.orange),
        ),
        title: Text(county),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _saveLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<SettingsCubit>();

    try {
      await cubit.saveSelectedLocation();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.locationSaved),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.locationSaveError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
