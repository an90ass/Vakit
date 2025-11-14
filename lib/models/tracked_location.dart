import 'package:equatable/equatable.dart';

class TrackedLocation extends Equatable {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final bool isAuto;

  const TrackedLocation({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.isAuto = false,
  });

  TrackedLocation copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    bool? isAuto,
  }) {
    return TrackedLocation(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAuto: isAuto ?? this.isAuto,
    );
  }

  factory TrackedLocation.fromJson(Map<String, dynamic> json) {
    return TrackedLocation(
      id: json['id'] as String,
      title: json['title'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isAuto: json['isAuto'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'isAuto': isAuto,
    };
  }

  @override
  List<Object?> get props => [id, title, latitude, longitude, isAuto];
}
