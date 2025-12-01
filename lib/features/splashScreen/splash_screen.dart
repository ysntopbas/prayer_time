import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    // Kullanıcı logoyu en az 2 saniye görsün
    final elapsedTime = DateTime.now().difference(_startTime!);
    final remainingTime = const Duration(seconds: 2) - elapsedTime;

    if (remainingTime.inMilliseconds > 0) {
      await Future.delayed(remainingTime);
    }

    if (!mounted) return;

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded && !_dataLoaded) {
          _dataLoaded = true;
          _navigateToHome();
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE5C8), Color(0xFF56987F)],
            ),
          ),
          child: Stack(
            children: [
              // Logo Katmanı
              Center(
                child: SvgPicture.asset(
                  "assets/splashScreen/splashScreen.svg",

                  // BoxFit.contain
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),

              // Yükleniyor Çubuğu Katmanı
              const Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
