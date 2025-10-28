import 'package:flutter/material.dart';
import 'package:prayer_time/features/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.calendarPageTitle,
        leading: const BackButton(),
      ),
      body: const Center(child: Text('Calendar Page')),
    );
  }
}
