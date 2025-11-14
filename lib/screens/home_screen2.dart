// import 'package:flutter/material.dart';
// import 'package:hijri/hijri_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
// import 'dart:math';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   Position? _userLocation;
//   Map<String, String>? _prayerTimes;
//   bool _loading = true;
//   String? _errorMessage;
//   Timer? _timer;
//   DateTime _currentTime = DateTime.now();
//   String? _nextPrayerName;
//   DateTime? _nextPrayerTime;
//   String _hijriDate = '';
//   String _hijriDateArabic = '';
//   bool _showArabicText = true;
//   bool _showHijriDate = true;
//   bool _showGregorianDate = true;
//   List<String> _selectedNafilePrayers = [];
//   bool _notificationsEnabled = true;
//   String _notificationBeforeMinutes = '30';
//   bool _notificationSound = true;
//   bool _notificationVibration = true;
  
//   final List<String> _prayerNames = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
//   final List<String> _arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

//   @override
//   void initState() {
//     super.initState();
//     _loadAllSettings();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _currentTime = DateTime.now();
//       });
//       if (_prayerTimes != null) {
//         _calculateNextPrayerTime();
//       }
//     });
//   }

//   Future<void> _loadAllSettings() async {
//     try {
//       await Future.wait([
//         _loadLocationData(),
//         _loadNotificationSettings(),
//         _loadInterfaceSettings(),
//         _loadSelectedNafilePrayers(),
//       ]);
//     } catch (error) {
//       print('Ayarlar yüklenirken hata: $error');
//     }
//   }

//   Future<void> _loadLocationData() async {
//     try {
//       setState(() {
//         _loading = true;
//         _errorMessage = null;
//       });
      
//       final prefs = await SharedPreferences.getInstance();
//       final savedLocationMethod = prefs.getString('locationMethod') ?? 'auto';
      
//       if (savedLocationMethod == 'manual') {
//         final savedLatitude = prefs.getDouble('userLatitude');
//         final savedLongitude = prefs.getDouble('userLongitude');
        
//         if (savedLatitude != null && savedLongitude != null) {
//           _userLocation = Position(
//             latitude: savedLatitude,
//             longitude: savedLongitude,
//             timestamp: DateTime.now(),
//             accuracy: 0,
//             altitude: 0,
//             heading: 0,
//             speed: 0,
//             speedAccuracy: 0,
//             altitudeAccuracy: 0,
//             headingAccuracy: 0,
//           );
//         } else {
//           setState(() {
//             _errorMessage = 'Konum bilgisi bulunamadı. Lütfen ayarlardan konum seçin.';
//             _loading = false;
//           });
//           return;
//         }
//       } else {
//         final savedLatitude = prefs.getDouble('userLatitude');
//         final savedLongitude = prefs.getDouble('userLongitude');
        
//         if (savedLatitude != null && savedLongitude != null) {
//           _userLocation = Position(
//             latitude: savedLatitude,
//             longitude: savedLongitude,
//             timestamp: DateTime.now(),
//             accuracy: 0,
//             altitude: 0,
//             heading: 0,
//             speed: 0,
//             speedAccuracy: 0,
//             altitudeAccuracy: 0,
//             headingAccuracy: 0,
//           );
//         } else {
//           await _requestLocationPermission();
//         }
//       }
      
//       if (_userLocation != null) {
//         await _fetchPrayerTimes();
//       }
      
//       setState(() {
//         _loading = false;
//       });
//     } catch (error) {
//       print('Konum verisi yüklenirken hata: $error');
//       setState(() {
//         _errorMessage = 'Konum bilgileri yüklenirken bir hata oluştu.';
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _loadNotificationSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
//         _notificationBeforeMinutes = prefs.getString('notificationBeforeMinutes') ?? '30';
//         _notificationSound = prefs.getBool('notificationSound') ?? true;
//         _notificationVibration = prefs.getBool('notificationVibration') ?? true;
//       });
//     } catch (error) {
//       print('Bildirim ayarları yüklenirken hata: $error');
//     }
//   }

