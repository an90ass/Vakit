import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namaz/models/prayer_times_model.dart';

class WidgetService {
  static const String _widgetName = 'PrayerTimeWidget';
  static const String _androidWidgetName = 'PrayerTimeWidgetProvider';
  static const String _iosWidgetName = 'PrayerTimeWidget';

  /// Widget'ı namaz vakitleri ile günceller
  static Future<void> updateWidget(
    BuildContext context,
    PrayerTimes prayerTimes,
    String nextPrayer,
    Duration timeRemaining,
  ) async {
    try {
      // Localization için context'ten dil bilgisini al
      final locale = Localizations.localeOf(context);
      final languageCode = locale.languageCode;
      
      // Dile göre etiketler
      String nextPrayerLabel;
      String remainingLabel;
      
      if (languageCode == 'tr') {
        nextPrayerLabel = 'Bir sonraki namaz';
        remainingLabel = 'kaldı';
      } else if (languageCode == 'ar') {
        nextPrayerLabel = 'الصلاة القادمة';
        remainingLabel = 'متبقي';
      } else {
        nextPrayerLabel = 'Next prayer';
        remainingLabel = 'remaining';
      }
      
      // Namaz ismini localize et
      final localizedPrayerName = _getLocalizedPrayerName(nextPrayer, languageCode);
      
      // Widget verilerini kaydet
      await HomeWidget.saveWidgetData<String>('next_prayer', localizedPrayerName);
      await HomeWidget.saveWidgetData<String>('time_remaining', _formatDuration(timeRemaining));
      await HomeWidget.saveWidgetData<String>('next_prayer_label', nextPrayerLabel);
      await HomeWidget.saveWidgetData<String>('remaining_label', remainingLabel);
      
      // Namaz vakitleri
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
    final hours = duration.inHours.abs();
    final minutes = duration.inMinutes.remainder(60).abs();
    final seconds = duration.inSeconds.remainder(60).abs();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  static String _getLocalizedPrayerName(String prayerName, String languageCode) {
    switch (prayerName) {
      case 'Imsak':
      case 'Fajr':
        if (languageCode == 'tr') return 'İmsak';
        if (languageCode == 'ar') return 'الفجر';
        return 'Fajr';
      case 'Sunrise':
        if (languageCode == 'tr') return 'Güneş';
        if (languageCode == 'ar') return 'الشروق';
        return 'Sunrise';
      case 'Dhuhr':
        if (languageCode == 'tr') return 'Öğle';
        if (languageCode == 'ar') return 'الظهر';
        return 'Dhuhr';
      case 'Asr':
        if (languageCode == 'tr') return 'İkindi';
        if (languageCode == 'ar') return 'العصر';
        return 'Asr';
      case 'Maghrib':
        if (languageCode == 'tr') return 'Akşam';
        if (languageCode == 'ar') return 'المغرب';
        return 'Maghrib';
      case 'Isha':
        if (languageCode == 'tr') return 'Yatsı';
        if (languageCode == 'ar') return 'العشاء';
        return 'Isha';
      default:
        return prayerName;
    }
  }
}
