class PrayerTimes {
  final Map<String, String> timings;

  PrayerTimes({required this.timings});

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      timings: json.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, String> toMap() => timings;
}
