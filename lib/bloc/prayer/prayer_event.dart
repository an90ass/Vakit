import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class PrayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPrayerData extends PrayerEvent {
  final Position location;

  LoadPrayerData(this.location);

  @override
  List<Object?> get props => [location];
}

class CalculateNextPrayer extends PrayerEvent {
  final Map<String, String> prayerTimes;

  CalculateNextPrayer(this.prayerTimes);

  @override
  List<Object?> get props => [prayerTimes];
}
