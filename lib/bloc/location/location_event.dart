sealed class LocationEvent {}

class LocationLoad extends LocationEvent {}

class LocationUpdate extends LocationEvent {
  final double latitude;
  final double longitude;

  LocationUpdate(this.latitude, this.longitude);
}