//   Future<void> _loadInterfaceSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _showArabicText = prefs.getBool('showArabicText') ?? true;
//         _showHijriDate = prefs.getBool('showHijriDate') ?? true;
//         _showGregorianDate = prefs.getBool('showGregorianDate') ?? true;
//       });
//     } catch (error) {
//       print('Arayüz ayarları yüklenirken hata: $error');
//     }
//   }

//   Future<void> _loadSelectedNafilePrayers() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedNafile = prefs.getStringList('selectedNafile') ?? [];
//       setState(() {
//         _selectedNafilePrayers = savedNafile;
//       });
//     } catch (error) {
//       print('Nafile namaz bilgileri yüklenirken hata: $error');
//       setState(() {
//         _selectedNafilePrayers = [];
//       });
//     }
//   }

//   Future<void> _requestLocationPermission() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _errorMessage = 'Konum izni verilmedi. Ayarlardan il ve ilçe seçin.';
//             _loading = false;
//           });
//           return;
//         }
//       }
      
//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _errorMessage = 'Konum izni kalıcı olarak reddedildi. Ayarlardan il ve ilçe seçin.';
//           _loading = false;
//         });
//         return;
//       }
      
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium,
//       );
      
//       _userLocation = position;
      
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('userLatitude', position.latitude);
//       await prefs.setDouble('userLongitude', position.longitude);
//       await prefs.setString('locationMethod', 'auto');
//     } catch (error) {
//       print('Konum alınamadı: $error');
//       setState(() {
//         _errorMessage = 'Konum bilgisi alınamadı. Lütfen ayarlardan manuel konum seçin.';
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _fetchPrayerTimes() async {
//     try {
//       if (_userLocation == null) return;
      
//       setState(() {
//         _loading = true;
//       });
      
//       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//       final url = 'https://api.aladhan.com/v1/timings/$date?latitude=${_userLocation!.latitude}&longitude=${_userLocation!.longitude}&method=3';
      
//       final response = await http.get(Uri.parse(url));
//       final data = json.decode(response.body);
      
//       if (data != null && data['data'] != null && data['data']['timings'] != null) {
//         final timings = data['data']['timings'];
//         setState(() {
//           _prayerTimes = {
//             'İmsak': timings['Fajr'],
//             'Güneş': timings['Sunrise'],
//             'Öğle': timings['Dhuhr'],
//             'İkindi': timings['Asr'],
//             'Akşam': timings['Maghrib'],
//             'Yatsı': timings['Isha'],
//           };
//         });
        
//         if (_notificationsEnabled) {
//           await _schedulePrayerNotifications(timings);
//         }
        
//         _calculateHijriDate();
//         _calculateNextPrayerTime();
//       } else {
//         throw Exception('Namaz vakitleri alınamadı');
//       }
//     } catch (error) {
//       print('Namaz vakitleri çekilirken hata: $error');
//       setState(() {
//         _errorMessage = 'Namaz vakitleri alınamadı. Lütfen internet bağlantınızı kontrol edin.';
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   void _calculateNextPrayerTime() {
//     if (_prayerTimes == null) return;
    
//     final now = DateTime.now();
//     final today = DateFormat('yyyy-MM-dd').format(now);
    
//     String? nextPrayer;
//     DateTime? nextTime;
//     Duration minDiff = const Duration(days: 1);
    
//     for (final prayerName in _prayerNames) {
//       final prayerTimeStr = _prayerTimes![prayerName]!;
//       final prayerTimeToday = DateTime.parse('$today $prayerTimeStr:00');
//       final prayerTimeTomorrow = prayerTimeToday.add(const Duration(days: 1));
      
//       final diffToday = prayerTimeToday.difference(now);
//       final diffTomorrow = prayerTimeTomorrow.difference(now);
      
//       if (diffToday.inSeconds >= 0 && diffToday < minDiff) {
//         minDiff = diffToday;
//         nextPrayer = prayerName;
//         nextTime = prayerTimeToday;
//       }
      
//       if (diffTomorrow.inSeconds >= 0 && diffTomorrow < minDiff) {
//         minDiff = diffTomorrow;
//         nextPrayer = prayerName;
//         nextTime = prayerTimeTomorrow;
//       }
//     }
    
//     setState(() {
//       _nextPrayerName = nextPrayer;
//       _nextPrayerTime = nextTime;
//     });
//   }

//   String _formatRemainingTime(Duration duration) {
//     final hours = duration.inHours.toString().padLeft(2, '0');
//     final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
//     final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
//     return '$hours:$minutes:$seconds';
//   }

//   Future<void> _schedulePrayerNotifications(Map<String, dynamic> timings) async {
//     if (!_notificationsEnabled) return;
    
//     try {
//       // await flutterLocalNotificationsPlugin.cancelAll();
      
//       // const androidDetails = AndroidNotificationDetails(
//       //   'prayer-times',
//       //   'Namaz Vakitleri',
//       //   channelDescription: 'Namaz vakti geldiğinde bildirim gönderir',
//       //   importance: Importance.high,
//       //   priority: Priority.high,
//       // );
      
//       // const notificationDetails = NotificationDetails(android: androidDetails);
      
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
//       final prayers = [
//         {'name': 'İmsak', 'time': timings['Fajr'], 'message': 'Sahur vakti sona eriyor.'},
//         {'name': 'Güneş', 'time': timings['Sunrise']},
//         {'name': 'Öğle', 'time': timings['Dhuhr']},
//         {'name': 'İkindi', 'time': timings['Asr']},
//         {'name': 'Akşam', 'time': timings['Maghrib'], 'message': 'İftar vakti yaklaşıyor.'},
//         {'name': 'Yatsı', 'time': timings['Isha']},
//       ];
      
//       for (int i = 0; i < prayers.length; i++) {
//         final prayer = prayers[i];
//         final prayerTime = DateTime.parse('$today ${prayer['time']}:00');
//         final notificationTime = prayerTime.subtract(Duration(minutes: int.parse(_notificationBeforeMinutes)));
        
//         // if (notificationTime.isAfter(DateTime.now())) {
//         //   await flutterLocalNotificationsPlugin.schedule(
//         //     i,
//         //     '${prayer['name']} Vakti',
//         //     '${prayer['name']} namazı $_notificationBeforeMinutes dakika sonra. ${prayer['message'] ?? ''}',
//         //     notificationTime,
//         //     notificationDetails,
//         //   );
//         // }
//       }
      
//       // Nafile namazlar için bildirimler
//       if (_selectedNafilePrayers.isNotEmpty) {
//         int notificationId = 100;
        
//         if (_selectedNafilePrayers.contains('teheccud')) {
//           final teheccudTime = DateTime.parse('$today ${timings['Fajr']}:00').subtract(const Duration(hours: 2));
//           final notificationTime = teheccudTime.subtract(Duration(minutes: int.parse(_notificationBeforeMinutes)));
          
//           // if (notificationTime.isAfter(DateTime.now())) {
//           //   await flutterLocalNotificationsPlugin.schedule(
//           //     notificationId++,
//           //     'Teheccüd Vakti',
//           //     'Teheccüd namazı $_notificationBeforeMinutes dakika sonra.',
//           //     notificationTime,
//           //     notificationDetails,
//           //   );
//           // }
//         }
        
//         if (_selectedNafilePrayers.contains('duha')) {
//           final duhaTime = DateTime.parse('$today ${timings['Sunrise']}:00').add(const Duration(minutes: 45));
//           final notificationTime = duhaTime.subtract(Duration(minutes: int.parse(_notificationBeforeMinutes)));
          
//           // if (notificationTime.isAfter(DateTime.now())) {
//           //   await flutterLocalNotificationsPlugin.schedule(
//           //     notificationId++,
//           //     'Kuşluk Vakti',
//           //     'Kuşluk namazı $_notificationBeforeMinutes dakika sonra.',
//           //     notificationTime,
//           //     notificationDetails,
//           //   );
//           // }
//         }
        
//         if (_selectedNafilePrayers.contains('evvabin')) {
//           final evvabinTime = DateTime.parse('$today ${timings['Maghrib']}:00').add(const Duration(minutes: 20));
//           final notificationTime = evvabinTime.subtract(Duration(minutes: int.parse(_notificationBeforeMinutes)));
          
//           // if (notificationTime.isAfter(DateTime.now())) {
//           //   await flutterLocalNotificationsPlugin.schedule(
//           //     notificationId++,
//           //     'Evvabin Vakti',
//           //     'Evvabin namazı $_notificationBeforeMinutes dakika sonra.',
//           //     notificationTime,
//           //     notificationDetails,
//           //   );
//           // }
//         }
//       }
//     } catch (error) {
//       print('Bildirimler planlanırken hata: $error');
//     }
//   }

//   void _calculateHijriDate() {
//     try {
//       final hijri = HijriCalendar.now();
//       setState(() {
//         _hijriDate = '${hijri.hDay} ${_getHijriMonthName(hijri.hMonth)} ${hijri.hYear}';
//         _hijriDateArabic = '${_toArabicNumber(hijri.hDay)} ${_getHijriMonthNameArabic(hijri.hMonth)} ${_toArabicNumber(hijri.hYear)}';
//       });
//     } catch (error) {
//       print('Hicri tarih hesaplanırken hata: $error');
//     }
//   }

//   String _getHijriMonthName(int month) {
//     const months = [
//       'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
//       'Cemaziyülevvel', 'Cemaziyülahir', 'Recep',
//       'Şaban', 'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce'
//     ];
//     return months[month - 1];
//   }

//   String _getHijriMonthNameArabic(int month) {
//     const months = [
//       'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
//       'جمادى الأولى', 'جمادى الآخرة', 'رجب',
//       'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
//     ];
//     return months[month - 1];
//   }

//   String _toArabicNumber(int num) {
//     return num.toString().split('').map((digit) => _arabicNumerals[int.parse(digit)]).join('');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Color(0xFF1e63b4)),
//               SizedBox(height: 16),
//               Text('Namaz vakitleri yükleniyor...', style: TextStyle(fontSize: 16)),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 50, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   _errorMessage!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16, color: Colors.red),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to settings
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1e63b4),
//                   ),
//                   child: const Text('Ayarları Düzenle', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
            
//             // Tarih bilgileri
//             if (_showGregorianDate || _showHijriDate) ...[
//               if (_showGregorianDate)
//                 Text(
//                   DateFormat('d MMMM yyyy, EEEE').format(DateTime.now()),
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                 ),
//               if (_showHijriDate) ...[
//                 const SizedBox(height: 8),
//                 if (_showArabicText)
//                   Text(
//                     _hijriDateArabic,
//                     style: const TextStyle(fontSize: 18, color: Colors.black54),
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _hijriDate,
//                   style: const TextStyle(fontSize: 16, color: Colors.black54),
//                 ),
//               ],
//               const SizedBox(height: 30),
//             ],
            
