class QadaRecord {
  const QadaRecord({
    required this.dateKey,
    required this.prayerName,
    required this.missedAt,
    this.resolvedAt,
  });

  final String dateKey;
  final String prayerName;
  final DateTime missedAt;
  final DateTime? resolvedAt;

  String get id => '${dateKey}_$prayerName';

  bool get isResolved => resolvedAt != null;

  QadaRecord copyWith({DateTime? resolvedAt}) {
    return QadaRecord(
      dateKey: dateKey,
      prayerName: prayerName,
      missedAt: missedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'prayerName': prayerName,
      'missedAt': missedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  static QadaRecord fromMap(Map<dynamic, dynamic> map) {
    return QadaRecord(
      dateKey: map['dateKey'] as String,
      prayerName: map['prayerName'] as String,
      missedAt: DateTime.parse(map['missedAt'] as String),
      resolvedAt:
          map['resolvedAt'] == null
              ? null
              : DateTime.parse(map['resolvedAt'] as String),
    );
  }
}
