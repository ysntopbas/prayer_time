import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:prayer_time/core/routing/app_routes.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DateTime? _startTime;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // HomeCubit'i tetikle
    final settingsCubit = context.read<SettingsCubit>();
    final savedLocation = settingsCubit.getSavedLocation();

    context.read<HomeCubit>().fetchPrayerTimes(
      savedLocation: savedLocation,
      context: context,
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    if (_startTime == null) return;

    final elapsedTime = DateTime.now().difference(_startTime!);
    final remainingTime = const Duration(seconds: 2) - elapsedTime;

    if (remainingTime.inMilliseconds > 0) {
      await Future.delayed(remainingTime);
    }

    if (!mounted) return;

    log('Navigating to HomeScreen');
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        log('Current state: ${state.runtimeType}');

        if (state is HomeLoaded && !_dataLoaded) {
          _dataLoaded = true;
          _navigateToHome();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFE5C8),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/splashScreen/splashScreen.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