//             // Namaz vakitleri çemberi
//             if (_prayerTimes != null) ...[
//               SizedBox(
//                 width: 300,
//                 height: 300,
//                 child: CustomPaint(
//                   painter: PrayerCirclePainter(_prayerTimes!, _currentTime),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
            
//             // Sonraki namaz bilgisi
//             if (_nextPrayerName != null && _nextPrayerTime != null) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF0F4F8),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Bir sonraki namaz: $_nextPrayerName',
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _formatRemainingTime(_nextPrayerTime!.difference(_currentTime)),
//                       style: const TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1e63b4),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text('kaldı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
            
//             // Günlük namaz vakitleri listesi
//             if (_prayerTimes != null) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Günlük Namaz Vakitleri',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     ..._prayerNames.map((name) => Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       decoration: BoxDecoration(
//                         color: _nextPrayerName == name ? const Color(0xFFE8F4FD) : null,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(name, style: const TextStyle(fontSize: 16)),
//                           Text(
//                             _prayerTimes![name]!,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF1e63b4),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//                   ],
//                 ),
//               ),
//             ],
            
//             // Seçili nafile namazlar
//             if (_selectedNafilePrayers.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Seçili Nafile Namazlar',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     ..._selectedNafilePrayers.map((nafileId) {
//                       String nafileName = '';
//                       String nafileTime = '';
                      
