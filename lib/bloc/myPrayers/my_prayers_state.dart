import 'package:vakit/hive/prayer_day.dart';

abstract class MyPrayersState {}

class MyPrayersInitial extends MyPrayersState {}

class MyPrayersLoading extends MyPrayersState {}
class MyPrayersLoaded extends MyPrayersState {
  final PrayerDay prayerDay;

  MyPrayersLoaded(this.prayerDay);
}

class MyPrayersError extends MyPrayersState {
  final String message;

  MyPrayersError(this.message);
}
class MyPrayersUpdateing extends MyPrayersState {}

