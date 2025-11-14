import 'dart:convert';
import 'package:hijri/hijri_calendar.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    this.birthYear,
    this.birthDate,
    required this.gender,
    required this.qadaModeEnabled,
    required this.extraPrayers,
    required this.extraPrayerNotifications,
    required this.createdAt,
    this.profileImagePath,
  });

  final String name;
  final int? birthYear; // Eski versiyon için
  final DateTime? birthDate; // Yeni versiyon - tam tarih
  final String gender;
  final bool qadaModeEnabled;
  final List<String> extraPrayers;
  final bool extraPrayerNotifications;
  final DateTime createdAt;
  final String? profileImagePath;

  int get age {
    final now = DateTime.now();
    if (birthDate != null) {
      int age = now.year - birthDate!.year;
      if (now.month < birthDate!.month ||
          (now.month == birthDate!.month && now.day < birthDate!.day)) {
        age--;
      }
      return age;
    }
    return birthYear != null ? now.year - birthYear! : 0;
  }

  int get hijriAge {
    try {
      final birth = birthDate ?? (birthYear != null ? DateTime(birthYear!, 1, 1) : DateTime.now());
      final hijriBirth = HijriCalendar.fromDate(birth);
      final hijriNow = HijriCalendar.now();
      int age = hijriNow.hYear - hijriBirth.hYear;
      if (hijriNow.hMonth < hijriBirth.hMonth ||
          (hijriNow.hMonth == hijriBirth.hMonth && hijriNow.hDay < hijriBirth.hDay)) {
        age--;
      }
      return age;
    } catch (e) {
      return age;
    }
  }

  UserProfile copyWith({
    String? name,
    int? birthYear,
    DateTime? birthDate,
    String? gender,
    bool? qadaModeEnabled,
    List<String>? extraPrayers,
    bool? extraPrayerNotifications,
    DateTime? createdAt,
    String? profileImagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      birthYear: birthYear ?? this.birthYear,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      qadaModeEnabled: qadaModeEnabled ?? this.qadaModeEnabled,
      extraPrayers: extraPrayers ?? List<String>.from(this.extraPrayers),
      extraPrayerNotifications:
          extraPrayerNotifications ?? this.extraPrayerNotifications,
      createdAt: createdAt ?? this.createdAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthYear': birthYear,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'qadaModeEnabled': qadaModeEnabled,
      'extraPrayers': extraPrayers,
      'extraPrayerNotifications': extraPrayerNotifications,
      'createdAt': createdAt.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      birthYear: json['birthYear'] as int?,
      birthDate: json['birthDate'] != null 
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String? ?? 'unspecified',
      qadaModeEnabled: json['qadaModeEnabled'] as bool? ?? false,
      extraPrayers:
          (json['extraPrayers'] as List<dynamic>? ?? const []).cast<String>(),
      extraPrayerNotifications:
          json['extraPrayerNotifications'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  static UserProfile? fromJsonString(String? source) {
    if (source == null || source.isEmpty) return null;
    final Map<String, dynamic> decoded = jsonDecode(source);
    return fromJson(decoded);
  }

  String toJsonString() => jsonEncode(toJson());
}