//                       switch (nafileId) {
//                         case 'teheccud':
//                           nafileName = 'Teheccüd Namazı';
//                           if (_prayerTimes != null) {
//                             final imsakTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${_prayerTimes!['İmsak']}:00');
//                             final teheccudTime = imsakTime.subtract(const Duration(hours: 2));
//                             nafileTime = DateFormat('HH:mm').format(teheccudTime);
//                           }
//                           break;
//                         case 'duha':
//                           nafileName = 'Kuşluk (Duha) Namazı';
//                           if (_prayerTimes != null) {
//                             final sunriseTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${_prayerTimes!['Güneş']}:00');
//                             final duhaTime = sunriseTime.add(const Duration(minutes: 45));
//                             nafileTime = DateFormat('HH:mm').format(duhaTime);
//                           }
//                           break;
//                         case 'evvabin':
//                           nafileName = 'Evvabin Namazı';
//                           if (_prayerTimes != null) {
//                             final maghribTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${_prayerTimes!['Akşam']}:00');
//                             final evvabinTime = maghribTime.add(const Duration(minutes: 20));
//                             nafileTime = DateFormat('HH:mm').format(evvabinTime);
//                           }
//                           break;
//                       }
                      
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(nafileName, style: const TextStyle(fontSize: 16)),
//                             if (nafileTime.isNotEmpty)
//                               Text(
//                                 nafileTime,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color(0xFF1e63b4),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PrayerCirclePainter extends CustomPainter {
//   final Map<String, String> prayerTimes;
//   final DateTime currentTime;
  
