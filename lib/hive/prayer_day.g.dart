// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_day.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerDayAdapter extends TypeAdapter<PrayerDay> {
  @override
  final int typeId = 0;

  @override
  PrayerDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerDay(
      date: fields[0] as DateTime,
      fajr: fields[1] as String,
      dhuhr: fields[2] as String,
      asr: fields[3] as String,
      maghrib: fields[4] as String,
      isha: fields[5] as String,
      fajrStatus: fields[6] as bool?,
      dhuhrStatus: fields[7] as bool?,
      asrStatus: fields[8] as bool?,
      maghribStatus: fields[9] as bool?,
      ishaStatus: fields[10] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerDay obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.fajr)
      ..writeByte(2)
      ..write(obj.dhuhr)
      ..writeByte(3)
      ..write(obj.asr)
      ..writeByte(4)
      ..write(obj.maghrib)
      ..writeByte(5)
      ..write(obj.isha)
      ..writeByte(6)
      ..write(obj.fajrStatus)
      ..writeByte(7)
      ..write(obj.dhuhrStatus)
      ..writeByte(8)
      ..write(obj.asrStatus)
      ..writeByte(9)
      ..write(obj.maghribStatus)
      ..writeByte(10)
      ..write(obj.ishaStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
