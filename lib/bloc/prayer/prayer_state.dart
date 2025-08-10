import 'package:equatable/equatable.dart';
import 'package:namaz/models/hijri_date_model.dart';
import 'package:namaz/models/prayer_times_model.dart';


abstract class PrayerState  {

}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTimes prayerTimes;
  final HijriDate hijriDate;
  final String nextPrayer;
  final Duration timeRemaining;

  PrayerLoaded({
    required this.prayerTimes,
    required this.hijriDate,
    required this.nextPrayer,
    required this.timeRemaining,
  });

  @override
  List<Object?> get props => [prayerTimes, hijriDate, nextPrayer, timeRemaining];
}

class PrayerError extends PrayerState {
  final String message;
  PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}
