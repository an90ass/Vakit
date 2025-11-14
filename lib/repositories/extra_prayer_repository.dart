import 'package:hive/hive.dart';

class ExtraPrayerRepository {
  ExtraPrayerRepository(Box box) : _box = box;

  static const boxName = 'extra-prayer-logs';

  final Box _box;

  Map<String, bool?> loadStatuses(String dateKey) {
    final raw = _box.get(dateKey);
    if (raw is Map) {
      return Map<String, bool?>.from(
        raw.map((key, value) => MapEntry(key.toString(), value as bool?)),
      );
    }
    return {};
  }

  Future<void> updateStatus(
    String dateKey,
    String prayerId,
    bool status,
  ) async {
    final current = loadStatuses(dateKey);
    current[prayerId] = status;
    await _box.put(dateKey, current);
  }
}
