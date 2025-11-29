import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakit/models/prayer_times_model.dart';

class WidgetService {
  static const String _androidWidgetName = 'PrayerTimeWidgetProvider';
  static const String _iosWidgetName = 'PrayerTimeWidget';

  // Platform channel for native service communication
  static const MethodChannel _channel = MethodChannel(
    'com.vakit.widget/service',
  );

  /// Native Android widget servisini başlat
  static Future<void> startNativeWidgetService() async {
    try {
      await _channel.invokeMethod('startWidgetService');
      debugPrint('Native widget servisi başlatıldı');
    } catch (e) {
      debugPrint('Native widget servisi başlatılamadı: $e');
    }
  }

  /// Native Android widget servisini durdur
  static Future<void> stopNativeWidgetService() async {
    try {
      await _channel.invokeMethod('stopWidgetService');
      debugPrint('Native widget servisi durduruldu');
    } catch (e) {
      debugPrint('Native widget servisi durdurulamadı: $e');
    }
  }

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

      // Dil ayarını kaydet (background için)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('widget_language', languageCode);

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
      final localizedPrayerName = _getLocalizedPrayerName(
        nextPrayer,
        languageCode,
      );

      // Widget verilerini kaydet
      await HomeWidget.saveWidgetData<String>(
        'next_prayer',
        localizedPrayerName,
      );

      // Hedef zamanı kaydet (Native Chronometer için)
      final endTime = DateTime.now().add(timeRemaining);
      await savePrayerEndTime(endTime);

      // Format time remaining as HH:mm:ss
      final hours = timeRemaining.inHours.toString().padLeft(2, '0');
      final minutes = (timeRemaining.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (timeRemaining.inSeconds % 60).toString().padLeft(2, '0');
      final timeString = '$hours:$minutes:$seconds';

      await HomeWidget.saveWidgetData<String>('time_remaining', timeString);

      await HomeWidget.saveWidgetData<String>(
        'next_prayer_label',
        nextPrayerLabel,
      );
      await HomeWidget.saveWidgetData<String>(
        'remaining_label',
        remainingLabel,
      );

      // Namaz vakitlerini localize edilmiş şekilde kaydet
      await HomeWidget.saveWidgetData<String>(
        'fajr',
        prayerTimes.timings['Imsak'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'fajr_label',
        _getLocalizedPrayerName('Fajr', languageCode),
      );
      await HomeWidget.saveWidgetData<String>(
        'sunrise',
        prayerTimes.timings['Sunrise'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'sunrise_label',
        _getLocalizedPrayerName('Sunrise', languageCode),
      );
      await HomeWidget.saveWidgetData<String>(
        'dhuhr',
        prayerTimes.timings['Dhuhr'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'dhuhr_label',
        _getLocalizedPrayerName('Dhuhr', languageCode),
      );
      await HomeWidget.saveWidgetData<String>(
        'asr',
        prayerTimes.timings['Asr'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'asr_label',
        _getLocalizedPrayerName('Asr', languageCode),
      );
      await HomeWidget.saveWidgetData<String>(
        'maghrib',
        prayerTimes.timings['Maghrib'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'maghrib_label',
        _getLocalizedPrayerName('Maghrib', languageCode),
      );
      await HomeWidget.saveWidgetData<String>(
        'isha',
        prayerTimes.timings['Isha'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'isha_label',
        _getLocalizedPrayerName('Isha', languageCode),
      );

      // Son güncelleme zamanını kaydet
      await HomeWidget.saveWidgetData<int>(
        'last_update',
        DateTime.now().millisecondsSinceEpoch,
      );

      // Widget'ı güncelle
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );

      debugPrint(
        'Widget başarıyla güncellendi - Dil: $languageCode, Vakit: $localizedPrayerName',
      );
    } catch (e) {
      debugPrint('Widget güncellenirken hata: $e');
    }
  }

  /// Widget'dan gelen tıklamaları dinle
  static void setupInteractivity() {
    HomeWidget.setAppGroupId('group.com.vakit.namaz');
    HomeWidget.widgetClicked.listen((uri) {
      // Widget'a tıklandığında yapılacak işlemler
      debugPrint('Widget tıklandı: $uri');
    });
  }

  /// Widget'ı başlat
  static Future<void> initializeWidget() async {
    await HomeWidget.setAppGroupId('group.com.vakit.namaz');

    // Widget için background update callback'i ayarla
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  /// Background callback - uygulama kapalıyken widget güncellemeleri
  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'updatewidget') {
      await updateWidgetInBackground();
    }
  }

  /// Arkaplan widget güncellemesi
  static Future<void> updateWidgetInBackground() async {
    try {
      // Native widget Chronometer kullandığı için manuel güncellemeye gerek yok
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );

      debugPrint('Widget arkaplan güncellemesi tamamlandı');
    } catch (e) {
      debugPrint('Arkaplan widget güncellemesi hatası: $e');
    }
  }

  /// Sonraki namaz vakti bitiş zamanını kaydet (geri sayım için)
  static Future<void> savePrayerEndTime(DateTime endTime) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'prayer_end_time',
        endTime.millisecondsSinceEpoch.toString(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('prayer_end_time', endTime.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Namaz bitiş zamanı kaydedilirken hata: $e');
    }
  }

  static String _getLocalizedPrayerName(
    String prayerName,
    String languageCode,
  ) {
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
      case 'Sunset':
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
