import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:vakit/hive/prayer_day.dart';
import 'package:vakit/models/prayer_times_model.dart';
import 'package:vakit/repositories/qada_repository.dart';

/// Intelligent Prayer Notification Service with Nagging System
///
/// This service implements a 3-phase notification system:
/// 1. Phase 1 (Reminder): Normal notification when prayer time enters
/// 2. Phase 2 (Nagging): Increasing frequency reminders as time runs out
/// 3. Phase 3 (Missed): Spiritual warning when prayer is missed + auto Qada recording
class IntelligentNotificationService {
  static final IntelligentNotificationService _instance =
      IntelligentNotificationService._internal();
  factory IntelligentNotificationService() => _instance;
  IntelligentNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Timer? _naggingTimer;
  Timer? _missedCheckTimer;

  // Notification channels
  static const String _prayerChannelId = 'prayer_notifications';
  static const String _naggingChannelId = 'prayer_nagging';
  static const String _missedChannelId = 'prayer_missed';

  // Notification ID bases
  static const int _fajrBase = 100;
  static const int _dhuhrBase = 200;
  static const int _asrBase = 300;
  static const int _maghribBase = 400;
  static const int _ishaBase = 500;

  // Nagging intervals in minutes (increasing frequency)
  static const List<int> _naggingIntervals = [30, 15, 10, 5, 2, 1];

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTapped(response);
      },
    );

    await _createNotificationChannels();
    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      // Main prayer notification channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _prayerChannelId,
          'Namaz Vakti Bildirimleri',
          description: 'Namaz vakti girdiğinde bildirim',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Nagging reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _naggingChannelId,
          'Namaz Hatırlatıcısı',
          description: 'Vakit çıkmadan önce artan sıklıkta hatırlatmalar',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Missed prayer channel (more urgent)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _missedChannelId,
          'Kaçırılan Namaz',
          description: 'Namaz kaçırıldığında manevi uyarı',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  /// Schedule all prayer notifications for the day
  Future<void> scheduleDailyNotifications(
    PrayerTimes prayerTimes,
    String languageCode,
  ) async {
    await initialize();
    await cancelAllNotifications();

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    if (!notificationsEnabled) return;

    final now = DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Schedule for each prayer
    await _schedulePrayerNotifications(
      'Fajr',
      prayerTimes.timings['Imsak'] ?? '',
      prayerTimes.timings['Sunrise'] ?? '',
      _fajrBase,
      languageCode,
      dateKey,
    );
    await _schedulePrayerNotifications(
      'Dhuhr',
      prayerTimes.timings['Dhuhr'] ?? '',
      prayerTimes.timings['Asr'] ?? '',
      _dhuhrBase,
      languageCode,
      dateKey,
    );
    await _schedulePrayerNotifications(
      'Asr',
      prayerTimes.timings['Asr'] ?? '',
      prayerTimes.timings['Maghrib'] ?? '',
      _asrBase,
      languageCode,
      dateKey,
    );
    await _schedulePrayerNotifications(
      'Maghrib',
      prayerTimes.timings['Maghrib'] ?? '',
      prayerTimes.timings['Isha'] ?? '',
      _maghribBase,
      languageCode,
      dateKey,
    );
    await _schedulePrayerNotifications(
      'Isha',
      prayerTimes.timings['Isha'] ?? '',
      _getNextFajr(prayerTimes.timings['Imsak'] ?? ''),
      _ishaBase,
      languageCode,
      dateKey,
    );

    // Start monitoring for missed prayers
    _startMissedPrayerMonitoring(prayerTimes, dateKey, languageCode);
  }

  String _getNextFajr(String fajrTime) {
    // Add 24 hours equivalent for Isha end time (next day's Fajr)
    final parts = fajrTime.split(':');
    if (parts.length < 2) return '05:30';
    return fajrTime; // Will be handled as next day in scheduling
  }

  Future<void> _schedulePrayerNotifications(
    String prayerName,
    String startTime,
    String endTime,
    int baseId,
    String languageCode,
    String dateKey,
  ) async {
    if (startTime.isEmpty || endTime.isEmpty) return;

    final now = DateTime.now();
    final prayerStart = _parseTime(startTime, now);
    final prayerEnd = _parseTime(endTime, now, isNextDay: prayerName == 'Isha');

    if (prayerStart == null || prayerEnd == null) return;

    final localizedName = _getLocalizedPrayerName(prayerName, languageCode);

    // Phase 1: Prayer time entry notification
    if (prayerStart.isAfter(now)) {
      await _scheduleNotification(
        id: baseId,
        title: _getPhase1Title(localizedName, languageCode),
        body: _getPhase1Body(localizedName, languageCode),
        scheduledTime: prayerStart,
        channelId: _prayerChannelId,
        payload: '$prayerName:start:$dateKey',
      );
    }

    // Phase 2: Nagging notifications (increasing frequency)
    await _scheduleNaggingNotifications(
      prayerName: prayerName,
      localizedName: localizedName,
      prayerEnd: prayerEnd,
      baseId: baseId,
      languageCode: languageCode,
      dateKey: dateKey,
    );

    // Phase 3: Missed prayer notification
    if (prayerEnd.isAfter(now)) {
      await _scheduleNotification(
        id: baseId + 50, // Offset for missed notification
        title: _getPhase3Title(localizedName, languageCode),
        body: _getPhase3Body(localizedName, languageCode),
        scheduledTime: prayerEnd.add(const Duration(minutes: 1)),
        channelId: _missedChannelId,
        payload: '$prayerName:missed:$dateKey',
      );
    }
  }

  Future<void> _scheduleNaggingNotifications({
    required String prayerName,
    required String localizedName,
    required DateTime prayerEnd,
    required int baseId,
    required String languageCode,
    required String dateKey,
  }) async {
    final now = DateTime.now();

    for (int i = 0; i < _naggingIntervals.length; i++) {
      final minutesBefore = _naggingIntervals[i];
      final notifyTime = prayerEnd.subtract(Duration(minutes: minutesBefore));

      if (notifyTime.isAfter(now)) {
        await _scheduleNotification(
          id: baseId + 10 + i,
          title: _getNaggingTitle(localizedName, minutesBefore, languageCode),
          body: _getNaggingBody(localizedName, minutesBefore, languageCode),
          scheduledTime: notifyTime,
          channelId: _naggingChannelId,
          payload: '$prayerName:nagging:$minutesBefore:$dateKey',
        );
      }
    }
  }

  void _startMissedPrayerMonitoring(
    PrayerTimes prayerTimes,
    String dateKey,
    String languageCode,
  ) {
    _missedCheckTimer?.cancel();

    // Check every 5 minutes for missed prayers
    _missedCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkMissedPrayers(prayerTimes, dateKey, languageCode),
    );
  }

  Future<void> _checkMissedPrayers(
    PrayerTimes prayerTimes,
    String dateKey,
    String languageCode,
  ) async {
    final now = DateTime.now();
    final prayers = [
      (
        'Fajr',
        prayerTimes.timings['Imsak'] ?? '',
        prayerTimes.timings['Sunrise'] ?? '',
      ),
      (
        'Dhuhr',
        prayerTimes.timings['Dhuhr'] ?? '',
        prayerTimes.timings['Asr'] ?? '',
      ),
      (
        'Asr',
        prayerTimes.timings['Asr'] ?? '',
        prayerTimes.timings['Maghrib'] ?? '',
      ),
      (
        'Maghrib',
        prayerTimes.timings['Maghrib'] ?? '',
        prayerTimes.timings['Isha'] ?? '',
      ),
    ];

    for (final (name, _, end) in prayers) {
      final endTime = _parseTime(end, now);
      if (endTime != null && now.isAfter(endTime)) {
        // Check if prayer was marked as done
        final isDone = await _isPrayerDone(name, dateKey);
        if (!isDone) {
          // Auto-record as Qada
          await _recordMissedPrayer(name, dateKey);
        }
      }
    }
  }

  Future<bool> _isPrayerDone(String prayerName, String dateKey) async {
    try {
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
    } catch (e) {
      return false;
    }
  }

  Future<void> _recordMissedPrayer(String prayerName, String dateKey) async {
    try {
      final box = await Hive.openBox(QadaRepository.boxName);
      final repo = QadaRepository(box);
      await repo.recordMissedPrayer(dateKey: dateKey, prayerName: prayerName);
      debugPrint('Missed prayer recorded: $prayerName on $dateKey');
    } catch (e) {
      debugPrint('Error recording missed prayer: $e');
    }
  }

  DateTime? _parseTime(
    String timeString,
    DateTime baseDate, {
    bool isNextDay = false,
  }) {
    try {
      final parts = timeString.split(':');
      if (parts.length < 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);

      var result = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
      if (isNextDay) {
        result = result.add(const Duration(days: 1));
      }
      return result;
    } catch (e) {
      return null;
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
          channelId == _missedChannelId
              ? 'Kaçırılan Namaz'
              : 'Namaz Hatırlatıcı',
          importance:
              channelId == _missedChannelId ? Importance.max : Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel notifications when prayer is marked as done
  Future<void> onPrayerMarkedAsDone(String prayerName) async {
    final baseId = _getBaseId(prayerName);
    if (baseId == null) return;

    // Cancel all related notifications
    for (int i = 0; i < 60; i++) {
      await _notificationsPlugin.cancel(baseId + i);
    }
  }

  int? _getBaseId(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return _fajrBase;
      case 'Dhuhr':
        return _dhuhrBase;
      case 'Asr':
        return _asrBase;
      case 'Maghrib':
        return _maghribBase;
      case 'Isha':
        return _ishaBase;
      default:
        return null;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _naggingTimer?.cancel();
    _missedCheckTimer?.cancel();
  }

  // Localization methods
  String _getLocalizedPrayerName(String prayerName, String languageCode) {
    final names = {
      'tr': {
        'Fajr': 'Sabah',
        'Dhuhr': 'Öğle',
        'Asr': 'İkindi',
        'Maghrib': 'Akşam',
        'Isha': 'Yatsı',
      },
      'ar': {
        'Fajr': 'الفجر',
        'Dhuhr': 'الظهر',
        'Asr': 'العصر',
        'Maghrib': 'المغرب',
        'Isha': 'العشاء',
      },
      'en': {
        'Fajr': 'Fajr',
        'Dhuhr': 'Dhuhr',
        'Asr': 'Asr',
        'Maghrib': 'Maghrib',
        'Isha': 'Isha',
      },
    };
    return names[languageCode]?[prayerName] ?? prayerName;
  }

  String _getPhase1Title(String localizedName, String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '$localizedName Vakti Girdi';
      case 'ar':
        return 'دخل وقت $localizedName';
      default:
        return '$localizedName Time Has Entered';
    }
  }

  String _getPhase1Body(String localizedName, String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '$localizedName namazını kılmayı unutma! Haydi namaza.';
      case 'ar':
        return 'لا تنسَ صلاة $localizedName! هيا للصلاة.';
      default:
        return 'Don\'t forget to pray $localizedName! Let\'s pray.';
    }
  }

  String _getNaggingTitle(
    String localizedName,
    int minutes,
    String languageCode,
  ) {
    switch (languageCode) {
      case 'tr':
        return '$localizedName Vakti Çıkmak Üzere!';
      case 'ar':
        return 'وقت $localizedName على وشك الانتهاء!';
      default:
        return '$localizedName Time Is Almost Over!';
    }
  }

  String _getNaggingBody(
    String localizedName,
    int minutes,
    String languageCode,
  ) {
    switch (languageCode) {
      case 'tr':
        return '$minutes dakika kaldı! Namazını kıl, kaçırma!';
      case 'ar':
        return 'بقي $minutes دقيقة! صلِّ قبل فوات الأوان!';
      default:
        return '$minutes minutes left! Pray before it\'s too late!';
    }
  }

  String _getPhase3Title(String localizedName, String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '😔 $localizedName Namazı Kaçırıldı';
      case 'ar':
        return '😔 فاتتك صلاة $localizedName';
      default:
        return '😔 $localizedName Prayer Missed';
    }
  }

  String _getPhase3Body(String localizedName, String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Maalesef $localizedName vaktini kaçırdın. Bu büyük bir kayıp. Kaza namazlarına otomatik eklendi, lütfen en kısa zamanda telafi et. Allah affetsin.';
      case 'ar':
        return 'للأسف فاتتك صلاة $localizedName. هذه خسارة كبيرة. تمت إضافتها تلقائياً إلى صلوات القضاء. الرجاء التعويض في أقرب وقت.';
      default:
        return 'Unfortunately you missed $localizedName. This is a significant loss. It has been automatically added to your Qada prayers. Please make it up as soon as possible.';
    }
  }
}
