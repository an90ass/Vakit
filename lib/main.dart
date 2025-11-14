import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:namaz/bloc/app_language/app_language_cubit.dart';
import 'package:namaz/bloc/location/location_bloc.dart';
import 'package:namaz/bloc/location/location_event.dart';
import 'package:namaz/bloc/prayer/prayer_bloc.dart';
import 'package:namaz/bloc/profile/profile_cubit.dart';
import 'package:namaz/bloc/quran/quran_bloc.dart';
import 'package:namaz/bloc/theme/theme_cubit.dart';
import 'package:namaz/bloc/theme/theme_state.dart';
import 'package:namaz/bloc/tracked_locations/tracked_locations_cubit.dart';
import 'package:namaz/hive/prayer_day.dart';
import 'package:namaz/l10n/generated/app_localizations.dart';
import 'package:namaz/repositories/extra_prayer_repository.dart';
import 'package:namaz/repositories/prayer_repository.dart';
import 'package:namaz/repositories/profile_repository.dart';
import 'package:namaz/repositories/qada_repository.dart';
import 'package:namaz/screens/home_screen.dart';
import 'package:namaz/services/LocationService.dart';
import 'package:namaz/services/extra_prayer_notification_service.dart';
import 'package:namaz/services/tracked_location_service.dart';
import 'package:namaz/theme/vakit_theme.dart';
import 'package:namaz/utlis/thems/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final locationService = LocationService();
  final prayerRepository = PrayerRepository();
  final trackedLocationService = TrackedLocationService(prefs);
  final profileRepository = ProfileRepository(prefs);
  final notificationService = ExtraPrayerNotificationService();

  await Hive.initFlutter();
  Hive.registerAdapter(PrayerDayAdapter());
  await Hive.openBox<PrayerDay>('prayers');
  final qadaBox = await Hive.openBox(QadaRepository.boxName);
  final extraPrayerBox = await Hive.openBox(ExtraPrayerRepository.boxName);
  final qadaRepository = QadaRepository(qadaBox);
  final extraPrayerRepository = ExtraPrayerRepository(extraPrayerBox);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: profileRepository),
        RepositoryProvider.value(value: qadaRepository),
        RepositoryProvider.value(value: extraPrayerRepository),
        RepositoryProvider.value(value: notificationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs)),
          BlocProvider<AppLanguageCubit>(
            create: (_) => AppLanguageCubit(prefs),
          ),
          BlocProvider<LocationBloc>(
            create: (_) => LocationBloc(locationService)..add(LocationLoad()),
          ),
          BlocProvider<TrackedLocationsCubit>(
            create:
                (_) => TrackedLocationsCubit(
                  storage: trackedLocationService,
                  repository: prayerRepository,
                  locationService: locationService,
                )..loadTrackedLocations(),
          ),
          BlocProvider<PrayerBloc>(
            create: (_) => PrayerBloc(repository: prayerRepository),
          ),
          BlocProvider<QuranBloc>(create: (_) => QuranBloc()),
          BlocProvider<ProfileCubit>(
            create:
                (context) => ProfileCubit(
                  repository: context.read<ProfileRepository>(),
                  notificationService:
                      context.read<ExtraPrayerNotificationService>(),
                )..loadProfile(),
          ),
        ],
        child: const VakitApp(),
      ),
    ),
  );
}

class VakitApp extends StatelessWidget {
  const VakitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, VakitThemeState>(
          builder: (context, themeState) {
            AppColors.update(themeState.palette, themeState.softness);
            final theme = buildVakitTheme(
              themeState.palette,
              themeState.softness,
            );
            return BlocBuilder<AppLanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  theme: theme,
                  supportedLocales: const [
                    Locale('tr'),
                    Locale('en'),
                    Locale('ar'),
                  ],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: const HomeScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}
