import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:vakit/models/hijri_date_model.dart';
import 'package:vakit/models/prayer_times_model.dart';


class PrayerRepository {
  final Map<String, String> arabicNumerals = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
  };

  Future<PrayerTimes> fetchPrayerTimes(Position location) async {
    final response = await http.get(Uri.parse(
      'https://api.aladhan.com/v1/timings?latitude=${location.latitude}&longitude=${location.longitude}'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerTimes.fromJson(data['data']['timings']);
    } else {
      throw Exception('Error');
    }
  }

  Future<HijriDate> fetchHijriDate() async {
    final now = DateTime.now();
    final day = now.day + 1;
    final month = now.month;
    final year = now.year;

    final response = await http.get(Uri.parse(
      'https://api.aladhan.com/v1/gToH?date=$day-$month-$year'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hijriData = data['data']['hijri'];

      final dayHijri = hijriData['day'];
      final monthArabic = hijriData['month']['ar'];
      final yearHijri = hijriData['year'];

      final monthTranslations = {
        'محرم': 'Muharrem',
        'صفر': 'Safer',
        'ربيع الأول': 'Rebiülevvel',
        'رَبيع الثاني': 'Rebiülahir',
        'جمادى الأولى': 'Cemaziyelevvel',
        'جمادى الآخرة': 'Cemaziyelahir',
        'رجب': 'Recep',
        'شعبان': 'Şaban',
        'رمضان': 'Ramazan',
        'شوال': 'Şevval',
        'ذو القعدة': 'Zilkade',
        'ذو الحجة': 'Zilhicce',
      };

      final translatedMonth = monthTranslations[monthArabic] ?? monthArabic;

      return HijriDate(
        turkish: '$dayHijri $translatedMonth $yearHijri',
        arabic: '${_toArabicNumerals(dayHijri)} $monthArabic ${_toArabicNumerals(yearHijri)}'
      );
    } else {
      throw Exception('فشل في جلب التاريخ الهجري');
    }
  }

  String _toArabicNumerals(String number) {
    String result = number;
    arabicNumerals.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
}
