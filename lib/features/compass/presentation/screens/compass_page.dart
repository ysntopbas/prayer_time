import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/compass/presentation/widgets/compass_widget.dart';
import 'package:prayer_time/features/compass/presentation/widgets/direction_indicator.dart';
import 'package:prayer_time/features/compass/presentation/widgets/qiblah_info_card.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  final LocationService _locationService = LocationService();

  // Kabe koordinatları (Mekke) - Daha hassas koordinatlar
  static const double kaabaLatitude = 21.4224779;
  static const double kaabaLongitude = 39.8251832;

  Position? _currentPosition;
  double? _qiblahDirection;
  double _currentHeading = 0;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // Konum izni kontrolü
      final hasPermission = await _locationService.handleLocationPermission();

      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
            _errorMessage = 'Konum izni gerekli';
          });
        }
        return;
      }

      // Konum bilgisini al
      final position = await _locationService.getCurrentPosition();

      if (position == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Konum bilgisi alınamadı';
          });
        }
        return;
      }

      // Kıble açısını hesapla
      final qiblahAngle = _calculateQiblahDirection(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _hasPermission = true;
          _currentPosition = position;
          _qiblahDirection = qiblahAngle;
          _isLoading = false;
        });

        // Pusula akışını başlat
        _startCompassListener();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Hata: $e';
        });
      }
    }
  }

  void _startCompassListener() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null && mounted) {
        setState(() {
          _currentHeading = event.heading!;
        });
      }
    });
  }

  /// Kıble yönünü hesaplar
  /// Haversine formülü kullanılarak hesaplanır
  double _calculateQiblahDirection(double latitude, double longitude) {
    // Koordinatları radyana çevir
    final lat1 = _degreesToRadians(latitude);
    final lon1 = _degreesToRadians(longitude);
    final lat2 = _degreesToRadians(kaabaLatitude);
    final lon2 = _degreesToRadians(kaabaLongitude);

    // Boylam farkı
    final deltaLon = lon2 - lon1;

    // Kıble açısını hesapla (bearing formülü)
    final y = sin(deltaLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);

    // atan2 ile açıyı hesapla
    var bearing = atan2(y, x);

    // Radyandan dereceye çevir
    bearing = _radiansToDegrees(bearing);

    // 0-360 aralığına normalize et
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;
  double _radiansToDegrees(double radians) => radians * 180 / pi;

  Future<bool> _onWillPop() async {
    // Yükleme devam ediyorsa geri gitmeyi engelle
    if (_isLoading) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // ignore: deprecated_member_use SONRA GÜNCELLENECEK
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.compassTile,
          leading: _isLoading
              ? const SizedBox.shrink() // Yükleme sırasında geri tuşunu gizle
              : const BackButton(),
          actions: const [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.mosque, color: Colors.white, size: 28),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : !_hasPermission ||
                    _currentPosition == null ||
                    _qiblahDirection == null
              ? _buildErrorWidget(_errorMessage ?? 'Konum bilgisi alınamadı')
              : _buildCompassContent(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initialize();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              QiblahInfoCard(
                currentPosition: _currentPosition!,
                qiblahDirection: _qiblahDirection!,
                currentHeading: _currentHeading,
              ),
              const SizedBox(height: 40),
              CompassWidget(
                qiblahDirection: _qiblahDirection!,
                currentHeading: _currentHeading,
              ),
              const SizedBox(height: 40),
              DirectionIndicator(
                qiblahDirection: _qiblahDirection!,
                currentHeading: _currentHeading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildDirectionMarker(String direction, double angle, Color color) {
  return Transform.rotate(
    angle: angle * (pi / 180),
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Transform.rotate(
          angle: -angle * (pi / 180),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              direction,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildDegreeMarker(int degree) {
  return Transform.rotate(
    angle: degree * (pi / 180),
    child: Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 2,
        height: 8,
        color: Colors.grey[400],
      ),
    ),
  );
}
