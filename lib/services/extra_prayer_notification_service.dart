import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:namaz/models/extra_prayer_type.dart';
import 'package:namaz/models/prayer_times_model.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ExtraPrayerNotificationService {
  ExtraPrayerNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _notifications = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'extra_prayer_channel';
  static const _channelName = 'Extra Prayers';
  static const _channelDescription = 'Hatırlatıcılar için bildirim kanalı';

  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'open',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );
    await _notifications.initialize(initSettings);

    tz_data.initializeTimeZones();
    // Set the local location to UTC as a fallback
    tz.setLocalLocation(tz.getLocation('UTC'));

    _initialized = true;
  }

  Future<void> scheduleExtraPrayers(
    List<String> extraPrayerIds,
    PrayerTimes times,
  ) async {
    await init();
    await cancelExtraPrayerNotifications();
    if (extraPrayerIds.isEmpty) return;

    for (final id in extraPrayerIds) {
      final type = _typeFromId(id);
      if (type == null) continue;
      final reminderTime = type.resolveReminderTime(times);
      if (reminderTime == null) continue;
      final scheduleDate = _nextInstance(reminderTime);
      await _notifications.zonedSchedule(
        _notificationIdFor(id),
        type.title,
        type.description,
        scheduleDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelExtraPrayerNotifications() async {
    await init();
    for (final type in ExtraPrayerType.values) {
      await _notifications.cancel(_notificationIdFor(type.id));
    }
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
    linux: LinuxNotificationDetails(),
  );

  int _notificationIdFor(String id) => id.hashCode & 0x7fffffff;

  tz.TZDateTime _nextInstance(DateTime target) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      target.hour,
      target.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  ExtraPrayerType? _typeFromId(String id) {
    for (final type in ExtraPrayerType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}