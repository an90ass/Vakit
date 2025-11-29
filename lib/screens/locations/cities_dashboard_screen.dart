import 'dart:async';
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
import 'package:vakit/models/tracked_location.dart';
import 'package:vakit/services/widget_service.dart';
import 'package:vakit/utlis/thems/colors.dart';

class CitiesDashboardScreen extends StatefulWidget {
  const CitiesDashboardScreen({super.key});

  @override
  State<CitiesDashboardScreen> createState() => _CitiesDashboardScreenState();
}

class _CitiesDashboardScreenState extends State<CitiesDashboardScreen>
    with TickerProviderStateMixin {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  void _setupTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final theme = Theme.of(context);

    final localization = AppLocalizations.of(context)!;
    return BlocListener<PrayerBloc, PrayerState>(
      listener: (context, state) {
        if (state is PrayerLoaded) {
          WidgetService.updateWidget(
            context,
            state.prayerTimes,
            state.nextPrayer,
            state.timeRemaining,
          );
        }
      },
      child: BlocConsumer<TrackedLocationsCubit, TrackedLocationsState>(
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
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: true,
              titleSpacing: 0,

              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  localization.citiesScreenTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    fontSize: 20,
                  ),
                ),
              ),

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
                          : const Icon(
                            Icons.my_location,
                            color: Colors.black87,
                          ),
                ),
                IconButton(
                  tooltip: localization.citiesRefreshAction,
                  onPressed:
                      () =>
                          context
                              .read<TrackedLocationsCubit>()
                              .refreshSummaries(),
                  icon: const Icon(Icons.refresh, color: Colors.black87),
                ),
                const SizedBox(width: 4),
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
      ),
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

    // Optimistic update for widget
    final state = context.read<TrackedLocationsCubit>().state;
    final summary = state.prayerSummaries[location.id];
    if (summary != null) {
      WidgetService.updateWidget(
        context,
        summary.prayerTimes,
        summary.nextPrayer,
        summary.timeRemaining,
      );
    }

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
      if (!mounted) return;
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
                                  final messenger = ScaffoldMessenger.of(
                                    this.context,
                                  );
                                  final query = addressController.text.trim();
                                  final label = labelController.text.trim();
                                  if (query.isEmpty) {
                                    messenger.showSnackBar(
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
                                    Navigator.of(this.context).pop();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.locationSaved,
                                        ),
                                      ),
                                    );
                                  } on TrackedLocationLimitReached {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.maxLocationsReached(
                                            TrackedLocationsCubit
                                                .maxManualLocations,
                                          ),
                                        ),
                                      ),
                                    );
                                  } on TrackedLocationLookupFailed {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.locationSearchFailed,
                                        ),
                                      ),
                                    );
                                  } on TrackedLocationValidationError {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localization.addressRequired,
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    messenger.showSnackBar(
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

class _CitySummaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.isAuto
                          ? localization.currentLocation
                          : location.title,
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
                  if (location.isAuto)
                    Chip(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      label: Text(
                        localization.currentLocation,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  if (isActive)
                    Chip(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
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

          if (summary != null)
            _SummaryRow(summary: summary!, localization: localization)
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isActive ? null : onSetActive,
                  icon: Icon(
                    Icons.radio_button_checked,
                    color: isActive ? Colors.white70 : Colors.white,
                  ),
                  label: Text(
                    isActive ? localization.active : localization.setActive,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (onDelete != null)
                IconButton(
                  tooltip: localization.delete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary, required this.localization});

  final PrayerSummary summary;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(summary.timeRemaining);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.03),
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
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
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
            color: Colors.white.withValues(alpha: 0.8),
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
