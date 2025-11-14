import 'package:home_widget/home_widget.dart';
import 'package:namaz/models/prayer_times_model.dart';

class WidgetService {
  static const String _widgetName = 'PrayerTimeWidget';
  static const String _androidWidgetName = 'PrayerTimeWidgetProvider';
  static const String _iosWidgetName = 'PrayerTimeWidget';

  /// Widget'ı namaz vakitleri ile günceller
  static Future<void> updateWidget(PrayerTimes prayerTimes, String nextPrayer, Duration timeRemaining) async {
    try {
      // Widget verilerini kaydet
      await HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer);
      await HomeWidget.saveWidgetData<String>('time_remaining', _formatDuration(timeRemaining));
      await HomeWidget.saveWidgetData<String>('fajr', prayerTimes.timings['Imsak'] ?? '');
      await HomeWidget.saveWidgetData<String>('sunrise', prayerTimes.timings['Sunrise'] ?? '');
      await HomeWidget.saveWidgetData<String>('dhuhr', prayerTimes.timings['Dhuhr'] ?? '');
      await HomeWidget.saveWidgetData<String>('asr', prayerTimes.timings['Asr'] ?? '');
      await HomeWidget.saveWidgetData<String>('maghrib', prayerTimes.timings['Maghrib'] ?? '');
      await HomeWidget.saveWidgetData<String>('isha', prayerTimes.timings['Isha'] ?? '');
      
      // Widget'ı güncelle
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      print('Widget güncellenirken hata: $e');
    }
  }

  /// Widget'dan gelen tıklamaları dinle
  static void setupInteractivity() {
    HomeWidget.setAppGroupId('group.com.vakit.namaz');
    HomeWidget.widgetClicked.listen((uri) {
      // Widget'a tıklandığında yapılacak işlemler
      print('Widget tıklandı: $uri');
    });
  }

  /// Widget'ı başlat
  static Future<void> initializeWidget() async {
    await HomeWidget.setAppGroupId('group.com.vakit.namaz');
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).abs();
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    final seconds = duration.inSeconds.remainder(60).abs();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
