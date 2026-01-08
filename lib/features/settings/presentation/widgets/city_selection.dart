import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
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
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
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
                  color: AppTheme.textWhite60,
                ),
              ),
              const SizedBox(height: 10),

              // 1. Country Selection (Locked)
              SelectionListTile.locked(
                title: l10n.turkey,
                subtitle: l10n.country,
                leading: const Text("🇹🇷", style: TextStyle(fontSize: 24)),
                backgroundColor: AppTheme.chipBackground,
              ),
              const SizedBox(height: 12),

              // 2. City Selection
              SelectionListTile.withIcon(
                title: state.selectedCity?.displayName ?? l10n.selectCity,
                subtitle: l10n.city,
                icon: Icons.location_city,
                iconColor: AppTheme.primaryGreen,
                onTap: () => _showCitySelectionSheet(context, state.cities),
              ),
              const SizedBox(height: 12),

              // 3. County Selection
              SelectionListTile.withIcon(
                title: state.selectedCounty ?? l10n.selectDistrict,
                subtitle: l10n.district,
                icon: Icons.location_on,
                iconColor: state.selectedCity == null ? null : Colors.orange,
                isEnabled: state.selectedCity != null,
                onTap: state.selectedCity == null
                    ? () => _showSelectCityFirstMessage(context, l10n)
                    : () => _showCountySelectionSheet(
                        context,
                        state.selectedCity!,
                      ),
              ),

              // Selected Location Display & Save Button
              if (state.selectedCity != null && state.selectedCounty != null)
                _buildSelectedLocationCard(context, state, l10n),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: Text(
                l10n.tryAgain,
                style: const TextStyle(color: AppTheme.textWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLocationCard(
    BuildContext context,
    SettingsState state,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.chipActiveBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.chipActiveBorderColor),
          ),
          child: Column(
            children: [
              Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 32),
              const SizedBox(height: 8),
              Text(
                l10n.selectedLocation,
                style: TextStyle(fontSize: 12, color: AppTheme.textWhite60),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.selectedCity!.displayName} / ${state.selectedCounty}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textWhite,
                    ),
                  )
                : const Icon(Icons.save, color: AppTheme.textWhite),
            label: Text(
              l10n.saveLocation,
              style: const TextStyle(color: AppTheme.textWhite),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pleaseSelectCityFirst),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showCitySelectionSheet(BuildContext context, List<CityModel> cities) {
    final l10n = AppLocalizations.of(context)!;
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
          backgroundColor: AppTheme.chipActiveBackground,
          child: Text(
            city.plate,
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          city.displayName,
          style: const TextStyle(color: AppTheme.textWhite),
        ),
        subtitle: Text(
          '${city.counties.length} ${l10n.districts}',
          style: TextStyle(color: AppTheme.textWhite60),
        ),
        trailing: Icon(Icons.chevron_right, color: AppTheme.textWhite60),
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
        title: Text(county, style: const TextStyle(color: AppTheme.textWhite)),
        trailing: Icon(Icons.chevron_right, color: AppTheme.textWhite60),
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
          backgroundColor: AppTheme.primaryGreen,
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