//   PrayerCirclePainter(this.prayerTimes, this.currentTime);
  
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 20;
    
//     // Çember çizimi
//     final circlePaint = Paint()
//       ..color = Colors.grey.shade300
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
    
//     canvas.drawCircle(center, radius, circlePaint);
    
//     // Namaz vakitleri
//     final prayerNames = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
//     final angles = [0, 60, 120, 180, 240, 300];
    
//     for (int i = 0; i < prayerNames.length; i++) {
//       final angle = (angles[i] - 90) * pi / 180;
//       final x = center.dx + (radius - 30) * cos(angle);
//       final y = center.dy + (radius - 30) * sin(angle);
      
//       // Namaz kutusu
//       final boxPaint = Paint()..color = const Color(0xFF1e63b4);
//       canvas.drawCircle(Offset(x, y), 20, boxPaint);
      
//       // Namaz ismi
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: prayerNames[i].substring(0, 1),
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//       textPainter.layout();
//       textPainter.paint(
//         canvas,
//         Offset(x - textPainter.width / 2, y - textPainter.height / 2),
//       );
//     }
    
//     // Mevcut zaman göstergesi
//     final currentAngle = (currentTime.hour * 60 + currentTime.minute) / (24 * 60) * 2 * pi - pi / 2;
//     final currentX = center.dx + (radius - 10) * cos(currentAngle);
//     final currentY = center.dy + (radius - 10) * sin(currentAngle);
    
//     // Zaman çizgisi
//     final linePaint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 2;
    
//     canvas.drawLine(center, Offset(currentX, currentY), linePaint);
    
//     // Zaman noktası
//     final pointPaint = Paint()..color = Colors.red;
//     canvas.drawCircle(Offset(currentX, currentY), 8, pointPaint);
//   }
  
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
