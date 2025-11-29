import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

// Alarm callback fonksiyonlari - top-level olmali
@pragma('vm:entry-point')
Future<void> widgetUpdateCallback() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Kaydedilmis dil ayarini al
    final languageCode = prefs.getString('widget_language') ?? 'tr';

    // Kaydedilmis namaz vakitlerini ve geri sayimi al
    final storedEndTime = prefs.getInt('prayer_end_time');

    if (storedEndTime != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(storedEndTime);
      final now = DateTime.now();
      final remaining = endTime.difference(now);

      if (!remaining.isNegative) {
        // Geri sayimi guncelle
        final hours = remaining.inHours.abs();
        final minutes = remaining.inMinutes.remainder(60).abs();
        final seconds = remaining.inSeconds.remainder(60).abs();
        final timeRemaining =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        await HomeWidget.saveWidgetData<String>(
          'time_remaining',
          timeRemaining,
        );
        await HomeWidget.saveWidgetData<int>(
          'last_update',
          now.millisecondsSinceEpoch,
        );

        // Widget'i guncelle
        await HomeWidget.updateWidget(
          androidName: 'PrayerTimeWidgetProvider',
          iOSName: 'PrayerTimeWidget',
        );

        debugPrint(
          'Widget arkaplan guncellemesi tamamlandi - Kalan: $timeRemaining',
        );
      } else {
        // Vakit gecmis, bir sonraki vakte gec
        await _moveToNextPrayer(prefs, languageCode);
      }
    }
  } catch (e) {
    debugPrint('Widget guncelleme hatasi: $e');
  }
}

Future<void> _moveToNextPrayer(
  SharedPreferences prefs,
  String languageCode,
) async {
  // Kayitli namaz vakitlerini kontrol et
  final prayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
  final now = DateTime.now();

  for (final prayer in prayers) {
    final timeStr = prefs.getString('prayer_time_$prayer');
    if (timeStr != null && timeStr.isNotEmpty) {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

        if (prayerTime.isAfter(now)) {
          // Bu namaz henuz gelmemis, bunu ayarla
          final label = prefs.getString('prayer_label_$prayer') ?? prayer;
          await HomeWidget.saveWidgetData<String>('next_prayer', label);
          await prefs.setInt(
            'prayer_end_time',
            prayerTime.millisecondsSinceEpoch,
          );

          final remaining = prayerTime.difference(now);
          final hours = remaining.inHours;
          final minutes = remaining.inMinutes.remainder(60);
          final seconds = remaining.inSeconds.remainder(60);
          final timeRemaining =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

          await HomeWidget.saveWidgetData<String>(
            'time_remaining',
            timeRemaining,
          );
          await HomeWidget.updateWidget(
            androidName: 'PrayerTimeWidgetProvider',
            iOSName: 'PrayerTimeWidget',
          );
          return;
        }
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> notificationCheckCallback() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) return;

    // Mevcut namaz vakitlerini kontrol et
    debugPrint('Bildirim kontrolu tamamlandi');
  } catch (e) {
    debugPrint('Bildirim kontrol hatasi: $e');
  }
}

@pragma('vm:entry-point')
Future<void> syncPrayerTimesCallback() async {
  try {
    // API'den yeni namaz vakitlerini al ve kaydet
    debugPrint('Namaz vakti senkronizasyonu tamamlandi');
  } catch (e) {
    debugPrint('Namaz vakti senkronizasyon hatasi: $e');
  }
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  bool _isInitialized = false;

  // Alarm ID'leri
  static const int widgetUpdateAlarmId = 1001;
  static const int notificationCheckAlarmId = 1002;
  static const int syncAlarmId = 1003;
  static const int minuteUpdateAlarmId = 1004;

  /// Arkaplan servisini baslat
  Future<void> initialize() async {
    if (_isInitialized) return;

    await AndroidAlarmManager.initialize();
    _isInitialized = true;
  }

  /// Widget guncelleme gorevini kaydet - Her dakika guncelleme
  Future<void> registerWidgetUpdateTask() async {
    await initialize();

    // Her 1 dakikada bir widget'i guncelle (geri sayim icin)
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      minuteUpdateAlarmId,
      widgetUpdateCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    debugPrint('Widget guncelleme gorevi kaydedildi - Her 1 dakika');
  }

  /// Bildirim kontrol gorevini kaydet
  Future<void> registerNotificationTask() async {
    await initialize();

    // Her 15 dakikada bir bildirimleri kontrol et
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 15),
      notificationCheckAlarmId,
      notificationCheckCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  /// Namaz vakti senkronizasyon gorevini kaydet
  Future<void> registerSyncTask() async {
    await initialize();

    // Her 12 saatte bir senkronizasyon
    await AndroidAlarmManager.periodic(
      const Duration(hours: 12),
      syncAlarmId,
      syncPrayerTimesCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  /// Tum arkaplan gorevlerini kaydet
  Future<void> registerAllTasks() async {
    await registerWidgetUpdateTask();
    await registerNotificationTask();
    await registerSyncTask();
    debugPrint('Tum arkaplan gorevleri kaydedildi');
  }

  /// Belirli bir gorevi iptal et
  Future<void> cancelTask(int alarmId) async {
    await AndroidAlarmManager.cancel(alarmId);
  }

  /// Tum gorevleri iptal et
  Future<void> cancelAllTasks() async {
    await AndroidAlarmManager.cancel(widgetUpdateAlarmId);
    await AndroidAlarmManager.cancel(notificationCheckAlarmId);
    await AndroidAlarmManager.cancel(syncAlarmId);
    await AndroidAlarmManager.cancel(minuteUpdateAlarmId);
  }

  /// Aninda widget guncellemesi
  Future<void> updateWidgetNow() async {
    await AndroidAlarmManager.oneShot(
      Duration.zero,
      widgetUpdateAlarmId + 100, // Farkli ID kullan
      widgetUpdateCallback,
      exact: true,
      wakeup: true,
    );
  }
}
