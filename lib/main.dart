import 'package:flutter/material.dart';
import 'package:namaz/bloc/location/location_event.dart';
import 'package:namaz/bloc/prayer/prayer_bloc.dart';
import 'package:namaz/repositories/prayer_repository.dart';
import 'package:namaz/screens/home_screen.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/home_screen.dart';
// import 'screens/life_weeks_screen.dart';
// import 'screens/nafile_screen.dart';
// import 'screens/settings_screen.dart';

// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// //     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // // Bildirim ayarları
//   // const AndroidInitializationSettings initializationSettingsAndroid =
//   //     AndroidInitializationSettings('@mipmap/ic_launcher');
  
//   // const InitializationSettings initializationSettings =
//   //     InitializationSettings(android: initializationSettingsAndroid);
  
//   // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
//   runApp(const VakitApp());
// }

// class VakitApp extends StatefulWidget {
//   const VakitApp({super.key});

//   @override
//   State<VakitApp> createState() => _VakitAppState();
// }

// class _VakitAppState extends State<VakitApp> {
//   bool _isFirstLaunch = true;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkFirstLaunch();
//   }

//   Future<void> _checkFirstLaunch() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final hasLaunched = prefs.getBool('hasLaunched') ?? false;
      
//       if (!hasLaunched) {
//         await _setupDefaultSettings();
//         await prefs.setBool('hasLaunched', true);
//       }
      
//       setState(() {
//         _isFirstLaunch = !hasLaunched;
//         _isLoading = false;
//       });
//     } catch (error) {
//       print('İlk açılış kontrolü sırasında hata: $error');
//       setState(() {
//         _isFirstLaunch = false;
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _setupDefaultSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('notificationsEnabled', true);
//       await prefs.setString('notificationBeforeMinutes', '30');
//       await prefs.setBool('notificationSound', true);
//       await prefs.setBool('notificationVibration', true);
//       await prefs.setBool('showArabicText', true);
//       await prefs.setBool('showHijriDate', true);
//       await prefs.setBool('showGregorianDate', true);
//       await prefs.setString('appLanguage', 'tr');
//       await prefs.setStringList('selectedNafile', []);
//     } catch (error) {
//       print('Varsayılan ayarlar kaydedilirken hata: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 CircularProgressIndicator(color: Color(0xFF1e63b4)),
//                 SizedBox(height: 16),
//                 Text('Yükleniyor...', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return MaterialApp(
//       title: 'Vakit',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         primaryColor: const Color(0xFF1e63b4),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const MainScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
  
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const LifeWeeksScreen(),
//     const NafileScreen(),
//     const SettingsScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         selectedItemColor: const Color(0xFF1e63b4),
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.access_time),
//             label: 'Namaz Vakitleri',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: 'Hayat Haftaları',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.nightlight_round),
//             label: 'Nafile Namazlar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Ayarlar',
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaz/bloc/location/location_bloc.dart';
import 'package:namaz/services/LocationService.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  final locationService = LocationService();
  final prayerRepository = PrayerRepository();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(
          create: (_) => LocationBloc(locationService)..add(LocationLoad()), 
         
        ),
          BlocProvider<PrayerBloc>(
          create: (_) => PrayerBloc(repository:prayerRepository ), 
         
        ),
      ],
      child: const VakitApp(),
    ),
  );
}

class VakitApp extends StatelessWidget {
  const VakitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
