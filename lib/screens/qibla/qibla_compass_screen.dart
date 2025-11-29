import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/utlis/thems/colors.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  bool _hasPermission = false;
  bool _isLoading = true;
  double? _qiblaDirection;
  double? _currentHeading;
  double? _smoothedHeading;
  Position? _currentPosition;
  StreamSubscription<CompassEvent>? _compassSubscription;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  String? _errorMessage;

  // AR Mode
  bool _arModeEnabled = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  // Calibration
  bool _isCalibrating = false;
  int _calibrationAccuracy = 0; // 0-3 (low to high)

  // Low-pass filter for smoother compass readings
  static const double _smoothingFactor = 0.12; // Lower = smoother but slower

  // Sensor Fusion
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _pitch = 0.0; // Device tilt forward/backward
  double _roll = 0.0; // Device tilt left/right
  bool _isDeviceFlat = true;
  static const double _flatThreshold = 0.3; // Radians (~17 degrees)

  // Kabe koordinatları
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeCompass();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCompass() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Konum izni kontrolü
    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
        _errorMessage = 'location_permission_required';
      });
      return;
    }

    // Konum servisi kontrolü
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'location_service_disabled';
      });
      return;
    }

    try {
      // Mevcut konumu al
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Kıble yönünü hesapla
      _qiblaDirection = _calculateQiblaDirection(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      setState(() {
        _hasPermission = true;
      });

      // Pusula dinleyicisini başlat
      _startCompassListener();
      _startAccelerometerListener(); // Sensor Fusion için
    } catch (e) {
      setState(() {
        _errorMessage = 'location_fetch_error';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Accelerometer listener for Sensor Fusion
  /// Detects device orientation to improve compass accuracy
  void _startAccelerometerListener() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;

      // Calculate pitch and roll from accelerometer data
      final ax = event.x;
      final ay = event.y;
      final az = event.z;

      // Calculate device orientation angles
      _pitch = math.atan2(-ax, math.sqrt(ay * ay + az * az));
      _roll = math.atan2(ay, az);

      // Determine if device is held flat (for optimal compass reading)
      final tiltAngle = math.sqrt(_pitch * _pitch + _roll * _roll);
      _isDeviceFlat = tiltAngle < _flatThreshold;

      // Reduce compass smoothing when device is not flat
      // This helps maintain responsiveness during movement
    });
  }

  void _startCompassListener() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        // Apply low-pass filter for smoother readings
        // Use dynamic smoothing based on device orientation
        final dynamicSmoothing =
            _isDeviceFlat ? _smoothingFactor : _smoothingFactor * 1.5;

        final newHeading = event.heading!;
        if (_smoothedHeading == null) {
          _smoothedHeading = newHeading;
        } else {
          // Handle angle wraparound with circular mean
          double diff = newHeading - _smoothedHeading!;
          if (diff > 180) diff -= 360;
          if (diff < -180) diff += 360;
          _smoothedHeading =
              (_smoothedHeading! + diff * dynamicSmoothing) % 360;
          if (_smoothedHeading! < 0) _smoothedHeading = _smoothedHeading! + 360;
        }

        // Get accuracy from event (if available)
        _calibrationAccuracy = _getAccuracyLevel(event.accuracy);

        setState(() {
          _currentHeading = _smoothedHeading;
        });
      }
    });
  }

  int _getAccuracyLevel(double? accuracy) {
    if (accuracy == null) return 1;
    if (accuracy < 15) return 3; // High accuracy
    if (accuracy < 30) return 2; // Medium accuracy
    if (accuracy < 45) return 1; // Low accuracy
    return 0; // Unreliable
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _toggleARMode() async {
    if (_arModeEnabled) {
      // Disable AR mode
      await _cameraController?.dispose();
      setState(() {
        _arModeEnabled = false;
        _isCameraInitialized = false;
        _cameraController = null;
      });
    } else {
      // Enable AR mode - request camera permission first
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isGranted) {
        await _initializeCamera();
        setState(() {
          _arModeEnabled = true;
        });
      } else {
        if (mounted) {
          final localization = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization.qiblaLocationPermissionRequired),
            ),
          );
        }
      }
    }
  }

  void _startCalibration() {
    setState(() {
      _isCalibrating = true;
    });

    // Show calibration dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _CalibrationDialog(
            onComplete: () {
              setState(() {
                _isCalibrating = false;
              });
              Navigator.of(context).pop();
            },
          ),
    );
  }

  /// Kıble yönünü hesapla (derece cinsinden)
  double _calculateQiblaDirection(double latitude, double longitude) {
    final lat1 = latitude * math.pi / 180;
    final lon1 = longitude * math.pi / 180;
    const lat2 = _kaabaLatitude * math.pi / 180;
    const lon2 = _kaabaLongitude * math.pi / 180;

    final dLon = lon2 - lon1;

    final y = math.sin(dLon);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLon);

    var qibla = math.atan2(y, x) * 180 / math.pi;
    qibla = (qibla + 360) % 360;

    return qibla;
  }

  double get _needleRotation {
    if (_currentHeading == null || _qiblaDirection == null) return 0;
    return (_qiblaDirection! - _currentHeading!) * (math.pi / 180);
  }

  bool get _isFacingQibla {
    if (_currentHeading == null || _qiblaDirection == null) return false;
    final diff = ((_qiblaDirection! - _currentHeading!) % 360 + 360) % 360;
    return diff < 5 || diff > 355;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return _buildLoadingView(localization);
    }

    if (_errorMessage != null) {
      return _buildErrorView(localization, _errorMessage!);
    }

    if (!_hasPermission) {
      return _buildPermissionView(localization);
    }

    return Scaffold(
      backgroundColor:
          _arModeEnabled ? Colors.transparent : AppColors.background,
      body: Stack(
        children: [
          // AR Camera Background
          if (_arModeEnabled &&
              _isCameraInitialized &&
              _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Başlık ve kontroller
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Calibration button
                      _buildControlButton(
                        icon: Icons.tune,
                        label: localization.calibrateCompass,
                        onTap: _startCalibration,
                        isActive: _isCalibrating,
                      ),
                      // Title
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              localization.qiblaCompassTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    _arModeEnabled
                                        ? Colors.white
                                        : AppColors.primary,
                                shadows:
                                    _arModeEnabled
                                        ? [
                                          const Shadow(
                                            color: Colors.black,
                                            blurRadius: 4,
                                          ),
                                        ]
                                        : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localization.qiblaCompassSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    _arModeEnabled
                                        ? Colors.white70
                                        : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // AR Mode button
                      _buildControlButton(
                        icon:
                            _arModeEnabled
                                ? Icons.camera_alt
                                : Icons.camera_alt_outlined,
                        label: localization.arMode,
                        onTap: _toggleARMode,
                        isActive: _arModeEnabled,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Accuracy indicator
                _buildAccuracyIndicator(localization),

                const SizedBox(height: 12),

                // Yön bilgisi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isFacingQibla
                            ? Colors.green.withValues(
                              alpha: _arModeEnabled ? 0.8 : 0.1,
                            )
                            : (_arModeEnabled
                                ? Colors.black.withValues(alpha: 0.5)
                                : AppColors.primary.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isFacingQibla ? Colors.green : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFacingQibla ? Icons.check_circle : Icons.explore,
                        color:
                            _isFacingQibla
                                ? Colors.green
                                : (_arModeEnabled
                                    ? Colors.white
                                    : AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isFacingQibla
                            ? localization.qiblaFacingCorrect
                            : '${_qiblaDirection?.toStringAsFixed(1)}°',
                        style: TextStyle(
                          color:
                              _isFacingQibla
                                  ? Colors.green
                                  : (_arModeEnabled
                                      ? Colors.white
                                      : AppColors.primary),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pusula
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isFacingQibla ? _pulseAnimation.value : 1.0,
                          child: child,
                        );
                      },
                      child:
                          _arModeEnabled ? _buildARCompass() : _buildCompass(),
                    ),
                  ),
                ),

                // Alt bilgi (hide in AR mode for cleaner view)
                if (!_arModeEnabled)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localization.qiblaYourLocation,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentPosition?.latitude.toStringAsFixed(4)}°, ${_currentPosition?.longitude.toStringAsFixed(4)}°',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mosque,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localization.qiblaKaabaDirection,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_qiblaDirection?.toStringAsFixed(2)}° ${_getDirectionName(localization)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // AR mode bottom info
                if (_arModeEnabled)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_android,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localization.holdVertical,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.primary
                  : (_arModeEnabled
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? Colors.white
                      : (_arModeEnabled ? Colors.white : AppColors.primary),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    isActive
                        ? Colors.white
                        : (_arModeEnabled ? Colors.white70 : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyIndicator(AppLocalizations localization) {
    final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green];
    final labels = ['Low', 'Medium', 'Good', 'High'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color:
            _arModeEnabled ? Colors.black.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            _arModeEnabled
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Accuracy: ',
            style: TextStyle(
              fontSize: 12,
              color: _arModeEnabled ? Colors.white70 : Colors.grey[600],
            ),
          ),
          ...List.generate(
            4,
            (index) => Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index <= _calibrationAccuracy
                        ? colors[_calibrationAccuracy]
                        : Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            labels[_calibrationAccuracy],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors[_calibrationAccuracy],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildARCompass() {
    // Simplified compass overlay for AR mode
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-transparent circle
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(
                color: _isFacingQibla ? Colors.green : Colors.white,
                width: 3,
              ),
            ),
          ),
          // Rotating compass with arrow pointing to Qibla
          Transform.rotate(
            angle: _needleRotation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Qibla arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isFacingQibla ? Colors.green : AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                Container(
                  width: 4,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isFacingQibla ? Colors.green : AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dış halka
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primaryLight.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // İç pusula
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: -(_currentHeading ?? 0) * (math.pi / 180),
              child: CustomPaint(
                painter: CompassPainter(
                  qiblaDirection: _qiblaDirection ?? 0,
                  primaryColor: AppColors.primary,
                  accentColor: AppColors.accent,
                ),
              ),
            ),
          ),
          // Merkez nokta
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isFacingQibla ? Colors.green : AppColors.accent,
              boxShadow: [
                BoxShadow(
                  color: (_isFacingQibla ? Colors.green : AppColors.accent)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectionName(AppLocalizations localization) {
    if (_qiblaDirection == null) return '';
    final dir = _qiblaDirection!;
    if (dir >= 337.5 || dir < 22.5) return localization.directionNorth;
    if (dir >= 22.5 && dir < 67.5) return localization.directionNorthEast;
    if (dir >= 67.5 && dir < 112.5) return localization.directionEast;
    if (dir >= 112.5 && dir < 157.5) return localization.directionSouthEast;
    if (dir >= 157.5 && dir < 202.5) return localization.directionSouth;
    if (dir >= 202.5 && dir < 247.5) return localization.directionSouthWest;
    if (dir >= 247.5 && dir < 292.5) return localization.directionWest;
    return localization.directionNorthWest;
  }

  Widget _buildLoadingView(AppLocalizations localization) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              localization.qiblaLoading,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations localization, String error) {
    String message;
    switch (error) {
      case 'location_permission_required':
        message = localization.qiblaLocationPermissionRequired;
        break;
      case 'location_service_disabled':
        message = localization.qiblaLocationServiceDisabled;
        break;
      case 'location_fetch_error':
        message = localization.qiblaLocationFetchError;
        break;
      default:
        message = localization.qiblaGenericError;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeCompass,
                icon: const Icon(Icons.refresh),
                label: Text(localization.qiblaRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionView(AppLocalizations localization) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.orange[400]),
              const SizedBox(height: 24),
              Text(
                localization.qiblaLocationPermissionRequired,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: Text(localization.qiblaOpenSettings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
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

class CompassPainter extends CustomPainter {
  final double qiblaDirection;
  final Color primaryColor;
  final Color accentColor;

  CompassPainter({
    required this.qiblaDirection,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Derece işaretleri
    final tickPaint =
        Paint()
          ..color = Colors.grey[400]!
          ..strokeWidth = 1;

    final majorTickPaint =
        Paint()
          ..color = primaryColor
          ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 5) {
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 15 : 8;
      final angle = i * math.pi / 180;

      final start = Offset(
        center.dx + (radius - tickLength) * math.sin(angle),
        center.dy - (radius - tickLength) * math.cos(angle),
      );
      final end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }

    // Yön harfleri
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0.0, 90.0, 180.0, 270.0];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final textOffset = Offset(
        center.dx + (radius - 35) * math.sin(angle),
        center.dy - (radius - 35) * math.cos(angle),
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: directions[i] == 'N' ? Colors.red : primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Kıble işareti (Kabe ikonu)
    final qiblaAngle = qiblaDirection * math.pi / 180;
    final qiblaIconCenter = Offset(
      center.dx + (radius - 55) * math.sin(qiblaAngle),
      center.dy - (radius - 55) * math.cos(qiblaAngle),
    );

    // Kıble ok
    final qiblaArrowPaint =
        Paint()
          ..color = accentColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final arrowStart = Offset(
      center.dx + 30 * math.sin(qiblaAngle),
      center.dy - 30 * math.cos(qiblaAngle),
    );
    final arrowEnd = Offset(
      center.dx + (radius - 65) * math.sin(qiblaAngle),
      center.dy - (radius - 65) * math.cos(qiblaAngle),
    );

    canvas.drawLine(arrowStart, arrowEnd, qiblaArrowPaint);

    // Ok ucu
    final arrowHeadPath = Path();
    const arrowHeadSize = 12.0;
    final arrowAngle1 = qiblaAngle - math.pi / 6;
    final arrowAngle2 = qiblaAngle + math.pi / 6;

    arrowHeadPath.moveTo(arrowEnd.dx, arrowEnd.dy);
    arrowHeadPath.lineTo(
      arrowEnd.dx - arrowHeadSize * math.sin(arrowAngle1),
      arrowEnd.dy + arrowHeadSize * math.cos(arrowAngle1),
    );
    arrowHeadPath.moveTo(arrowEnd.dx, arrowEnd.dy);
    arrowHeadPath.lineTo(
      arrowEnd.dx - arrowHeadSize * math.sin(arrowAngle2),
      arrowEnd.dy + arrowHeadSize * math.cos(arrowAngle2),
    );

    canvas.drawPath(arrowHeadPath, qiblaArrowPaint);

    // Kabe sembolü
    final kaabaPaint =
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill;

    const kaabaSize = 16.0;
    final kaabaRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: qiblaIconCenter,
        width: kaabaSize,
        height: kaabaSize,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(kaabaRect, kaabaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Calibration Dialog Widget
class _CalibrationDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _CalibrationDialog({required this.onComplete});

  @override
  State<_CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<_CalibrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  int _step = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Auto-advance steps
    _advanceSteps();
  }

  void _advanceSteps() async {
    for (int i = 0; i < _totalSteps; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _step = i + 1;
        });
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Rotating phone animation
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_android,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localization.compassCalibrating,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            localization.calibrateCompassDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSteps, (index) {
              return Container(
                width: 40,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index < _step ? AppColors.primary : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            '${(_step / _totalSteps * 100).toInt()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
