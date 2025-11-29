import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:vakit/hive/prayer_day.dart';
import 'package:vakit/models/prayer_times_model.dart';

class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();
  factory PrayerNotificationService() => _instance;
  PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Bildirim kanalları
  static const String _prayerChannelId = 'prayer_notifications';
  static const String _reminderChannelId = 'prayer_reminders';

  // Bildirim ID'leri
  static const int _fajrId = 100;
  static const int _dhuhrId = 200;
  static const int _asrId = 300;
  static const int _maghribId = 400;
  static const int _ishaId = 500;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android bildirim kanallarini olustur
    await _createNotificationChannels();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      // Ana namaz bildirimi kanali
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _prayerChannelId,
          'Namaz Vakti Bildirimleri',
          description: 'Namaz vakti geldiginde bildirim gonderir',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Hatirlatma bildirimi kanali
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          'Namaz Hatirlatmalari',
          description: 'Namaz vakti yaklastiginda hatirlatma gonderir',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Bildirime tiklandiginda yapilacak islem
    print('Bildirime tiklandi: ${response.payload}');
  }

  /// Tum namaz bildirimlerini planla
  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    await initialize();

    // Mevcut bildirimleri temizle
    await cancelAllNotifications();

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) return;

    final preNotificationMinutes =
        int.tryParse(prefs.getString('notificationBeforeMinutes') ?? '5') ?? 5;

    // Her namaz vakti icin bildirim planla
    await _scheduleForPrayer(
      'Fajr',
      prayerTimes.timings['Imsak'] ?? '',
      _fajrId,
      preNotificationMinutes,
    );
    await _scheduleForPrayer(
      'Dhuhr',
      prayerTimes.timings['Dhuhr'] ?? '',
      _dhuhrId,
      preNotificationMinutes,
    );
    await _scheduleForPrayer(
      'Asr',
      prayerTimes.timings['Asr'] ?? '',
      _asrId,
      preNotificationMinutes,
    );
    await _scheduleForPrayer(
      'Maghrib',
      prayerTimes.timings['Maghrib'] ?? '',
      _maghribId,
      preNotificationMinutes,
    );
    await _scheduleForPrayer(
      'Isha',
      prayerTimes.timings['Isha'] ?? '',
      _ishaId,
      preNotificationMinutes,
    );
  }

  Future<void> _scheduleForPrayer(
    String prayerName,
    String timeString,
    int baseId,
    int preMinutes,
  ) async {
    if (timeString.isEmpty) return;

    final parts = timeString.split(':');
    if (parts.length < 2) return;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1].split(' ')[0]) ?? 0;

    final now = DateTime.now();
    var prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

    // Eger vakit gecmisse yarin icin planla
    if (prayerTime.isBefore(now)) {
      prayerTime = prayerTime.add(const Duration(days: 1));
    }

    // Namaz oncesi hatirlatma (5 dk once, 2 kez)
    final preTime1 = prayerTime.subtract(Duration(minutes: preMinutes));
    final preTime2 = prayerTime.subtract(Duration(minutes: preMinutes ~/ 2));

    if (preTime1.isAfter(now)) {
      await _scheduleNotification(
        id: baseId + 1,
        title: _getLocalizedTitle(prayerName, 'reminder'),
        body: _getLocalizedBody(prayerName, preMinutes, 'pre'),
        scheduledTime: preTime1,
        channelId: _reminderChannelId,
        payload: '$prayerName:reminder:1',
      );
    }

    if (preTime2.isAfter(now)) {
      await _scheduleNotification(
        id: baseId + 2,
        title: _getLocalizedTitle(prayerName, 'reminder'),
        body: _getLocalizedBody(prayerName, preMinutes ~/ 2, 'pre'),
        scheduledTime: preTime2,
        channelId: _reminderChannelId,
        payload: '$prayerName:reminder:2',
      );
    }

    // Vakit girisi bildirimi
    if (prayerTime.isAfter(now)) {
      await _scheduleNotification(
        id: baseId,
        title: _getLocalizedTitle(prayerName, 'time'),
        body: _getLocalizedBody(prayerName, 0, 'time'),
        scheduledTime: prayerTime,
        channelId: _prayerChannelId,
        payload: '$prayerName:time',
      );
    }
  }

  /// Artan siklikta bildirim gonder (nagging)
  Future<void> scheduleNaggingNotifications(
    String prayerName,
    DateTime prayerEnd,
    int baseId,
  ) async {
    final now = DateTime.now();
    final remaining = prayerEnd.difference(now);

    if (remaining.inMinutes <= 0) return;

    // Son 30 dakika icinde artan siklikta bildirim
    final intervals = <int>[];

    if (remaining.inMinutes > 30) {
      intervals.add(30);
    }
    if (remaining.inMinutes > 15) {
      intervals.add(15);
    }
    if (remaining.inMinutes > 10) {
      intervals.add(10);
    }
    if (remaining.inMinutes > 5) {
      intervals.add(5);
    }
    if (remaining.inMinutes > 2) {
      intervals.add(2);
    }

    for (int i = 0; i < intervals.length; i++) {
      final notifyTime = prayerEnd.subtract(Duration(minutes: intervals[i]));
      if (notifyTime.isAfter(now)) {
        await _scheduleNotification(
          id: baseId + 10 + i,
          title: '$prayerName Vakti Cikmak Uzere!',
          body: '${intervals[i]} dakika kaldi. Namazi kacirmayin!',
          scheduledTime: notifyTime,
          channelId: _reminderChannelId,
          payload: '$prayerName:nagging:${intervals[i]}',
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    String? payload,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == _prayerChannelId ? 'Namaz Vakti' : 'Hatirlatma',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      payload: payload,
    );
  }

  /// Belirli bir namaz icin bildirimi iptal et
  Future<void> cancelPrayerNotification(String prayerName) async {
    int baseId;
    switch (prayerName) {
      case 'Fajr':
        baseId = _fajrId;
        break;
      case 'Dhuhr':
        baseId = _dhuhrId;
        break;
      case 'Asr':
        baseId = _asrId;
        break;
      case 'Maghrib':
        baseId = _maghribId;
        break;
      case 'Isha':
        baseId = _ishaId;
        break;
      default:
        return;
    }

    // Tum ilgili bildirimleri iptal et
    for (int i = 0; i < 20; i++) {
      await _notificationsPlugin.cancel(baseId + i);
    }
  }

  /// Tum bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Namaz kilindiginda bildirimleri iptal et
  Future<void> onPrayerMarkedAsDone(String prayerName) async {
    await cancelPrayerNotification(prayerName);
  }

  /// Namazin kilinip kilinmadigini kontrol et
  Future<bool> isPrayerDone(String prayerName, String dateKey) async {
    final box = Hive.box<PrayerDay>('prayers');
    final prayerDay = box.get(dateKey);

    if (prayerDay == null) return false;

    switch (prayerName) {
      case 'Fajr':
        return prayerDay.fajrStatus ?? false;
      case 'Dhuhr':
        return prayerDay.dhuhrStatus ?? false;
      case 'Asr':
        return prayerDay.asrStatus ?? false;
      case 'Maghrib':
        return prayerDay.maghribStatus ?? false;
      case 'Isha':
        return prayerDay.ishaStatus ?? false;
      default:
        return false;
    }
  }

  String _getLocalizedTitle(String prayerName, String type) {
    final localizedName = _getLocalizedPrayerName(prayerName);
    if (type == 'reminder') {
      return '$localizedName Hatirlatmasi';
    }
    return '$localizedName Vakti';
  }

  String _getLocalizedBody(String prayerName, int minutes, String type) {
    final localizedName = _getLocalizedPrayerName(prayerName);
    if (type == 'pre') {
      return '$localizedName vaktine $minutes dakika kaldi';
    }
    return '$localizedName vakti girdi. Haydi namaza!';
  }

  String _getLocalizedPrayerName(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 'Sabah';
      case 'Dhuhr':
        return 'Ogle';
      case 'Asr':
        return 'Ikindi';
      case 'Maghrib':
        return 'Aksam';
      case 'Isha':
        return 'Yatsi';
      default:
        return prayerName;
    }
  }
}
