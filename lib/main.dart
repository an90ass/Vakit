import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:namaz/bloc/location/location_event.dart';
import 'package:namaz/bloc/myPrayers/my_prayers_bloc.dart' show MyPrayersBloc;
import 'package:namaz/bloc/prayer/prayer_bloc.dart';
import 'package:namaz/bloc/quran/quran_bloc.dart';
import 'package:namaz/repositories/prayer_repository.dart';
import 'package:namaz/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaz/bloc/location/location_bloc.dart';
import 'package:namaz/services/LocationService.dart';
import 'package:namaz/hive/prayer_day.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locationService = LocationService();
  final prayerRepository = PrayerRepository();
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PrayerDayAdapter());
  await Hive.openBox<PrayerDay>('prayers');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(
          create: (_) => LocationBloc(locationService)..add(LocationLoad()),
        ),
        BlocProvider<PrayerBloc>(
          create: (_) => PrayerBloc(repository: prayerRepository),
        ),
        // BlocProvider<MyPrayersBloc>(
        // create: (_) => MyPrayersBloc(), ),

             BlocProvider<QuranBloc>(
          create: (_) => QuranBloc( ), 
         
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
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder:
          (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          ),
    );
  }
}
