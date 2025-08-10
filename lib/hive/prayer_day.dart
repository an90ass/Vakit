import 'package:hive/hive.dart';

part 'prayer_day.g.dart';

@HiveType(typeId: 0)
class PrayerDay {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String fajr;

  @HiveField(2)
  final String dhuhr;

  @HiveField(3)
  final String asr;

  @HiveField(4)
  final String maghrib;

  @HiveField(5)
  final String isha;

  @HiveField(6)
  bool? fajrStatus;

  @HiveField(7)
  bool? dhuhrStatus;

  @HiveField(8)
  bool? asrStatus;

  @HiveField(9)
  bool? maghribStatus;

  @HiveField(10)
  bool? ishaStatus;

  PrayerDay({
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.fajrStatus,
    this.dhuhrStatus,
    this.asrStatus,
    this.maghribStatus,
    this.ishaStatus,
  });
}
