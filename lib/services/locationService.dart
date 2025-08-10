import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  Position? _userLocation;

  Position? get userLocation => _userLocation;

  Future<Position> loadLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');

    if (latitude != null && longitude != null) {
      _userLocation = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
      );
      return _userLocation!;
    } else {
      return await requestLocationPermission();
    }
  }

  Future<Position> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi');
    }

    Position position = await Geolocator.getCurrentPosition();
    _userLocation = position;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', position.latitude);
    await prefs.setDouble('longitude', position.longitude);

    return position;
  }
}
