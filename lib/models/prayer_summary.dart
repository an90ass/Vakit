import 'package:namaz/models/prayer_times_model.dart';

class PrayerSummary {
  final PrayerTimes prayerTimes;
  final String nextPrayer;
  final Duration timeRemaining;

  const PrayerSummary({
    required this.prayerTimes,
    required this.nextPrayer,
    required this.timeRemaining,
  });
}
