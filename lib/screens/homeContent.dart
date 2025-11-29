import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/bloc/prayer/prayer_bloc.dart';
import 'package:vakit/bloc/prayer/prayer_event.dart';
import 'package:vakit/bloc/prayer/prayer_state.dart';
import 'package:vakit/bloc/profile/profile_cubit.dart';
import 'package:vakit/bloc/location/location_bloc.dart';
import 'package:vakit/bloc/location/location_state.dart';
import 'package:vakit/bloc/tracked_locations/tracked_locations_cubit.dart';
import 'package:vakit/bloc/tracked_locations/tracked_locations_state.dart';
import 'package:vakit/models/prayer_times_model.dart';
import 'package:vakit/models/tracked_location.dart';
import 'package:vakit/screens/locations/cities_dashboard_screen.dart';
import 'package:vakit/services/widget_service.dart';
import 'package:vakit/services/intelligent_notification_service.dart';
import 'package:vakit/utlis/thems/colors.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showAnimation = false;
  String? _lastRequestedLocationId;

  @override
  void initState() {
    super.initState();
    _setupTimer();
    _setupAnimation();
    WidgetService.initializeWidget();
    WidgetService.setupInteractivity();
  }

  void _setupTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        final currentState = context.read<PrayerBloc>().state;
        if (currentState is PrayerLoaded) {
          context.read<PrayerBloc>().add(
            CalculateNextPrayer(currentState.prayerTimes.toMap()),
          );
        }
      }
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).abs();
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    final seconds = duration.inSeconds.remainder(60).abs();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _openCitiesDashboard() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CitiesDashboardScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listenWhen:
                (previous, current) =>
                    current is LocationLoaded || current is LocationError,
            listener: (context, state) {
              if (state is LocationLoaded) {
                final position = Position(
                  latitude: state.latitude,
                  longitude: state.longitude,
                  accuracy: 0,
                  altitude: 0,
                  heading: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  timestamp: DateTime.now(),
                  altitudeAccuracy: 0,
                  headingAccuracy: 0,
                );
                context.read<TrackedLocationsCubit>().syncCurrentLocation(
                  position,
                );
              }
            },
          ),
          BlocListener<TrackedLocationsCubit, TrackedLocationsState>(
            listenWhen: (previous, current) {
              final prevActive = previous.activeLocation;
              final currActive = current.activeLocation;
              if (prevActive == null && currActive != null) {
                return true;
              }
              if (prevActive == null || currActive == null) {
                return false;
              }
              final idChanged =
                  previous.activeLocationId != current.activeLocationId;
              final coordsChanged =
                  prevActive.latitude != currActive.latitude ||
                  prevActive.longitude != currActive.longitude;
              return idChanged || coordsChanged;
            },
            listener: (context, state) {
              final active = state.activeLocation;
              if (active != null &&
                  (_lastRequestedLocationId != active.id ||
                      state.prayerSummaries[active.id] == null)) {
                _lastRequestedLocationId = active.id;
                _loadPrayerDataForLocation(active);
              }
            },
          ),
        ],
        child: BlocBuilder<TrackedLocationsCubit, TrackedLocationsState>(
          builder: (context, trackedState) {
            return BlocConsumer<PrayerBloc, PrayerState>(
              listener: (context, state) {
                if (state is PrayerLoaded) {
                  context.read<ProfileCubit>().scheduleRemindersIfNeeded(
                    state.prayerTimes,
                  );
                  final remaining = state.timeRemaining;
                  if (remaining.inMinutes == 0 && remaining.inSeconds <= 5) {
                    _startPrayerTimeAnimation();
                  }
                  // Widget'ı güncelle
                  WidgetService.updateWidget(
                    context,
                    state.prayerTimes,
                    state.nextPrayer,
                    state.timeRemaining,
                  );

                  // Intelligent notification schedule (nagging & missed prayer tracking)
                  final locale = Localizations.localeOf(context);
                  context
                      .read<IntelligentNotificationService>()
                      .scheduleDailyNotifications(
                        state.prayerTimes,
                        locale.languageCode,
                      );
                }
              },
              builder: (context, prayerState) {
                return SafeArea(
                  child: Center(
                    child: _buildPrayerCircle(
                      prayerState,
                      trackedState,
                      localization,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _loadPrayerDataForLocation(TrackedLocation location) {
    final position = Position(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    context.read<PrayerBloc>().add(LoadPrayerData(position));
  }

  Widget _buildPrayerCircle(
    PrayerState prayerState,
    TrackedLocationsState trackedState,
    AppLocalizations localization,
  ) {
    if (prayerState is PrayerLoading) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      );
    }

    if (prayerState is PrayerLoaded) {
      return PrayerCircle(
        prayerTimes: prayerState.prayerTimes,
        nextPrayerName: prayerState.nextPrayer,
        timeRemaining: prayerState.timeRemaining,
      );
    }

    if (prayerState is PrayerError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '${localization.genericError}: ${prayerState.message}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
    );
  }

  void _startPrayerTimeAnimation() {
    if (!_showAnimation) {
      setState(() {
        _showAnimation = true;
      });

      _animationController.forward().then((_) {
        Future.delayed(Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showAnimation = false;
            });
            _animationController.reset();
          }
        });
      });
    }
  }
}

// PrayerCircle widget remains the same
class PrayerCircle extends StatefulWidget {
  final PrayerTimes? prayerTimes;
  final String? nextPrayerName;
  final Duration? timeRemaining;
  PrayerCircle({this.prayerTimes, this.nextPrayerName, this.timeRemaining});

  @override
  _PrayerCircleState createState() => _PrayerCircleState();
}

class _PrayerCircleState extends State<PrayerCircle>
    with TickerProviderStateMixin {
  final double circleRadius = 175;
  Map<String, bool> boxStates = {};
  final List<String> prayerNames = [
    'Imsak',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  String _getLocalizedPrayerName(String prayerName) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    switch (prayerName) {
      case 'Imsak':
      case 'Fajr':
        if (languageCode == 'tr') return 'İmsak';
        if (languageCode == 'ar') return 'الفجر';
        return 'Fajr';
      case 'Sunrise':
        if (languageCode == 'tr') return 'Güneş';
        if (languageCode == 'ar') return 'الشروق';
        return 'Sunrise';
      case 'Dhuhr':
        if (languageCode == 'tr') return 'Öğle';
        if (languageCode == 'ar') return 'الظهر';
        return 'Dhuhr';
      case 'Asr':
        if (languageCode == 'tr') return 'İkindi';
        if (languageCode == 'ar') return 'العصر';
        return 'Asr';
      case 'Maghrib':
        if (languageCode == 'tr') return 'Akşam';
        if (languageCode == 'ar') return 'المغرب';
        return 'Maghrib';
      case 'Isha':
        if (languageCode == 'tr') return 'Yatsı';
        if (languageCode == 'ar') return 'العشاء';
        return 'Isha';
      default:
        return prayerName;
    }
  }

  late final AnimationController _overlayCtr;
  // Gece yarısı Hicrî tarihi yenilemek için timer
  Timer? _midnightTimer;
  // RN'deki minute-level tetiklemeye daha yakın: aynı dakika içinde tekrar tetiklemeyi engelle
  int? _lastOverlayMinute;
  String? _lastOverlayPrayer;

  @override
  void initState() {
    super.initState();
    print("prayerTimesprayerTimes ${widget.prayerTimes}");

    _overlayCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _overlayCtr.dispose();
    _midnightTimer?.cancel();
    super.dispose();
  }

  List<double> _angles(PrayerTimes? prayerTimes) {
    if (prayerTimes == null) {
      return [];
    }
    DateTime now = DateTime.now();
    DateTime _parseToday(String hhmm) {
      final parts = hhmm.split(':');
      final d = DateTime.now();
      return DateTime(
        d.year,
        d.month,
        d.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    final dayStart = DateTime(now.year, now.month, now.day);
    final aksamMins =
        _parseToday(
          prayerTimes.timings['Maghrib']!,
        ).difference(dayStart).inMinutes;
    const total = 24 * 60;

    return prayerNames.map((n) {
      final mins =
          _parseToday(prayerTimes.timings[n]!).difference(dayStart).inMinutes;
      final diff =
          mins >= aksamMins ? mins - aksamMins : total + mins - aksamMins;
      return (diff / total) * 2 * math.pi; // radians
    }).toList();
  }



  DateTime _parseToday(String hhmm) {
    final parts = hhmm.split(':');
    final d = DateTime.now();
    return DateTime(
      d.year,
      d.month,
      d.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  double _angleFromAksam(PrayerTimes? prayerTimes, DateTime t) {
    if (prayerTimes == null) return 0;
    final aksam = _parseToday(prayerTimes.timings['Maghrib']!);
    const dayMin = 24 * 60;
    int diff = t.difference(aksam).inMinutes;
    if (diff < 0) diff += dayMin;
    return (diff / dayMin) * 2 * math.pi; // radians
  }

  double _timeAngleWithOffset(
    PrayerTimes? prayerTimes,
    String prayer,
    int offsetMin,
  ) {
    if (prayerTimes == null) return 0;

    final timingStr = prayerTimes.timings[prayer];
    if (timingStr == null) {
      return 0;
    }

    final base = _parseToday(timingStr);
    final withOffset = base.add(Duration(minutes: offsetMin));
    return _angleFromAksam(prayerTimes, withOffset);
  }

  String _fmt(Duration d) {
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.prayerTimes == null) {
      return const SizedBox.shrink();
    }

    final farzAngles = _angles(widget.prayerTimes);

    // Ekran boyutuna göre dinamik çember
    final size = MediaQuery.of(context).size;
    final diameter =
        math.min(size.width, size.height) * 0.86; // biraz daha büyük yap
    final circleRadius = diameter / 2;
    final innerRadius = circleRadius * 0.95;

    // RN'e daha yakın: dakika bazlı tetikleme (aynı dakika içinde sadece 1 kez)
    if (widget.nextPrayerName != null && widget.timeRemaining != null) {
      final d = widget.timeRemaining!;
      final sameMinute = d.inMinutes == 0 && !d.isNegative; // bu dakika içinde
      if (sameMinute) {
        if (_lastOverlayPrayer != widget.nextPrayerName ||
            _lastOverlayMinute != now.minute) {
          _lastOverlayPrayer = widget.nextPrayerName;
          _lastOverlayMinute = now.minute;
          if (!_overlayCtr.isAnimating) {
            _overlayCtr.forward(from: 0);
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) _overlayCtr.value = 0;
            });
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hicrî Tarih (üstte, daha belirgin)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      '2025.08.10',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2025.08.10',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Çember ve boyalı alan
              SizedBox(
                width: diameter,
                height: diameter,
                child: CustomPaint(
                  painter: PrayerCirclePainter(
                    angles: farzAngles,
                    prayerNames: prayerNames,
                    nowAngle: _angleFromAksam(widget.prayerTimes, now),
                    kerahatMarkers: [
                      (
                        _timeAngleWithOffset(widget.prayerTimes, 'Sunrise', 45),
                        'Kerahat',
                      ),
                      (
                        _timeAngleWithOffset(widget.prayerTimes, 'Dhuhr', -45),
                        'Kerahat',
                      ),
                      (
                        _timeAngleWithOffset(
                          widget.prayerTimes,
                          'Maghrib',
                          -45,
                        ),
                        'Kerahat',
                      ),
                    ],
                    circleRadius: circleRadius,
                  ),
                ),
              ),

              // Geri sayım çemberin ortasında
              if (widget.prayerTimes != null &&
                  widget.nextPrayerName != null &&
                  widget.timeRemaining != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.nextPrayer,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLocalizedPrayerName(widget.nextPrayerName!),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        final dur = widget.timeRemaining!;
                        final hhmmss = _fmt(dur);
                        return Column(
                          children: [
                            Text(
                              hhmmss,
                              style: const TextStyle(
                                fontSize: 34,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "",
                              style: const TextStyle(
                                fontSize: 42,
                                color: Colors.black87,
                                fontFamily: 'Arial',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.remaining,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

              // Farz kutucuklar
              if (farzAngles.isNotEmpty)
                ...List.generate(farzAngles.length, (i) {
                  final x = innerRadius * math.cos(farzAngles[i] - math.pi / 2);
                  final y = innerRadius * math.sin(farzAngles[i] - math.pi / 2);
                  return Transform.translate(
                    offset: Offset(x, y),
                    child: _PrayerBox(
                      label: prayerNames[i],
                      displayLabel: _getLocalizedPrayerName(prayerNames[i]),
                    ),
                  );
                }),

              // Overlay animasyonu
              AnimatedBuilder(
                animation: _overlayCtr,
                builder: (context, _) {
                  if (_overlayCtr.value == 0) return const SizedBox.shrink();
                  final scale = 1 + 0.2 * _overlayCtr.value;
                  return Opacity(
                    opacity: _overlayCtr.value,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Text(
                          '${_getLocalizedPrayerName(widget.nextPrayerName ?? '')} vakti!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerCirclePainter extends CustomPainter {
  final List<double> angles; // radians, Akşam referanslı
  final double nowAngle; // radians
  final List<String> prayerNames;
  final List<(double, String)> kerahatMarkers; // (angle, label)
  final double circleRadius; // dynamic

  const PrayerCirclePainter({
    required this.angles,
    required this.prayerNames,
    required this.nowAngle,
    required this.kerahatMarkers,
    required this.circleRadius,
  });

  // RN'deki gradient paletleri birebir
  List<Color> _gradientFor(String name) {
    switch (name) {
      case 'Isha':
        return const [
          Color(0xFF3E2723),
          Color(0xFF5C4033),
          Color(0xFF654321),
          Color(0xFF8B4513),
          Color(0xFFA0522D),
        ];
      case 'Imsak':
        return const [
          Color(0xFF85929E),
          Color(0xFF5D6D7E),
          Color(0xFF2C3E50),
          Color(0xFF34495E),
          Color(0xFF1F2A37),
        ];
      case 'Sunrise':
        return const [
          Color(0xFFF6DDCC),
          Color(0xFFFDEBD0),
          Color(0xFFF9E79F),
          Color(0xFFF4D03F),
          Color(0xFFF0E68C),
        ];
      case 'Dhuhr':
        return const [
          Color(0xFF98d038),
          Color(0xFFb4f544),
          Color(0xFFb4f544),
          Color(0xFFBDB76B),
          Color(0xFFFFD700),
        ];
      case 'Asr':
        return const [
          Color(0xFFFFC0CB),
          Color(0xFFFF7C41),
          Color(0xFFFC7E4B),
          Color(0xFFF76328),
          Color(0xFFF6510F),
        ];
      case 'Maghrib':
        return const [
          Color(0xFFFFDAB9),
          Color(0xFFF4A460),
          Color(0xFFD2691E),
          Color(0xFFA0522D),
          Color(0xFF654321),
        ];
    }
    return const [Colors.black, Colors.white];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, circleRadius, outerPaint);

    if (angles.isEmpty) return;

    final innerRadius = circleRadius * 0.95;

    // Her vakit için ayrı radial gradient segment (RN Path/Arc mantığı)
    for (int i = 0; i < angles.length; i++) {
      final start = i == 0 ? angles.last : angles[i - 1];
      final end = angles[i];
      final sweep = _sweep(start, end);
      final rect = Rect.fromCircle(center: center, radius: innerRadius);
      final colors = _gradientFor(prayerNames[i]);
      final p =
          Paint()
            ..shader = RadialGradient(
              colors: colors,
              stops: List.generate(
                colors.length,
                (j) => j / (colors.length - 1),
              ),
              center: Alignment.center,
              radius: 1.0,
            ).createShader(rect);

      final path = Path()..moveTo(center.dx, center.dy);
      path.arcTo(rect, start - math.pi / 2, sweep, false);
      path.close();
      canvas.drawPath(path, p);
    }

    // Şu anki zaman: kırmızı çizgi + bilye
    final x = center.dx + innerRadius * math.cos(nowAngle - math.pi / 2);
    final y = center.dy + innerRadius * math.sin(nowAngle - math.pi / 2);
    final p2 =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2;
    canvas.drawLine(center, Offset(x, y), p2);
    canvas.drawCircle(Offset(x, y), 9, Paint()..color = Colors.red);

    // Kerahat işaretleri
    for (final (ang, label) in kerahatMarkers) {
      final mx = center.dx + innerRadius * math.cos(ang - math.pi / 2);
      final my = center.dy + innerRadius * math.sin(ang - math.pi / 2);
      canvas.drawCircle(Offset(mx, my), 10, Paint()..color = Colors.black);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(mx - tp.width / 2, my - tp.height / 2));
      canvas.drawLine(
        center,
        Offset(mx, my),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      );
    }
  }

  double _sweep(double start, double end) {
    var s = end - start;
    if (s < 0) s += 2 * math.pi;
    return s;
  }

  @override
  bool shouldRepaint(covariant PrayerCirclePainter old) =>
      old.angles != angles ||
      old.nowAngle != nowAngle ||
      old.prayerNames != prayerNames ||
      old.circleRadius != circleRadius;
}

class _PrayerBox extends StatefulWidget {
  final String label;
  final String? displayLabel;
  const _PrayerBox({required this.label, this.displayLabel});

  @override
  State<_PrayerBox> createState() => _PrayerBoxState();
}

class _PrayerBoxState extends State<_PrayerBox> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: expanded ? 70 : 30,
        height: expanded ? 70 : 30,
        decoration: BoxDecoration(
          color: _boxColorFor(widget.label),
          borderRadius: BorderRadius.circular(expanded ? 10 : 15),
        ),
        alignment: Alignment.center,
        child:
            expanded
                ? Text(
                  widget.displayLabel ?? widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                )
                : null,
      ),
    );
  }

  // RN kutucuk renkleri birebir
  Color _boxColorFor(String name) {
    switch (name) {
      case 'Maghrib':
        return const Color(0xFF6F4C3E);
      case 'Isha':
        return const Color(0xFF295e9c);
      case 'Imsak':
        return const Color(0xFFA3C1DA);
      case 'Sunrise':
        return const Color(0xFF9CB86B);
      case 'Dhuhr':
        return const Color(0xFFFFD700);
      case 'Asr':
        return const Color(0xFFFFA07A);
    }
    return Colors.grey;
  }
}









// // PrayerCircle widget remains the same
// class PrayerCircle extends StatefulWidget {
//   final PrayerTimes? prayerTimes;

//   PrayerCircle({this.prayerTimes});

//   @override
//   _PrayerCircleState createState() => _PrayerCircleState();
// }

// class _PrayerCircleState extends State<PrayerCircle>with TickerProviderStateMixin {
//    List<double> _angles(PrayerTimes prayerTimes){
//     if(prayerTimes ==null){
//       return[];
//     } 
//       DateTime now = DateTime.now();
//   DateTime _parseToday(String hhmm){
//     final parts = hhmm.split(':');
//     final d = DateTime.now();
//     return DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));
//   }

//     final dayStart = DateTime(now.year, now.month, now.day);
//     final aksamMins = _parseToday(prayerTimes.timings['Magrib']!).difference(dayStart).inMinutes;
//     const total = 24*60;

//     return prayerNames.map((n){
//       final mins = _parseToday(prayerTimes.timings[n]!).difference(dayStart).inMinutes;
//       final diff = mins >= aksamMins ? mins-aksamMins : total+mins-aksamMins;
//       return (diff/total) * 2*math.pi; // radians
//     }).toList();
//   }

// (String, DateTime)? _nextPrayer(PrayerTimes prayerTimes) {
//   DateTime now = DateTime.now();

//   if (prayerTimes == null) return null;
  
//   final items = <(String, DateTime)>[];
  
//   for (final name in prayerNames) {
//     final timeString = prayerTimes.timings[name];
//     if (timeString == null) continue;

//     final t = _parseToday(timeString);
//     items.add((name, t));
//     items.add((name, t.add(const Duration(days: 1))));
//   }
  
//   items.sort((a, b) => a.$2.compareTo(b.$2));
  
//   for (final it in items) {
//     if (it.$2.isAfter(now)) return it;
//   }
  
//   return null;
// }

// DateTime _parseToday(String hhmm){
//     final parts = hhmm.split(':');
//     final d = DateTime.now();
//     return DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));
//   }
//   DateTime _midAcrossDays(DateTime start, DateTime end) {
//     // end < start ise ertesi güne taşı
//     if (!end.isAfter(start)) end = end.add(const Duration(days: 1));
//     final half = _frac(end.difference(start), 0.5);
//     return start.add(half);
//   }
//     Duration _frac(Duration d, double f) => Duration(milliseconds: (d.inMilliseconds * f).round());

//   Map<String, double> _computeNafileAngles(PrayerTimes prayerTimes ){
//     final res = <String, double>{};
//     if (prayerTimes==null ) return res;

// final imsakToday = _parseToday(prayerTimes.timings['Fajr']!);   // İmsak [Fajr]
// final sunrise    = _parseToday(prayerTimes.timings['Sunrise']!);   // Güneş [Sunrise]
// final dhuhr      = _parseToday(prayerTimes.timings['Dhuhr']!);    // Öğle [Dhuhr]
// final asr        = _parseToday(prayerTimes.timings['Asr']!);  // İkindi [Asr]
// final maghrib    = _parseToday(prayerTimes.timings['Maghrib']!);   // Akşam [Maghrib]
// final isha       = _parseToday(prayerTimes.timings['Isha']!);   // Yatsı [Isha]


//     final imsakNext  = imsakToday.add(const Duration(days: 1));
//     final nightLen   = imsakNext.difference(isha.isAfter(maghrib) ? isha : isha); // isha bugün

//     DateTime midDuha(){
//       final start = sunrise.add(const Duration(minutes: 45));
//       final end   = dhuhr.subtract(const Duration(minutes: 15));
//       return _midAcrossDays(start, end);
//     }

//     DateTime midTeheccud(){
//       // Gecenin son üçte biri: orta noktası 5/6 oranında
//       final startNight = isha;
//       final mid = startNight.add(_frac(nightLen, 5/6));
//       return mid;
//     }

//     DateTime midEvvabin(){
//       final start = maghrib.add(const Duration(minutes: 10));
//       final end   = isha.subtract(const Duration(minutes: 10));
//       return _midAcrossDays(start, end);
//     }

//     DateTime midIstihare(){
//       // Gecenin ilk üçte birinin ortası: 1/6
//       final startNight = isha;
//       return startNight.add(_frac(nightLen, 1/6));
//     }

//     DateTime midHacet(){
//       // Öğle-Asr aralığında pratik bir orta
//       final start = dhuhr.add(const Duration(hours: 1));
//       final end   = asr.subtract(const Duration(minutes: 30));
//       return _midAcrossDays(start, end);
//     }

//     DateTime midTesbih(){
//       // Gün içinde geniş: İkindi-Akşam ortası
//       return _midAcrossDays(asr, maghrib);
//     }

//     DateTime pickMid(String name){
//       switch(name){
//         case 'Duha (Kuşluk)': return midDuha();
//         case 'Teheccüd': return midTeheccud();
//         case 'Evvabin': return midEvvabin();
//         case 'İstihare': return midIstihare();
//         case 'Hacet': return midHacet();
//         case 'Tesbih': return midTesbih();
//       }
//       // bilmezse öğle ortası
//       return _midAcrossDays(dhuhr, asr);
//     }

   
//     return res;
//   }

//    double _angleFromAksam(PrayerTimes prayerTimes, DateTime t){
//     if (prayerTimes==null) return 0;
//     final aksam = _parseToday(prayerTimes.timings['Magrib']!);
//     const dayMin = 24*60;
//     int diff = t.difference(aksam).inMinutes;
//     if (diff < 0) diff += dayMin;
//     return (diff/dayMin) * 2*math.pi; // radians
//   }
//   double _timeAngleWithOffset(PrayerTimes prayerTimes ,String prayer, int offsetMin){
//     if (prayerTimes==null) return 0;
//     final base = _parseToday(prayerTimes.timings[prayer]!);
//     final withOffset = base.add(Duration(minutes: offsetMin));
//     return _angleFromAksam(prayerTimes,withOffset);
//   }
// }

//   final double circleRadius = 175;
//   Map<String, bool> boxStates = {};
// final List<String> prayerNames = [
//   'Imsak',
//   'Sunrise',
//   'Dhuhr',
//   'Asr',
//   'Maghrib',
//   'Isha',
// ];
//   late final AnimationController _overlayCtr;
//   // Gece yarısı Hicrî tarihi yenilemek için timer
//   Timer? _midnightTimer;
//   // RN'deki minute-level tetiklemeye daha yakın: aynı dakika içinde tekrar tetiklemeyi engelle
//   int? _lastOverlayMinute;
//   String? _lastOverlayPrayer;
//     @override
//   void initState() {
//     super.initState();
//     _overlayCtr = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
 
//   }
//   @override
//   Widget build(BuildContext context) {
//       final farzAngles = _angles(widget.prayerTimes!);
//     final next = _nextPrayer(widget.prayerTimes!);
//     final nafileAngles = _computeNafileAngles(widget.prayerTimes!);
//       DateTime now = DateTime.now();

//     // Ekran boyutuna göre dinamik çember
//     final size = MediaQuery.of(context).size;
//     final diameter = math.min(size.width, size.height) * 0.86; // biraz daha büyük yap
//     final circleRadius = diameter / 2;
//     final innerRadius = circleRadius * 0.95;
//     return BlocBuilder<PrayerBloc, PrayerState>(
//       builder: (context, state) {
//         if (state is PrayerLoading) {
//           return CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//           );
//         }

//         if (state is PrayerLoaded) {
//           if (next != null) {
//       final d = next.$2.difference(now);
//       final sameMinute = d.inMinutes == 0 && !d.isNegative; // bu dakika içinde
//       if (sameMinute) {
//         if (_lastOverlayPrayer != next.$1 || _lastOverlayMinute != now.minute) {
//           _lastOverlayPrayer = next.$1;
//           _lastOverlayMinute = now.minute;
//           if (!_overlayCtr.isAnimating) {
//             _overlayCtr.forward(from: 0);
//             Future.delayed(const Duration(seconds: 4), () {
//               if (mounted) _overlayCtr.value = 0;
//             });
//           }
//         }
//       }
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       body: SafeArea(
//         child: Center(
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Hicrî Tarih (üstte, daha belirgin)
//               Positioned(
//                 top: 8,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   children: [
                   
//                     const SizedBox(height: 2),
//                     // Text(
//                     //   hijriTr ?? '',
//                     //   textAlign: TextAlign.center,
//                     //   style: const TextStyle(
//                     //     fontSize: 18,
//                     //     fontWeight: FontWeight.w600,
//                     //     color: Colors.black87,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),

//               // Çember ve boyalı alan
//               SizedBox(
//                 width: diameter,
//                 height: diameter,
//                 child: CustomPaint(
//                   painter: PrayerCirclePainter(
//                     angles: farzAngles,
//                     prayerNames: prayerNames,
//                     nowAngle: _angleFromAksam(widget.prayerTimes!,now),
//                     kerahatMarkers: [
//                       (_timeAngleWithOffset('Güneş', 45), 'Kerahat'),
//                       (_timeAngleWithOffset('Öğle', -45), 'Kerahat'),
//                       (_timeAngleWithOffset('Akşam', -45), 'Kerahat'),
//                     ],
//                     circleRadius: circleRadius,
//                   ),
//                 ),
//               ),

//               // Geri sayım çemberin ortasında
//               if (widget.prayerTimes != null && next != null)
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Bir sonraki namaz',
//                       style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       next.$1,
//                       style: const TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.w800),
//                     ),
//                     const SizedBox(height: 8),
//                     Builder(builder: (_) {
//                       final d = next.$2.difference(now);
//                       final dur = d.isNegative ? const Duration() : d;
//                       final hhmmss = _fmt(dur);
//                       return Column(
//                         children: [
//                           Text(
//                             hhmmss,
//                             style: const TextStyle(fontSize: 34, color: Colors.black87, fontWeight: FontWeight.bold),
//                           ),
                      
//                           const SizedBox(height: 4),
//                           const Text(
//                             'kaldı',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
//                           ),
//                         ],
//                       );
//                     })
//                   ],
//                 ),

//               // Farz kutucuklar
//               if (farzAngles.isNotEmpty)
//                 ...List.generate(farzAngles.length, (i) {
//                   final x = innerRadius * math.cos(farzAngles[i] - math.pi / 2);
//                   final y = innerRadius * math.sin(farzAngles[i] - math.pi / 2);
//                   return Transform.translate(
//                     offset: Offset(x, y),
//                     child: _PrayerBox(label: prayerNames[i]),
//                   );
//                 }),

//               // Nafile kutucuklar
//               if (nafileAngles.isNotEmpty)
//                 ...nafileAngles.entries.map((e) {
//                   final ang = e.value;
//                   final x = innerRadius * math.cos(ang - math.pi / 2);
//                   final y = innerRadius * math.sin(ang - math.pi / 2);
//                   return Transform.translate(
//                     key: ValueKey('nafile-${e.key}'),
//                     offset: Offset(x, y),
//                     child: _PrayerBox(label: e.key),
//                   );
//                 }),

//               // Overlay animasyonu
//               AnimatedBuilder(
//                 animation: _overlayCtr,
//                 builder: (context, _) {
//                   if (_overlayCtr.value == 0) return const SizedBox.shrink();
//                   final scale = 1 + 0.2*_overlayCtr.value;
//                   return Opacity(
//                     opacity: _overlayCtr.value,
//                     child: Transform.scale(
//                       scale: scale,
//                       child: Container(
//                         width: double.infinity,
//                         height: double.infinity,
//                         color: Colors.black54,
//                         alignment: Alignment.center,
//                         child: Text('${_nextPrayer()?.$1} vakti!',
//                           style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//         return SizedBox.shrink();
//       },
//     );
//   }

//   List<Widget> _buildPrayerBoxes(PrayerTimes prayerTimes) {
//       print("namaz prayerTimesprayerTimes ${prayerTimes.timings}");

//     final angles = _calculateAngles(prayerTimes, prayerNames);
//     final innerRadius = circleRadius * 0.95;
    
//     return angles.asMap().entries.map((entry) {
//       final index = entry.key;
//       final angle = entry.value;
//       final prayerName = prayerNames[index];
//       final isExpanded = boxStates[prayerName] ?? false;
      
//       final angleInRadians = (angle - 90) * (pi / 180);
//       final x = innerRadius * cos(angleInRadians);
//       final y = innerRadius * sin(angleInRadians);

//       return Positioned(
//         left: circleRadius + x - (isExpanded ? 35 : 15),
//         top: circleRadius + y - (isExpanded ? 35 : 15),
//         child: GestureDetector(
//           onTap: () {
//             setState(() {
//               boxStates[prayerName] = !isExpanded;
//             });
//           },
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 200),
//             width: isExpanded ? 70 : 30,
//             height: isExpanded ? 70 : 30,
//             decoration: BoxDecoration(
//               color: _getColorForPrayer(prayerName),
//               borderRadius: BorderRadius.circular(isExpanded ? 10 : 15),
//               border: Border.all(color: AppColors.border, width: 1),
//             ),
//             child: Center(
//               child: isExpanded 
//                 ? Text(
//                     prayerName,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 : SizedBox.shrink(),
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

// List<double> _calculateAngles(PrayerTimes prayerTimes, List<String> prayerNames) {
//   final prayerTimesMap = prayerTimes.toMap();
//   final timesInMinutes = prayerNames.map((name) {
//     final timeString = prayerTimesMap[name];
//     if (timeString == null) {
//       throw Exception('Prayer time for $name not found');
//     }
//     final parts = timeString.split(':');
//     return int.parse(parts[0]) * 60 + int.parse(parts[1]);
//   }).toList();

//   final aksamIndex = prayerNames.indexOf('Maghrib');
//   if (aksamIndex == -1) {
//     throw Exception('Prayer name "Maghrib" not found in prayerNames');
//   }
//   final aksamTime = timesInMinutes[aksamIndex];
//   const totalMinutesInDay = 24 * 60;

//   return timesInMinutes.map((time) {
//     final diffFromAksam = time >= aksamTime 
//         ? time - aksamTime 
//         : totalMinutesInDay + time - aksamTime;
//     return (diffFromAksam / totalMinutesInDay) * 360;
//   }).toList();
// }



// Color _getColorForPrayer(String prayerName) {
//   final colors = {
//     'Imsak': Color(0xFFA3C1DA),    // İmsak
//     'Sunrise': Color(0xFF9CB86B),  // Güneş
//     'Dhuhr': Color(0xFFFFD700),    // Öğle
//     'Asr': Color(0xFFFFA07A),      // İkindi
//     'Maghrib': Color(0xFF6F4C3E),  // Maghrib
//     'Isha': Color(0xFF295e9c),     // Yatsı
//   };
//   return colors[prayerName] ?? AppColors.primary;
// }


// class PrayerCirclePainter extends CustomPainter {
//   final List<double> angles; // radians, Akşam referanslı
//   final double nowAngle; // radians
//   final List<String> prayerNames;
//   final List<(double, String)> kerahatMarkers; // (angle, label)
//   final double circleRadius; // dynamic

//   const PrayerCirclePainter({
//     required this.angles,
//     required this.prayerNames,
//     required this.nowAngle,
//     required this.kerahatMarkers,
//     required this.circleRadius,
//   });

//   // RN'deki gradient paletleri birebir
//   List<Color> _gradientFor(String name){
//     switch(name){
//       case 'Yatsı': return const [Color(0xFF3E2723), Color(0xFF5C4033), Color(0xFF654321), Color(0xFF8B4513), Color(0xFFA0522D)];
//       case 'İmsak': return const [Color(0xFF85929E), Color(0xFF5D6D7E), Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF1F2A37)];
//       case 'Güneş': return const [Color(0xFFF6DDCC), Color(0xFFFDEBD0), Color(0xFFF9E79F), Color(0xFFF4D03F), Color(0xFFF0E68C)];
//       case 'Öğle': return const [Color(0xFF98d038), Color(0xFFb4f544), Color(0xFFb4f544), Color(0xFFBDB76B), Color(0xFFFFD700)];
//       case 'İkindi': return const [Color(0xFFFFC0CB), Color(0xFFFF7C41), Color(0xFFFC7E4B), Color(0xFFF76328), Color(0xFFF6510F)];
//       case 'Akşam': return const [Color(0xFFFFDAB9), Color(0xFFF4A460), Color(0xFFD2691E), Color(0xFFA0522D), Color(0xFF654321)];
//     }
//     return const [Colors.black, Colors.white];
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width/2, size.height/2);
//     final outerPaint = Paint()..color = Colors.white;
//     canvas.drawCircle(center, circleRadius, outerPaint);

//     if (angles.isEmpty) return;

//     final innerRadius = circleRadius * 0.95;

//     // Her vakit için ayrı radial gradient segment (RN Path/Arc mantığı)
//     for (int i=0;i<angles.length;i++){
//       final start = i==0 ? angles.last : angles[i-1];
//       final end = angles[i];
//       final sweep = _sweep(start, end);
//       final rect = Rect.fromCircle(center: center, radius: innerRadius);
//       final colors = _gradientFor(prayerNames[i]);
//       final p = Paint()
//         ..shader = RadialGradient(
//           colors: colors,
//           stops: List.generate(colors.length, (j)=> j/(colors.length-1)),
//           center: Alignment.center,
//           radius: 1.0,
//         ).createShader(rect);

//       final path = Path()..moveTo(center.dx, center.dy);
//       path.arcTo(rect, start - math.pi/2, sweep, false);
//       path.close();
//       canvas.drawPath(path, p);
//     }

//     // Şu anki zaman: kırmızı çizgi + bilye
//     final x = center.dx + innerRadius * math.cos(nowAngle - math.pi/2);
//     final y = center.dy + innerRadius * math.sin(nowAngle - math.pi/2);
//     final p2 = Paint()..color = Colors.red..strokeWidth=2;
//     canvas.drawLine(center, Offset(x,y), p2);
//     canvas.drawCircle(Offset(x,y), 9, Paint()..color=Colors.red);

//     // Kerahat işaretleri
//     for (final (ang, label) in kerahatMarkers){
//       final mx = center.dx + innerRadius * math.cos(ang - math.pi/2);
//       final my = center.dy + innerRadius * math.sin(ang - math.pi/2);
//       canvas.drawCircle(Offset(mx,my), 10, Paint()..color=Colors.black);
//       final tp = TextPainter(
//         text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 10)),
//         textDirection: TextDirection.ltr,
//       )..layout();
//       tp.paint(canvas, Offset(mx - tp.width/2, my - tp.height/2));
//       canvas.drawLine(center, Offset(mx,my), Paint()..color=Colors.black..strokeWidth=2);
//     }
//   }

//   double _sweep(double start, double end){
//     var s = end - start; if (s < 0) s += 2*math.pi; return s;
//   }

//   @override
//   bool shouldRepaint(covariant PrayerCirclePainter old) =>
//       old.angles != angles || old.nowAngle != nowAngle || old.prayerNames != prayerNames || old.circleRadius != circleRadius;
// }


// class _PrayerBox extends StatefulWidget {
//   final String label;
//   const _PrayerBox({required this.label});

//   @override
//   State<_PrayerBox> createState() => _PrayerBoxState();
// }

// class _PrayerBoxState extends State<_PrayerBox> {
//   bool expanded = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: ()=> setState(()=> expanded = !expanded),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: expanded ? 70 : 30,
//         height: expanded ? 70 : 30,
//         decoration: BoxDecoration(
//           color: _boxColorFor(widget.label),
//           borderRadius: BorderRadius.circular(expanded ? 10 : 15),
//         ),
//         alignment: Alignment.center,
//         child: expanded ? Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)) : null,
//       ),
//     );
//   }

//   // RN kutucuk renkleri birebir
//   Color _boxColorFor(String name){
//     switch(name){
//       case 'Akşam': return const Color(0xFF6F4C3E);
//       case 'Yatsı': return const Color(0xFF295e9c);
//       case 'İmsak': return const Color(0xFFA3C1DA);
//       case 'Güneş': return const Color(0xFF9CB86B);
//       case 'Öğle': return const Color(0xFFFFD700);
//       case 'İkindi': return const Color(0xFFFFA07A);
//     }
//     return Colors.grey;
//   }
// }

