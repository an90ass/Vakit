import 'package:equatable/equatable.dart';
import 'package:vakit/models/prayer_summary.dart';
import 'package:vakit/models/tracked_location.dart';

class TrackedLocationsState extends Equatable {
  final List<TrackedLocation> locations;
  final String? activeLocationId;
  final Map<String, PrayerSummary> prayerSummaries;
  final bool isLoading;
  final bool isGpsRefreshing;
  final String? errorMessage;

  const TrackedLocationsState({
    required this.locations,
    required this.activeLocationId,
    required this.prayerSummaries,
    required this.isLoading,
    required this.isGpsRefreshing,
    required this.errorMessage,
  });

  factory TrackedLocationsState.initial() {
    return const TrackedLocationsState(
      locations: [],
      activeLocationId: null,
      prayerSummaries: {},
      isLoading: true,
      isGpsRefreshing: false,
      errorMessage: null,
    );
  }

  TrackedLocationsState copyWith({
    List<TrackedLocation>? locations,
    String? activeLocationId,
    Map<String, PrayerSummary>? prayerSummaries,
    bool? isLoading,
    bool? isGpsRefreshing,
    String? errorMessage,
  }) {
    return TrackedLocationsState(
      locations: locations ?? this.locations,
      activeLocationId: activeLocationId ?? this.activeLocationId,
      prayerSummaries: prayerSummaries ?? this.prayerSummaries,
      isLoading: isLoading ?? this.isLoading,
      isGpsRefreshing: isGpsRefreshing ?? this.isGpsRefreshing,
      errorMessage: errorMessage,
    );
  }

  TrackedLocation? get activeLocation {
    if (locations.isEmpty) {
      return null;
    }
    if (activeLocationId == null) {
      return locations.first;
    }
    try {
      return locations.firstWhere(
        (location) => location.id == activeLocationId,
      );
    } catch (_) {
      return locations.first;
    }
  }

  PrayerSummary? summaryFor(String id) => prayerSummaries[id];

  int get manualLocationCount =>
      locations.where((location) => !location.isAuto).length;

  @override
  List<Object?> get props => [
    locations,
    activeLocationId,
    prayerSummaries,
    isLoading,
    isGpsRefreshing,
    errorMessage,
  ];
}
