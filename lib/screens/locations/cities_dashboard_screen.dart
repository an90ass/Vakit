import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vakit/bloc/prayer/prayer_bloc.dart';
import 'package:vakit/bloc/prayer/prayer_event.dart';
import 'package:vakit/bloc/prayer/prayer_state.dart';
import 'package:vakit/bloc/tracked_locations/tracked_locations_cubit.dart';
import 'package:vakit/bloc/tracked_locations/tracked_locations_state.dart';
import 'package:vakit/l10n/generated/app_localizations.dart';
import 'package:vakit/models/prayer_summary.dart';
import 'package:vakit/models/prayer_times_model.dart';
import 'package:vakit/models/tracked_location.dart';
import 'package:vakit/utlis/thems/colors.dart';

String _getLocalizedPrayerName(BuildContext context, String prayerName) {
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

class CitiesDashboardScreen extends StatefulWidget {
  const CitiesDashboardScreen({super.key});

  @override
  State<CitiesDashboardScreen> createState() => _CitiesDashboardScreenState();
}

class _CitiesDashboardScreenState extends State<CitiesDashboardScreen> with TickerProviderStateMixin {
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _setupTimer();
  }
  
  void _setupTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Trigger rebuild for countdown
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BlocConsumer<TrackedLocationsCubit, TrackedLocationsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final hasCapacity =
            state.manualLocationCount <
            TrackedLocationsCubit.maxManualLocations;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(localization.citiesScreenTitle),
            actions: [
              IconButton(
                tooltip: localization.gpsRefresh,
                onPressed:
                    state.isGpsRefreshing
                        ? null
                        : () =>
                            context
                                .read<TrackedLocationsCubit>()
                                .refreshGpsLocation(),
                icon:
                    state.isGpsRefreshing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.my_location),
              ),
              IconButton(
                tooltip: localization.citiesRefreshAction,
                onPressed:
                    () =>
                        context
                            .read<TrackedLocationsCubit>()
                            .refreshSummaries(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton:
              hasCapacity
                  ? FloatingActionButton.extended(
                    onPressed: () => _handleAddLocationTap(state),
                    backgroundColor: AppColors.accent,
                    label: Text(localization.addLocation),
                    icon: const Icon(Icons.add_location_alt),
                  )
                  : null,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildBody(state, localization),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    TrackedLocationsState state,
    AppLocalizations localization,
  ) {
    if (state.isLoading && state.locations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.locations.isEmpty) {
      return _EmptyCitiesState(onAction: _openAddLocationSheet);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TrackedLocationsCubit>().refreshSummaries(),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: state.locations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final location = state.locations[index];
          final summary = state.prayerSummaries[location.id];
          final isActive = state.activeLocationId == location.id;
          return _CitySummaryCard(
            location: location,
            summary: summary,
            isActive: isActive,
            onSetActive: () => _setActive(location),
            onDelete:
                location.isAuto ? null : () => _confirmDelete(location.id),
          );
        },
      ),
    );
  }

  void _setActive(TrackedLocation location) {
    context.read<TrackedLocationsCubit>().selectLocation(location.id);
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

  Future<void> _confirmDelete(String id) async {
    final localization = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localization.delete),
          content: Text(localization.citiesDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localization.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localization.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await context.read<TrackedLocationsCubit>().removeLocation(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localization.locationDeleted)));
    }
  }

  void _handleAddLocationTap(TrackedLocationsState state) {
    if (state.manualLocationCount >= TrackedLocationsCubit.maxManualLocations) {
      _showLimitSnack();
      return;
    }
    _openAddLocationSheet();
  }

  void _showLimitSnack() {
    final localization = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localization.maxLocationsReached(
            TrackedLocationsCubit.maxManualLocations,
          ),
        ),
      ),
    );
  }

  void _openAddLocationSheet() {
    final localization = AppLocalizations.of(context)!;
    final addressController = TextEditingController();
    final labelController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        var isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.addLocationTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.addLocationDescription,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: localization.addressFieldLabel,
                      hintText: localization.addressFieldHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: localization.labelFieldLabel,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(localization.cancel),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed:
                            isSubmitting
                                ? null
                                : () async {
                                  final query = addressController.text.trim();
                                  final label = labelController.text.trim();
                                  if (query.isEmpty) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.addressRequired,
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => isSubmitting = true);
                                  try {
                                    await context
                                        .read<TrackedLocationsCubit>()
                                        .addManualLocation(
                                          query: query,
                                          customLabel:
                                              label.isEmpty ? null : label,
                                        );
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.locationSaved,
                                        ),
                                      ),
                                    );
                                  } on TrackedLocationLimitReached {
                                    _showLimitSnack();
                                  } on TrackedLocationLookupFailed {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.locationSearchFailed,
                                        ),
                                      ),
                                    );
                                  } on TrackedLocationValidationError {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.addressRequired,
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.genericError,
                                        ),
                                      ),
                                    );
                                  } finally {
                                    setState(() => isSubmitting = false);
                                  }
                                },
                        child:
                            isSubmitting
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(localization.save),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      addressController.dispose();
      labelController.dispose();
    });
  }
}

