import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaz/models/tracked_location.dart';

class TrackedLocationService {
  TrackedLocationService(this._prefs);

  static const _locationsKey = 'trackedLocations';
  static const _activeKey = 'activeTrackedLocationId';

  final SharedPreferences _prefs;

  Future<List<TrackedLocation>> loadLocations() async {
    final raw = _prefs.getString(_locationsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => TrackedLocation.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLocations(List<TrackedLocation> locations) async {
    final data = jsonEncode(
      locations.map((location) => location.toJson()).toList(),
    );
    await _prefs.setString(_locationsKey, data);
  }

  String? loadActiveLocationId() {
    return _prefs.getString(_activeKey);
  }

  Future<void> saveActiveLocationId(String? id) async {
    if (id == null) {
      await _prefs.remove(_activeKey);
    } else {
      await _prefs.setString(_activeKey, id);
    }
  }
}
