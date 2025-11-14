class NextPrayerInfo {
  final String name;
  final Duration remaining;

  const NextPrayerInfo({required this.name, required this.remaining});
}

class PrayerUtils {
  static NextPrayerInfo calculateNextPrayer(Map<String, String> times) {
    final now = DateTime.now();
    String? nextPrayer;
    Duration? minDiff;

    times.forEach((name, time) {
      final parts = time.split(':');
      if (parts.length < 2) {
        return;
      }
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) {
        return;
      }

      var prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }

      final diff = prayerTime.difference(now);
      if (minDiff == null || diff < minDiff!) {
        minDiff = diff;
        nextPrayer = name;
      }
    });

    return NextPrayerInfo(
      name: nextPrayer ?? '',
      remaining: minDiff ?? Duration.zero,
    );
  }
}
