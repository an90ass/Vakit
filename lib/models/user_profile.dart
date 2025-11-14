import 'dart:convert';
import 'package:hijri/hijri_calendar.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.birthYear,
    required this.gender,
    required this.qadaModeEnabled,
    required this.extraPrayers,
    required this.extraPrayerNotifications,
    required this.createdAt,
    this.profileImagePath,
  });

  final String name;
  final int birthYear;
  final String gender;
  final bool qadaModeEnabled;
  final List<String> extraPrayers;
  final bool extraPrayerNotifications;
  final DateTime createdAt;
  final String? profileImagePath;

  int get age {
    final now = DateTime.now();
    return now.year - birthYear;
  }

  int get hijriAge {
    try {
      final birthDate = DateTime(birthYear, 1, 1);
      final hijriBirth = HijriCalendar.fromDate(birthDate);
      final hijriNow = HijriCalendar.now();
      return hijriNow.hYear - hijriBirth.hYear;
    } catch (e) {
      return age;
    }
  }

  UserProfile copyWith({
    String? name,
    int? birthYear,
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
      birthYear: json['birthYear'] as int? ?? DateTime.now().year,
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
