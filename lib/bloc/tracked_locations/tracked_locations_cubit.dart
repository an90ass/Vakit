import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namaz/bloc/tracked_locations/tracked_locations_state.dart';
import 'package:namaz/models/prayer_summary.dart';
import 'package:namaz/models/tracked_location.dart';
import 'package:namaz/repositories/prayer_repository.dart';
import 'package:namaz/services/LocationService.dart';
import 'package:namaz/services/tracked_location_service.dart';
import 'package:namaz/utlis/prayer_utils.dart';

class TrackedLocationsCubit extends Cubit<TrackedLocationsState> {
  TrackedLocationsCubit({
    required TrackedLocationService storage,
    required PrayerRepository repository,
    LocationService? locationService,
  }) : _storage = storage,
       _repository = repository,
       _locationService = locationService,
       super(TrackedLocationsState.initial());

  static const int maxManualLocations = 3;
  static const String _autoLocationId = 'auto-location';

  final TrackedLocationService _storage;
  final PrayerRepository _repository;
  final LocationService? _locationService;

  Future<void> loadTrackedLocations() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final stored = await _storage.loadLocations();
      final locations = List<TrackedLocation>.from(stored);
      var activeId = _storage.loadActiveLocationId();

      if (locations.isEmpty && _locationService != null) {
        try {
          final position = await _locationService!.loadLocationData();
          final autoLocation = _buildAutoLocation(position);
          locations.add(autoLocation);
          activeId = autoLocation.id;
          await _storage.saveLocations(locations);
          await _storage.saveActiveLocationId(activeId);
        } catch (_) {
          // Ignore errors here; UI will surface via LocationBloc if needed.
        }
      }

      if (activeId == null && locations.isNotEmpty) {
        activeId = locations.first.id;
        await _storage.saveActiveLocationId(activeId);
      }

      emit(
        state.copyWith(
          locations: locations,
          activeLocationId: activeId,
          isLoading: false,
        ),
      );

      await _refreshSummaries(locations, silent: true);
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> syncCurrentLocation(Position position) async {
    final autoLocation = _buildAutoLocation(position);
    final updated = List<TrackedLocation>.from(state.locations);
    final index = updated.indexWhere(
      (location) => location.id == _autoLocationId,
    );
    if (index >= 0) {
      updated[index] = autoLocation;
    } else {
      updated.insert(0, autoLocation);
    }

    final activeId = state.activeLocationId ?? autoLocation.id;
    await _persist(updated, activeId: activeId);
    emit(state.copyWith(locations: updated, activeLocationId: activeId));
    await _refreshPrayerSummaryForLocation(autoLocation, silent: true);
  }

  Future<void> refreshGpsLocation() async {
    if (_locationService == null) {
      emit(state.copyWith(errorMessage: 'GPS service unavailable'));
      return;
    }
    emit(state.copyWith(isGpsRefreshing: true, errorMessage: null));
    try {
      final position = await _locationService!.requestLocationPermission();
      await syncCurrentLocation(position);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    } finally {
      emit(state.copyWith(isGpsRefreshing: false));
    }
  }

  Future<void> addManualLocation({
    required String query,
    String? customLabel,
  }) async {
    if (state.manualLocationCount >= maxManualLocations) {
      throw TrackedLocationLimitReached(maxManualLocations);
    }

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw const TrackedLocationValidationError('address-required');
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final searchResults = await locationFromAddress(trimmedQuery);
      if (searchResults.isEmpty) {
        throw const TrackedLocationLookupFailed();
      }

      final chosen = searchResults.first;
      final location = TrackedLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title:
            (customLabel?.trim().isNotEmpty ?? false)
                ? customLabel!.trim()
                : trimmedQuery,
        latitude: chosen.latitude,
        longitude: chosen.longitude,
      );

      final updated = List<TrackedLocation>.from(state.locations)
        ..add(location);
      final activeId = state.activeLocationId ?? location.id;
      await _persist(updated, activeId: activeId);
      emit(
        state.copyWith(
          locations: updated,
          activeLocationId: activeId,
          isLoading: false,
        ),
      );
      await _refreshPrayerSummaryForLocation(location);
    } on TrackedLocationLookupFailed {
      rethrow;
    } on TrackedLocationValidationError {
      rethrow;
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
      rethrow;
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> removeLocation(String id) async {
    final location = state.locations.firstWhere(
      (element) => element.id == id,
      orElse:
          () => const TrackedLocation(
            id: '',
            title: '',
            latitude: 0,
            longitude: 0,
          ),
    );

    if (location.id.isEmpty || location.isAuto) {
      return;
    }

    final updated = List<TrackedLocation>.from(state.locations)
      ..removeWhere((element) => element.id == id);

    var activeId = state.activeLocationId;
    if (activeId == id) {
      activeId = updated.isNotEmpty ? updated.first.id : null;
    }

    final summaries = Map<String, PrayerSummary>.from(state.prayerSummaries)
      ..remove(id);

    await _persist(updated, activeId: activeId);
    emit(
      state.copyWith(
        locations: updated,
        activeLocationId: activeId,
        prayerSummaries: summaries,
      ),
    );
  }

  Future<void> selectLocation(String id) async {
    if (!state.locations.any((location) => location.id == id)) {
      return;
    }
    await _storage.saveActiveLocationId(id);
    emit(state.copyWith(activeLocationId: id));
  }

  Future<void> refreshSummaries() async {
    await _refreshSummaries(state.locations);
  }

  Future<void> _refreshSummaries(
    List<TrackedLocation> locations, {
    bool silent = false,
  }) async {
    if (locations.isEmpty) {
      return;
    }

    if (!silent) {
      emit(state.copyWith(isLoading: true));
    }

    for (final location in locations) {
      await _refreshPrayerSummaryForLocation(location, silent: true);
    }

    if (!silent) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _refreshPrayerSummaryForLocation(
    TrackedLocation location, {
    bool silent = false,
  }) async {
    if (!silent) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final prayerTimes = await _repository.fetchPrayerTimes(
        _toPosition(location),
      );
      final nextPrayerInfo = PrayerUtils.calculateNextPrayer(
        prayerTimes.toMap(),
      );
      final summary = PrayerSummary(
        prayerTimes: prayerTimes,
        nextPrayer: nextPrayerInfo.name,
        timeRemaining: nextPrayerInfo.remaining,
      );

      final summaries = Map<String, PrayerSummary>.from(state.prayerSummaries)
        ..[location.id] = summary;

      emit(state.copyWith(prayerSummaries: summaries));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    } finally {
      if (!silent) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  TrackedLocation _buildAutoLocation(Position position) {
    return TrackedLocation(
      id: _autoLocationId,
      title: 'Current Location',
      latitude: position.latitude,
      longitude: position.longitude,
      isAuto: true,
    );
  }

  Position _toPosition(TrackedLocation location) {
    return Position(
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  Future<void> _persist(
    List<TrackedLocation> locations, {
    String? activeId,
  }) async {
    await _storage.saveLocations(locations);
    await _storage.saveActiveLocationId(activeId);
  }
}

class TrackedLocationLimitReached implements Exception {
  const TrackedLocationLimitReached(this.max);
  final int max;
}

class TrackedLocationLookupFailed implements Exception {
  const TrackedLocationLookupFailed();
}

class TrackedLocationValidationError implements Exception {
  const TrackedLocationValidationError(this.code);
  final String code;
}
