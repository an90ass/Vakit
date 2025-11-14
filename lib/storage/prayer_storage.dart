import 'package:hive/hive.dart';
import 'package:vakit/hive/prayer_day.dart';

class PrayerStorage {
  static final _boxName = 'prayers';

  static Box<PrayerDay> get _box => Hive.box<PrayerDay>(_boxName);

  static Future<void> savePrayerTimes(Map<String, dynamic> timings) async {
    String key = DateTime.now().toIso8601String().substring(0, 10);

    if (_box.containsKey(key)) {
      print('Prayer times for today already saved.');
      return;
    }

    final prayerDay = PrayerDay(
      date: DateTime.now(),
      fajr: timings["Fajr"] ?? '',
      dhuhr: timings["Dhuhr"] ?? '',
      asr: timings["Asr"] ?? '',
      maghrib: timings["Maghrib"] ?? '',
      isha: timings["Isha"] ?? '',
      fajrStatus: null,
      dhuhrStatus: null,
      asrStatus: null,
      maghribStatus: null,
      ishaStatus: null,
    );

    await _box.put(key, prayerDay);
  }

  static Future<void> updatePrayerStatus(String dateKey, String prayerName, bool status) async {
    final PrayerDay? dayData = _box.get(dateKey);

    if (dayData != null) {
      PrayerDay updatedDay;

      switch (prayerName) {
        case 'Fajr':
          updatedDay = PrayerDay(
            date: dayData.date,
            fajr: dayData.fajr,
            dhuhr: dayData.dhuhr,
            asr: dayData.asr,
            maghrib: dayData.maghrib,
            isha: dayData.isha,
            fajrStatus: status,
            dhuhrStatus: dayData.dhuhrStatus,
            asrStatus: dayData.asrStatus,
            maghribStatus: dayData.maghribStatus,
            ishaStatus: dayData.ishaStatus,
          );
          break;
        case 'Dhuhr':
          updatedDay = PrayerDay(
            date: dayData.date,
            fajr: dayData.fajr,
            dhuhr: dayData.dhuhr,
            asr: dayData.asr,
            maghrib: dayData.maghrib,
            isha: dayData.isha,
            fajrStatus: dayData.fajrStatus,
            dhuhrStatus: status,
            asrStatus: dayData.asrStatus,
            maghribStatus: dayData.maghribStatus,
            ishaStatus: dayData.ishaStatus,
          );
          break;
        case 'Asr':
          updatedDay = PrayerDay(
            date: dayData.date,
            fajr: dayData.fajr,
            dhuhr: dayData.dhuhr,
            asr: dayData.asr,
            maghrib: dayData.maghrib,
            isha: dayData.isha,
            fajrStatus: dayData.fajrStatus,
            dhuhrStatus: dayData.dhuhrStatus,
            asrStatus: status,
            maghribStatus: dayData.maghribStatus,
            ishaStatus: dayData.ishaStatus,
          );
          break;
        case 'Maghrib':
          updatedDay = PrayerDay(
            date: dayData.date,
            fajr: dayData.fajr,
            dhuhr: dayData.dhuhr,
            asr: dayData.asr,
            maghrib: dayData.maghrib,
            isha: dayData.isha,
            fajrStatus: dayData.fajrStatus,
            dhuhrStatus: dayData.dhuhrStatus,
            asrStatus: dayData.asrStatus,
            maghribStatus: status,
            ishaStatus: dayData.ishaStatus,
          );
          break;
        case 'Isha':
          updatedDay = PrayerDay(
            date: dayData.date,
            fajr: dayData.fajr,
            dhuhr: dayData.dhuhr,
            asr: dayData.asr,
            maghrib: dayData.maghrib,
            isha: dayData.isha,
            fajrStatus: dayData.fajrStatus,
            dhuhrStatus: dayData.dhuhrStatus,
            asrStatus: dayData.asrStatus,
            maghribStatus: dayData.maghribStatus,
            ishaStatus: status,
          );
          break;
        default:
          return;
      }

      await _box.put(dateKey, updatedDay);
    }
  }

  static PrayerDay? getPrayerDay(String dateKey) {
    return _box.get(dateKey);
  }
}
