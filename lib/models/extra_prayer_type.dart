import 'package:namaz/models/prayer_times_model.dart';

enum ExtraPrayerType { duha, ishraq, tahajjud, awwabin }

extension ExtraPrayerTypeX on ExtraPrayerType {
  String get id => name;

  String get title {
    switch (this) {
      case ExtraPrayerType.duha:
        return 'Duha (Kuşluk)';
      case ExtraPrayerType.ishraq:
        return 'İşrak';
      case ExtraPrayerType.tahajjud:
        return 'Teheccüd';
      case ExtraPrayerType.awwabin:
        return 'Evvabin';
    }
  }

  String get description {
    switch (this) {
      case ExtraPrayerType.duha:
        return 'Güneş doğduktan sonra 20 dakika içinde';
      case ExtraPrayerType.ishraq:
        return 'Güneş doğduktan 15 dakika içinde';
      case ExtraPrayerType.tahajjud:
        return 'Gece yarısından seher vaktine kadar';
      case ExtraPrayerType.awwabin:
        return 'Akşam ile yatsı arası sessiz vakit';
    }
  }

  DateTime? resolveReminderTime(PrayerTimes? times) {
    if (times == null) return null;
    DateTime? parse(String? raw) {
      if (raw == null) return null;
      final parts = raw.split(':');
      if (parts.length < 2) return null;
      final now = DateTime.now();
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    switch (this) {
      case ExtraPrayerType.duha:
        return parse(
          times.timings['Sunrise'],
        )?.add(const Duration(minutes: 20));
      case ExtraPrayerType.ishraq:
        return parse(
          times.timings['Sunrise'],
        )?.add(const Duration(minutes: 15));
      case ExtraPrayerType.tahajjud:
        return parse(times.timings['Fajr'])?.subtract(const Duration(hours: 2));
      case ExtraPrayerType.awwabin:
        return parse(
          times.timings['Maghrib'],
        )?.add(const Duration(minutes: 20));
    }
  }
}
