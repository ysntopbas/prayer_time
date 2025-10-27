import 'package:flutter/material.dart';
import 'package:prayer_time/features/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/core/widgets/custom_drawer.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.homePageTitle),
      drawer: CustomDrawer(),
      body: Center(child: Text(l10n.welcomeMessage)),
    );
  }
}