class _CitySummaryCard extends StatefulWidget {
  const _CitySummaryCard({
    required this.location,
    this.summary,
    required this.isActive,
    required this.onSetActive,
    this.onDelete,
  });

  final TrackedLocation location;
  final PrayerSummary? summary;
  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback? onDelete;

  @override
  State<_CitySummaryCard> createState() => _CitySummaryCardState();
}

class _CitySummaryCardState extends State<_CitySummaryCard> {
  bool _showCircle = false;
  PrayerTimes? _prayerTimes;
  
  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }
  
  Future<void> _loadPrayerTimes() async {
    final position = Position(
      latitude: widget.location.latitude,
      longitude: widget.location.longitude,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    
    // Trigger prayer data load
    context.read<PrayerBloc>().add(LoadPrayerData(position));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(
          color: widget.isActive ? AppColors.accent : AppColors.border,
          width: widget.isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.location.isAuto
                          ? localization.currentLocation
                          : widget.location.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localization.citiesCardSubtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (widget.location.isAuto)
                    Chip(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      label: Text(
                        localization.currentLocation,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  if (widget.isActive)
                    Chip(
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      label: Text(
                        localization.active,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Prayer Circle Widget - Anasayfadaki ile aynı
          BlocBuilder<PrayerBloc, PrayerState>(
            builder: (context, prayerState) {
              if (prayerState is PrayerLoaded && _showCircle) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFFF6F7FB),
                          child: _CityPrayerCircle(
                            prayerTimes: prayerState.prayerTimes,
                            location: widget.location,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              if (widget.summary != null) {
                return _SummaryRow(
                  summary: widget.summary!,
                  localization: localization,
                  onTap: () {
                    setState(() {
                      _showCircle = !_showCircle;
                    });
                  },
                );
              }
              
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isActive ? null : widget.onSetActive,
                  icon: Icon(
                    Icons.radio_button_checked,
                    color: widget.isActive ? Colors.white70 : Colors.white,
                  ),
                  label: Text(
                    widget.isActive ? localization.active : localization.setActive,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (widget.onDelete != null)
                IconButton(
                  tooltip: localization.delete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.summary,
    required this.localization,
    this.onTap,
  });

  final PrayerSummary summary;
  final AppLocalizations localization;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(summary.timeRemaining);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.timelapse, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localization.nextPrayerLabel}: ${_getLocalizedPrayerName(context, summary.nextPrayer)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${localization.remainingLabel} • $duration',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.circle_outlined,
              color: AppColors.accent,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCitiesState extends StatelessWidget {
  const _EmptyCitiesState({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore,
            color: Colors.white.withOpacity(0.8),
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            localization.citiesEmptyTitle,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localization.citiesEmptyDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_location_alt),
            label: Text(localization.addLocation),
          ),
        ],
      ),
    );
  }
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

// Prayer Circle Widget - Anasayfadaki ile aynı
class _CityPrayerCircle extends StatefulWidget {
  final PrayerTimes prayerTimes;
  final TrackedLocation location;
  
  const _CityPrayerCircle({
    required this.prayerTimes,
    required this.location,
  });

  @override
  State<_CityPrayerCircle> createState() => _CityPrayerCircleState();
}

class _CityPrayerCircleState extends State<_CityPrayerCircle> {
  final List<String> prayerNames = [
    'Imsak',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];
  
  bool _allExpanded = false; // Tüm kutucukların durumu

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

  List<double> _angles(PrayerTimes? prayerTimes) {
    if (prayerTimes == null) return [];
    
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
      return (diff / total) * 2 * math.pi;
    }).toList();
  }

  (String, DateTime)? _nextPrayer(PrayerTimes? prayerTimes) {
    DateTime now = DateTime.now();
    if (prayerTimes == null) return null;

    final items = <(String, DateTime)>[];

    for (final name in prayerNames) {
      final timeString = prayerTimes.timings[name];
      if (timeString == null) continue;

      final t = _parseToday(timeString);
      items.add((name, t));
      items.add((name, t.add(const Duration(days: 1))));
    }

    items.sort((a, b) => a.$2.compareTo(b.$2));

    for (final it in items) {
      if (it.$2.isAfter(now)) return it;
    }

    return null;
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
    return (diff / dayMin) * 2 * math.pi;
  }

  double _timeAngleWithOffset(
    PrayerTimes? prayerTimes,
    String prayer,
    int offsetMin,
  ) {
    if (prayerTimes == null) return 0;

    final timingStr = prayerTimes.timings[prayer];
    if (timingStr == null) return 0;

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
    final farzAngles = _angles(widget.prayerTimes);
    final next = _nextPrayer(widget.prayerTimes);

    final size = MediaQuery.of(context).size;
    final diameter = math.min(size.width, 300.0);
    final circleRadius = diameter / 2;
    final innerRadius = circleRadius * 0.95;

    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _allExpanded = !_allExpanded;
          });
        },
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Çember
              CustomPaint(
                size: Size(diameter, diameter),
                painter: _CityPrayerCirclePainter(
                  angles: farzAngles,
                  prayerNames: prayerNames,
                  nowAngle: _angleFromAksam(widget.prayerTimes, now),
                  kerahatMarkers: [
                    (
                      _timeAngleWithOffset(widget.prayerTimes, 'Sunrise', 45),
                      'K',
                    ),
                    (
                      _timeAngleWithOffset(widget.prayerTimes, 'Dhuhr', -45),
                      'K',
                    ),
                    (
                      _timeAngleWithOffset(widget.prayerTimes, 'Maghrib', -45),
                      'K',
                    ),
                  ],
                  circleRadius: circleRadius,
                ),
              ),

            // Geri sayım ortada
            if (next != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.nextPrayer,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLocalizedPrayerName(next.$1),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (_) {
                      final d = next.$2.difference(now);
                      final dur = d.isNegative ? const Duration() : d;
                      final hhmmss = _fmt(dur);
                      return Column(
                        children: [
                          Text(
                            hhmmss,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.remaining,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
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
                  child: _CityPrayerBox(
                    label: prayerNames[i],
                    displayLabel: _getLocalizedPrayerName(prayerNames[i]),
                    isExpanded: _allExpanded,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityPrayerCirclePainter extends CustomPainter {
  final List<double> angles;
  final double nowAngle;
  final List<String> prayerNames;
  final List<(double, String)> kerahatMarkers;
  final double circleRadius;

  const _CityPrayerCirclePainter({
    required this.angles,
    required this.prayerNames,
    required this.nowAngle,
    required this.kerahatMarkers,
    required this.circleRadius,
  });

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

    // Her vakit için gradient segment
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

    // Vakit ayırım noktaları (her vaktin kendi rengiyle)
    for (int i = 0; i < angles.length; i++) {
      final sx = center.dx + innerRadius * math.cos(angles[i] - math.pi / 2);
      final sy = center.dy + innerRadius * math.sin(angles[i] - math.pi / 2);
      
      final separatorPaint = Paint()
        ..color = _boxColorFor(prayerNames[i])
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(sx, sy), 5, separatorPaint);
    }

    // Şu anki zaman çizgisi (kırmızı)
    final x = center.dx + innerRadius * math.cos(nowAngle - math.pi / 2);
    final y = center.dy + innerRadius * math.sin(nowAngle - math.pi / 2);
    final p2 =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2;
    canvas.drawLine(center, Offset(x, y), p2);
    canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.red);

    // Kerahat işaretleri (siyah)
    for (final (ang, label) in kerahatMarkers) {
      final mx = center.dx + innerRadius * math.cos(ang - math.pi / 2);
      final my = center.dy + innerRadius * math.sin(ang - math.pi / 2);
      
      // Siyah çizgi
      canvas.drawLine(
        center,
        Offset(mx, my),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5,
      );
      
      // Siyah nokta
      canvas.drawCircle(Offset(mx, my), 6, Paint()..color = Colors.black);
      
      // "K" harfi
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(mx - tp.width / 2, my - tp.height / 2));
    }
  }

  double _sweep(double start, double end) {
    var s = end - start;
    if (s < 0) s += 2 * math.pi;
    return s;
  }
  
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

  @override
  bool shouldRepaint(covariant _CityPrayerCirclePainter old) =>
      old.angles != angles ||
      old.nowAngle != nowAngle ||
      old.prayerNames != prayerNames ||
      old.circleRadius != circleRadius;
}

class _CityPrayerBox extends StatelessWidget {
  final String label;
  final String? displayLabel;
  final bool isExpanded;
  
  const _CityPrayerBox({
    required this.label,
    this.displayLabel,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 70 : 30,
      height: isExpanded ? 70 : 30,
      decoration: BoxDecoration(
        color: _boxColorFor(label),
        borderRadius: BorderRadius.circular(isExpanded ? 10 : 15),
      ),
      alignment: Alignment.center,
      child:
          isExpanded
              ? Text(
                displayLabel ?? label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.white,
                ),
              )
              : null,
    );
  }

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
