import 'package:hive/hive.dart';
import 'package:namaz/models/qada_record.dart';

class QadaRepository {
  QadaRepository(Box box) : _box = box;

  static const boxName = 'qada-records';

  final Box _box;

  Future<void> recordMissedPrayer({
    required String dateKey,
    required String prayerName,
  }) async {
    final record = QadaRecord(
      dateKey: dateKey,
      prayerName: prayerName,
      missedAt: DateTime.now(),
    );
    await _box.put(record.id, record.toMap());
  }

  Future<void> resolvePrayer({
    required String dateKey,
    required String prayerName,
  }) async {
    final id = '${dateKey}_$prayerName';
    final stored = _box.get(id);
    if (stored == null) return;
    final record = QadaRecord.fromMap(
      Map<dynamic, dynamic>.from(stored),
    ).copyWith(resolvedAt: DateTime.now());
    await _box.put(id, record.toMap());
  }

  List<QadaRecord> pendingRecords() {
    return _box.values
        .whereType<Map>()
        .map((value) => QadaRecord.fromMap(value))
        .where((record) => !record.isResolved)
        .toList()
      ..sort((a, b) => a.missedAt.compareTo(b.missedAt));
  }
}
