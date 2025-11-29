class NextPrayerInfo {
  final String name;
  final Duration remaining;

  const NextPrayerInfo({required this.name, required this.remaining});
}

class PrayerUtils {
  static const List<String> _allowedPrayers = [
    'Imsak',
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha'
  ];

  static NextPrayerInfo calculateNextPrayer(Map<String, String> times) {
    final now = DateTime.now();
    String? nextPrayer;
    Duration? minDiff;

    // Sadece izin verilen vakitleri kontrol et
    for (final name in _allowedPrayers) {
      final time = times[name];
      if (time == null) continue;

      final parts = time.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      // Vaktin bugünkü tarihi
      var prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Eğer vakit şu andan önceyse, yarınki vakit olarak kabul et
      // (Basit yaklaşım: yarınki vaktin saati bugünküyle aynı varsayılır)
      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }

      final diff = prayerTime.difference(now);

      if (minDiff == null || diff < minDiff) {
        minDiff = diff;
        nextPrayer = name;
      }
    }

    return NextPrayerInfo(
      name: nextPrayer ?? '',
      remaining: minDiff ?? Duration.zero,
    );
  }
}
