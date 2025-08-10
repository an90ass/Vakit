abstract class MyPrayersEvent {}

class LoadMyPrayers extends MyPrayersEvent {
  final String dateKey;

  LoadMyPrayers(this.dateKey);
}

class UpdatePrayerStatus extends MyPrayersEvent {
  final String dateKey;
  final String prayerName;
  final bool status;

  UpdatePrayerStatus({
    required this.dateKey,
    required this.prayerName,
    required this.status,
  });
}
